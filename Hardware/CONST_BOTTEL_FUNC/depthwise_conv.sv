module depthwise_conv #(
    parameter N = 16,            // Data width
    parameter Q = 8,             // Fractional bits
    parameter IN_WIDTH = 112,    // Input feature map width
    parameter IN_HEIGHT = 112,   // Input feature map height
    parameter CHANNELS = 16,     // Number of channels
    parameter KERNEL_SIZE = 3,   // Kernel size (3x3)
    parameter STRIDE = 1,        // Stride
    parameter PADDING = 1,       // Padding
    parameter PARALLELISM = 4    // Process 4 channels in parallel
) (
    input wire clk,
    input wire rst,
    input wire en,
    
    // Input interface
    input wire [N-1:0] data_in,
    input wire [$clog2(CHANNELS)-1:0] channel_in,
    input wire valid_in,
    
    // Weight interface
    input wire [(KERNEL_SIZE*KERNEL_SIZE*PARALLELISM*N)-1:0] weights, // Reduced weight interface
    
    // Output interface
    output reg [N-1:0] data_out,
    output reg [$clog2(CHANNELS)-1:0] channel_out,
    output reg valid_out,
    output reg done
);

    // Calculate output dimensions
    localparam OUT_WIDTH = (IN_WIDTH + 2*PADDING - KERNEL_SIZE) / STRIDE + 1;
    localparam OUT_HEIGHT = (IN_HEIGHT + 2*PADDING - KERNEL_SIZE) / STRIDE + 1;
    
    // State machine
    typedef enum logic [1:0] { // Reduced state encoding
        IDLE,
        LOAD_WEIGHTS,
        PROCESSING,
        COMPLETED
    } state_t;
    
    state_t state;
    
    // Partitioned line buffer - one per parallel channel
    (* ram_style = "block" *) reg [N-1:0] line_buffer_mem [0:PARALLELISM-1][0:KERNEL_SIZE*IN_WIDTH-1];
    
    // Partitioned weight memory - one per parallel channel
    (* ram_style = "block" *) reg [N-1:0] weight_memory [0:PARALLELISM-1][0:KERNEL_SIZE*KERNEL_SIZE-1];
    
    // Input tracking
    reg [$clog2(IN_WIDTH)-1:0] input_x;
    reg [$clog2(IN_HEIGHT)-1:0] input_y;
    reg [$clog2(CHANNELS/PARALLELISM)-1:0] input_ch_group;
    reg [$clog2(IN_WIDTH*IN_HEIGHT*CHANNELS/PARALLELISM + 1)-1:0] input_count;
    
    // Output tracking
    reg [$clog2(OUT_WIDTH)-1:0] output_x;
    reg [$clog2(OUT_HEIGHT)-1:0] output_y;
    reg [$clog2(CHANNELS/PARALLELISM)-1:0] output_ch_group;
    reg [$clog2(OUT_WIDTH*OUT_HEIGHT*CHANNELS/PARALLELISM + 1)-1:0] output_count;
    
    // Control signals
    reg weights_loaded;
    reg buffer_ready;
    
    // Parallel computation signals
    reg signed [N-1:0] window_data [0:PARALLELISM-1][0:KERNEL_SIZE*KERNEL_SIZE-1];
    reg signed [2*N+7:0] acc_reg [0:PARALLELISM-1];
    wire signed [N-1:0] conv_result [0:PARALLELISM-1];
    wire conv_overflow [0:PARALLELISM-1];
    
    localparam TOTAL_INPUTS = IN_WIDTH * IN_HEIGHT * CHANNELS / PARALLELISM;
    localparam TOTAL_OUTPUTS = OUT_WIDTH * OUT_HEIGHT * CHANNELS / PARALLELISM;
    
    // Weight loading state machine
    reg [$clog2(CHANNELS/PARALLELISM)-1:0] weight_ch_group;
    reg [$clog2(KERNEL_SIZE*KERNEL_SIZE)-1:0] weight_k;
    
    // Generate parallel processing units
    genvar i;
    generate
        for (i = 0; i < PARALLELISM; i = i + 1) begin : conv_units
            // Overflow detection and saturation
            assign conv_overflow[i] = (acc_reg[i] > ((1 << (N+Q-1)) - 1)) || (acc_reg[i] < -(1 << (N+Q-1)));
            assign conv_result[i] = conv_overflow[i] ? 
                                  (acc_reg[i] > 0 ? {1'b0, {(N-1){1'b1}}} : {1'b1, {(N-1){1'b0}}}) :
                                  (acc_reg[i] + (1 << (Q-1))) >>> Q;
        end
    endgenerate
    
    // Weight loading - now loads in groups of PARALLELISM channels
    always @(posedge clk) begin
        if (rst) begin
            weights_loaded <= 0;
            weight_ch_group <= 0;
            weight_k <= 0;
        end else if (state == LOAD_WEIGHTS && !weights_loaded) begin
            for (int i = 0; i < PARALLELISM; i = i + 1) begin
                weight_memory[i][weight_k] <= weights[(weight_ch_group*KERNEL_SIZE*KERNEL_SIZE*PARALLELISM + 
                                                     i*KERNEL_SIZE*KERNEL_SIZE + weight_k)*N +: N];
            end
            
            if (weight_k >= KERNEL_SIZE*KERNEL_SIZE - 1) begin
                weight_k <= 0;
                if (weight_ch_group >= (CHANNELS/PARALLELISM) - 1) begin
                    weights_loaded <= 1;
                end else begin
                    weight_ch_group <= weight_ch_group + 1;
                end
            end else begin
                weight_k <= weight_k + 1;
            end
        end
    end
    
    // Line buffer management - now handles PARALLELISM channels at once
    always @(posedge clk) begin
        if (rst) begin
            input_x <= 0;
            input_y <= 0;
            input_ch_group <= 0;
            input_count <= 0;
            buffer_ready <= 0;
        end else if (valid_in && state == PROCESSING) begin
            // Store input data for the current channel group
            for (int i = 0; i < PARALLELISM; i = i + 1) begin
                if (channel_in/PARALLELISM == input_ch_group && channel_in%PARALLELISM == i) begin
                    line_buffer_mem[i][((input_y % KERNEL_SIZE) * IN_WIDTH) + input_x] <= data_in;
                end
            end
            
            // Update input coordinates
            if (channel_in >= CHANNELS - 1) begin
                if (input_x >= IN_WIDTH - 1) begin
                    input_x <= 0;
                    if (input_y >= IN_HEIGHT - 1) begin
                        input_y <= 0;
                        input_ch_group <= input_ch_group + 1;
                    end else begin
                        input_y <= input_y + 1;
                    end
                end else begin
                    input_x <= input_x + 1;
                end
            end
            
            input_count <= input_count + 1;
            
            if (input_count >= (KERNEL_SIZE * IN_WIDTH)) begin
                buffer_ready <= 1;
            end
        end
    end
    
    // Window extraction and convolution computation - pipelined
    reg [$clog2(IN_WIDTH)-1:0] conv_center_x, conv_center_y;
    reg can_compute;
    reg [1:0] pipeline_stage; // Simple 3-stage pipeline
    
    always @(*) begin
        conv_center_x = output_x * STRIDE;
        conv_center_y = output_y * STRIDE;
        can_compute = buffer_ready && (output_count < TOTAL_OUTPUTS);
        
        // Window extraction for each parallel unit
        for (int i = 0; i < PARALLELISM; i = i + 1) begin
            // Simplified window extraction with bounds checking
            if (conv_center_x >= PADDING && conv_center_y >= PADDING && 
                conv_center_x < IN_WIDTH + PADDING && conv_center_y < IN_HEIGHT + PADDING) begin
                // Window data for current position
                window_data[i][0] = line_buffer_mem[i][((conv_center_y - PADDING) % KERNEL_SIZE) * IN_WIDTH + (conv_center_x - PADDING)];
                window_data[i][1] = line_buffer_mem[i][((conv_center_y - PADDING) % KERNEL_SIZE) * IN_WIDTH + (conv_center_x + 1 - PADDING)];
                window_data[i][2] = line_buffer_mem[i][((conv_center_y - PADDING) % KERNEL_SIZE) * IN_WIDTH + (conv_center_x + 2 - PADDING)];
                window_data[i][3] = line_buffer_mem[i][((conv_center_y + 1 - PADDING) % KERNEL_SIZE) * IN_WIDTH + (conv_center_x - PADDING)];
                window_data[i][4] = line_buffer_mem[i][((conv_center_y + 1 - PADDING) % KERNEL_SIZE) * IN_WIDTH + (conv_center_x + 1 - PADDING)];
                window_data[i][5] = line_buffer_mem[i][((conv_center_y + 1 - PADDING) % KERNEL_SIZE) * IN_WIDTH + (conv_center_x + 2 - PADDING)];
                window_data[i][6] = line_buffer_mem[i][((conv_center_y + 2 - PADDING) % KERNEL_SIZE) * IN_WIDTH + (conv_center_x - PADDING)];
                window_data[i][7] = line_buffer_mem[i][((conv_center_y + 2 - PADDING) % KERNEL_SIZE) * IN_WIDTH + (conv_center_x + 1 - PADDING)];
                window_data[i][8] = line_buffer_mem[i][((conv_center_y + 2 - PADDING) % KERNEL_SIZE) * IN_WIDTH + (conv_center_x + 2 - PADDING)];
            end else begin
                // Zero padding for border cases
                for (int j = 0; j < KERNEL_SIZE*KERNEL_SIZE; j = j + 1) begin
                    window_data[i][j] = 0;
                end
            end
        end
    end
    
    // Pipelined convolution computation
    always @(posedge clk) begin
        if (rst) begin
            for (int i = 0; i < PARALLELISM; i = i + 1) begin
                acc_reg[i] <= 0;
            end
            pipeline_stage <= 0;
        end else begin
            case (pipeline_stage)
                0: begin // Stage 1: First three multiplications
                    if (can_compute) begin
                        for (int i = 0; i < PARALLELISM; i = i + 1) begin
                            acc_reg[i] <= ($signed(window_data[i][0]) * $signed(weight_memory[i][0])) +
                                          ($signed(window_data[i][1]) * $signed(weight_memory[i][1])) +
                                          ($signed(window_data[i][2]) * $signed(weight_memory[i][2]));
                        end
                        pipeline_stage <= 1;
                    end
                end
                
                1: begin // Stage 2: Next three multiplications and accumulate
                    for (int i = 0; i < PARALLELISM; i = i + 1) begin
                        acc_reg[i] <= acc_reg[i] +
                                      ($signed(window_data[i][3]) * $signed(weight_memory[i][3])) +
                                      ($signed(window_data[i][4]) * $signed(weight_memory[i][4])) +
                                      ($signed(window_data[i][5]) * $signed(weight_memory[i][5]));
                    end
                    pipeline_stage <= 2;
                end
                
                2: begin // Stage 3: Final three multiplications and accumulate
                    for (int i = 0; i < PARALLELISM; i = i + 1) begin
                        acc_reg[i] <= acc_reg[i] +
                                      ($signed(window_data[i][6]) * $signed(weight_memory[i][6])) +
                                      ($signed(window_data[i][7]) * $signed(weight_memory[i][7])) +
                                      ($signed(window_data[i][8]) * $signed(weight_memory[i][8]));
                    end
                    pipeline_stage <= 0;
                end
            endcase
        end
    end
    
    // Main processing state machine - simplified
    always @(posedge clk) begin
        if (rst) begin
            state <= IDLE;
            data_out <= 0;
            channel_out <= 0;
            valid_out <= 0;
            done <= 0;
            output_x <= 0;
            output_y <= 0;
            output_ch_group <= 0;
            output_count <= 0;
        end else begin
            case (state)
                IDLE: begin
                    if (en && !done) begin
                        state <= LOAD_WEIGHTS;
                        output_count <= 0;
                        output_x <= 0;
                        output_y <= 0;
                        output_ch_group <= 0;
                       // weights_loaded <= 0;
                    end
                    valid_out <= 0;
                end
                
                LOAD_WEIGHTS: begin
                    if (weights_loaded) begin
                        state <= PROCESSING;
                    end
                end
                
                PROCESSING: begin
                    valid_out <= 0;
                    
                    if (can_compute && pipeline_stage == 2 && output_count < TOTAL_OUTPUTS) begin
                        // Output results for all parallel channels
                        for (int i = 0; i < PARALLELISM; i = i + 1) begin
                            if (i == 0) begin // Only one output per cycle to save resources
                                data_out <= conv_result[i];
                                channel_out <= output_ch_group * PARALLELISM + i;
                                valid_out <= 1;
                            end
                        end
                        
                        output_count <= output_count + 1;
                        
                        // Update output coordinates
                        if (output_ch_group >= (CHANNELS/PARALLELISM) - 1) begin
                            output_ch_group <= 0;
                            if (output_x >= OUT_WIDTH - 1) begin
                                output_x <= 0;
                                if (output_y >= OUT_HEIGHT - 1) begin
                                    output_y <= 0;
                                    state <= COMPLETED;
                                    done <= 1;
                                end else begin
                                    output_y <= output_y + 1;
                                end
                            end else begin
                                output_x <= output_x + 1;
                            end
                        end else begin
                            output_ch_group <= output_ch_group + 1;
                        end
                    end
                end
                
                COMPLETED: begin
                    valid_out <= 0;
                    done <= 1;
                    if (!en) begin
                        state <= IDLE;
                        done <= 0;
                    end
                end
            endcase
        end
    end
endmodule