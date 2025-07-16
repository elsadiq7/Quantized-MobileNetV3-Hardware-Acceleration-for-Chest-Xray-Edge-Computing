`timescale 1ns / 1ps

module convolver #(
    parameter N = 16,    
    parameter Q = 8,      
    parameter n = 224,   
    parameter k = 3,     
    parameter s = 2,     
    parameter p = 1,    
    parameter IN_CHANNELS = 1,    
    parameter OUT_CHANNELS = 16,  
    parameter NUM_MAC = 4 
)(
    input wire clk,                   
    input wire rst,                   
    input wire en,                    
    input wire [N-1:0] activation_in, 
    input wire [(k*k*IN_CHANNELS*OUT_CHANNELS*N)-1:0] weight, 
    output reg [N-1:0] conv_out,      
    output reg [$clog2(OUT_CHANNELS)-1:0] channel_out,     
    output reg valid_out,             
    output reg done                  
);

    // Padded input dimensions
    localparam n_padded = n + 2*p;
    
    // Output dimensions after convolution with stride - CORRECTED
    localparam o = ((n_padded - k) / s) + 1;  // 112 for 224x224 input with stride 2
    
    // FIXED: Correct expected output calculation
    localparam EXPECTED_TOTAL_OUTPUTS = o * o * OUT_CHANNELS;  // 112 * 112 * 16 = 200,704

    // Line buffer stores padded rows - optimized for block RAM inference
    (* ram_style = "block" *) reg [N-1:0] line_buffer [(k-1)*(n_padded)-1:0];

    // Window buffer represents the current k x k window used for convolution
    wire [N-1:0] window_buffer [k*k-1:0];

    // CLEAN: Counter widths for proper functionality (no timeout counters)
    reg [$clog2(n*n+1)-1:0] input_counter;
    reg [$clog2(EXPECTED_TOTAL_OUTPUTS+1)-1:0] output_counter;
    reg [$clog2(o+1)-1:0] out_x_counter;  // Output position counters
    reg [$clog2(o+1)-1:0] out_y_counter;  // Output position counters
    reg [$clog2(n_padded+1)-1:0] x_counter;
    reg [$clog2(n_padded+1)-1:0] y_counter;
    reg [$clog2(OUT_CHANNELS)-1:0] channel_counter;
    reg [$clog2(k)-1:0] row_counter;

    // Weight buffer for the current output channel - optimized for block RAM
    (* ram_style = "block" *) reg [N-1:0] current_weights [k*k*IN_CHANNELS-1:0];

    // CLEAN: State machine - simplified for reliable operation (no timeouts)
    localparam [2:0] IDLE = 3'b000, 
                     LOAD_WEIGHTS = 3'b001,
                     LOAD_INPUT = 3'b010, 
                     COMPUTE = 3'b011, 
                     NEXT_CHANNEL = 3'b100, 
                     DONE = 3'b101;
    reg [2:0] state, next_state;

    // CLEAN: Completion tracking flags (no timeout flags)
    reg all_inputs_loaded;
    reg current_channel_complete;
    reg all_channels_complete;

    // Synthesis-friendly loop variables
    genvar i, j;

    // Load weights for current channel - CLEAN logic
    always @(posedge clk) begin
        if (rst) begin
            for (integer idx = 0; idx < k*k*IN_CHANNELS; idx = idx + 1) begin
                current_weights[idx] <= 0;
            end
        end else if (state == LOAD_WEIGHTS || state == NEXT_CHANNEL) begin
            // Sequential weight loading for better timing
            for (integer idx = 0; idx < k*k*IN_CHANNELS; idx = idx + 1) begin
                current_weights[idx] <= weight[(channel_counter*k*k*IN_CHANNELS + idx)*N +: N];
            end
        end
    end

    // Line buffer shift register logic with padding - optimized for block RAM
    always @(posedge clk) begin
        if (rst) begin
            for (integer idx = 0; idx < (k-1)*(n_padded); idx = idx + 1) begin
                line_buffer[idx] <= 0;
            end
        end else if (en && state == LOAD_INPUT) begin
            // Sequential shift for better timing
            for (integer idx = (k-1)*(n_padded)-1; idx > 0; idx = idx - 1) begin
                line_buffer[idx] <= line_buffer[idx-1];
            end
            line_buffer[0] <= activation_in;
        end
    end

    // Window buffer assignment - optimized for timing
    genvar wx, wy;
    generate
        for (wy = 0; wy < k; wy = wy + 1) begin : window_row
            for (wx = 0; wx < k; wx = wx + 1) begin : window_col
                if (wy == k-1) begin
                    assign window_buffer[wy*k + wx] = line_buffer[wx];
                end else begin
                    assign window_buffer[wy*k + wx] = line_buffer[wy*(n_padded) + wx];
                end
            end
        end
    endgenerate

    // FIXED: MAC operation for reliable functionality with proper accumulation
    reg [2*N-1:0] conv_acc; 
    reg [N-1:0] conv_temp;
    reg mac_valid;
    
    // FIXED: Combinational MAC computation with proper accumulation
    wire [2*N-1:0] conv_sum;
    wire [2*N-1:0] mult_results [k*k-1:0];
    
    // Generate multiplication results combinationally
    genvar mac_idx;
    generate
        for (mac_idx = 0; mac_idx < k*k; mac_idx = mac_idx + 1) begin : mult_gen
            assign mult_results[mac_idx] = $signed(window_buffer[mac_idx]) * $signed(current_weights[mac_idx]);
        end
    endgenerate
    
    // Combinational sum of all multiplication results
    assign conv_sum = mult_results[0] + mult_results[1] + mult_results[2] + 
                      mult_results[3] + mult_results[4] + mult_results[5] + 
                      mult_results[6] + mult_results[7] + mult_results[8];
    
    // FIXED: Sequential MAC with corrected logic - MAC always valid in COMPUTE
    always @(posedge clk) begin
        if (rst) begin
            conv_acc <= 0;
            conv_temp <= 0;
            mac_valid <= 1'b0;
        end else if (state == COMPUTE) begin
            // FIXED: MAC always computes during COMPUTE state 
            conv_acc <= conv_sum;
            
            // Quantization with rounding
            if (conv_sum[2*N-1]) begin // Negative number
                conv_temp <= (conv_sum - (1 << (Q-1))) >>> Q;
            end else begin // Positive number
                conv_temp <= (conv_sum + (1 << (Q-1))) >>> Q;
            end
            
            mac_valid <= 1'b1;
            if (x_counter % 500 == 0 && y_counter % 500 == 0) begin
                $display("CONVOLVER: MAC computed - sum=0x%08x, quantized=0x%04x", conv_sum, conv_temp);
            end
        end else begin
            mac_valid <= 1'b0;
        end
    end

    // CLEAN: Pure logic-based next state transitions (no timeouts)
    always @(*) begin
        next_state = state;

        case (state)
            IDLE: begin
                if (en) next_state = LOAD_WEIGHTS;
            end
            
            LOAD_WEIGHTS: begin
                next_state = LOAD_INPUT;
            end
            
            LOAD_INPUT: begin
                if (all_inputs_loaded) begin
                    next_state = COMPUTE;
                end
            end
            
            COMPUTE: begin
                // CLEAN: Pure completion detection based on actual work completion
                if (current_channel_complete) begin
                    if (channel_counter >= (OUT_CHANNELS - 1)) begin
                        next_state = DONE;
                    end else begin
                        next_state = NEXT_CHANNEL;
                    end
                end
            end
            
            NEXT_CHANNEL: begin
                next_state = COMPUTE;
            end
            
            DONE: begin
                if (!en) next_state = IDLE;
            end
            
            default: next_state = IDLE;
        endcase
    end

    // CLEAN: Pure logic-based state machine and control logic (no timeouts)
    always @(posedge clk) begin
        if (rst) begin
            state <= IDLE;
            input_counter <= 0;
            output_counter <= 0;
            out_x_counter <= 0;
            out_y_counter <= 0;
            x_counter <= 0;
            y_counter <= 0;
            channel_counter <= 0;
            row_counter <= 0;
            valid_out <= 1'b0;
            done <= 1'b0;
            conv_out <= 0;
            channel_out <= 0;
            all_inputs_loaded <= 1'b0;
            current_channel_complete <= 1'b0;
            all_channels_complete <= 1'b0;
        end else if (en) begin
            // Debug state transitions
            if (state != next_state) begin
                case (next_state)
                    IDLE: $display("CONVOLVER: State transition to IDLE");
                    LOAD_WEIGHTS: $display("CONVOLVER: State transition to LOAD_WEIGHTS");
                    LOAD_INPUT: $display("CONVOLVER: State transition to LOAD_INPUT - expecting %0d pixels", n*n);
                    COMPUTE: $display("CONVOLVER: State transition to COMPUTE");
                    NEXT_CHANNEL: $display("CONVOLVER: State transition to NEXT_CHANNEL");
                    DONE: $display("CONVOLVER: State transition to DONE");
                endcase
            end
            
            state <= next_state;
            
            case (state)
                IDLE: begin
                    if (next_state == LOAD_WEIGHTS) begin
                        input_counter <= 0;
                        channel_counter <= 0;
                        output_counter <= 0;
                        out_x_counter <= 0;
                        out_y_counter <= 0;
                        x_counter <= 0;
                        y_counter <= 0;
                        row_counter <= 0;
                        done <= 1'b0;
                        all_inputs_loaded <= 1'b0;
                        current_channel_complete <= 1'b0;
                        all_channels_complete <= 1'b0;
                        $display("CONVOLVER: Reset counters for new processing");
                    end
                end
                
                LOAD_WEIGHTS: begin
                    valid_out <= 1'b0;
                    $display("CONVOLVER: Loading weights for channel %0d", channel_counter);
                end
                
                LOAD_INPUT: begin
                    static int load_debug_count = 0;
                    
                    if (input_counter < n*n) begin
                        input_counter <= input_counter + 1'b1;
                        
                        // SYNTHESIS FIX: Detailed input loading debug without floating-point
                        load_debug_count++;
                        if (load_debug_count % 5000 == 0 || load_debug_count < 10) begin
                            $display("CONVOLVER: Loading input pixel %0d/%0d - data=0x%04x", 
                                     input_counter + 1, n*n, activation_in);
                        end
                        
                        // Track when all inputs are loaded
                        if (input_counter >= (n*n - 1)) begin
                            all_inputs_loaded <= 1'b1;
                            x_counter <= 0;
                            y_counter <= 0;
                            $display("CONVOLVER: *** ALL %0d INPUTS LOADED *** for channel %0d", n*n, channel_counter);
                            $display("CONVOLVER: Transitioning to COMPUTE state");
                        end
                    end else begin
                        $display("CONVOLVER: WARNING - input_counter %0d >= n*n %0d", input_counter, n*n);
                    end
                    valid_out <= 1'b0;
                end
                
                COMPUTE: begin
                    static int compute_debug_count = 0;
                    compute_debug_count++;
                    
                    if (compute_debug_count % 1000 == 0 || compute_debug_count < 10) begin
                        $display("CONVOLVER: COMPUTE cycle %0d - pos(%0d,%0d), out_pos(%0d,%0d)", 
                                 compute_debug_count, x_counter, y_counter, out_x_counter, out_y_counter);
                    end
                    
                    // CLEAN: Pure convolution computation with stride (no timeout checks)
                    if (x_counter < n_padded && y_counter < n_padded) begin
                        // Check if this position generates an output (stride alignment)
                        if ((x_counter >= k/2) && (y_counter >= k/2) && 
                            ((x_counter - k/2) % s == 0) && ((y_counter - k/2) % s == 0) && 
                            mac_valid) begin
                            
                            conv_out <= conv_temp;
                            channel_out <= channel_counter;
                            valid_out <= 1'b1;
                            output_counter <= output_counter + 1'b1;
                            
                            // Track output position
                            if (out_x_counter < (o-1)) begin
                                out_x_counter <= out_x_counter + 1;
                            end else begin
                                out_x_counter <= 0;
                                out_y_counter <= out_y_counter + 1;
                            end
                            
                            if (output_counter % 1000 == 0 || output_counter < 20) begin
                                $display("CONVOLVER: Output #%0d generated at (%0d,%0d) for channel %0d - value=0x%04x", 
                                         output_counter + 1, out_x_counter, out_y_counter, channel_counter, conv_temp);
                            end
                        end else begin
                            valid_out <= 1'b0;
                        end
                        
                        // Advance position counters
                        if (x_counter < (n_padded - 1)) begin
                            x_counter <= x_counter + 1;
                        end else begin
                            x_counter <= 0;
                            y_counter <= y_counter + 1;
                        end
                    end else begin
                        valid_out <= 1'b0;
                        if (compute_debug_count % 1000 == 0) begin
                            $display("CONVOLVER: Position limit reached - x=%0d/%0d, y=%0d/%0d", 
                                     x_counter, n_padded, y_counter, n_padded);
                        end
                    end
                    
                    // CLEAN: Check for current channel completion based on actual work done
                    if (out_x_counter >= (o-1) && out_y_counter >= (o-1)) begin
                        current_channel_complete <= 1'b1;
                        $display("CONVOLVER: Channel %0d complete, generated %0d outputs", 
                                 channel_counter, (output_counter - channel_counter * o * o));
                    end
                    
                    // Alternative completion check based on output count
                    if (output_counter >= ((channel_counter + 1) * o * o)) begin
                        current_channel_complete <= 1'b1;
                    end
                end
                
                NEXT_CHANNEL: begin
                    if (channel_counter < (OUT_CHANNELS-1)) begin
                        channel_counter <= channel_counter + 1'b1;
                        $display("CONVOLVER: Moving to channel %0d", channel_counter + 1);
                    end
                    x_counter <= 0;
                    y_counter <= 0;
                    out_x_counter <= 0;
                    out_y_counter <= 0;
                    current_channel_complete <= 1'b0;
                    all_inputs_loaded <= 1'b1; // Keep inputs loaded for next channel
                    valid_out <= 1'b0;
                end
                
                DONE: begin
                    done <= 1'b1;
                    valid_out <= 1'b0;
                    all_channels_complete <= 1'b1;
                    $display("CONVOLVER: *** ALL PROCESSING COMPLETE *** - %0d total outputs generated", output_counter);
                end
                
                default: begin
                    state <= IDLE;
                end
            endcase
        end
    end

endmodule

