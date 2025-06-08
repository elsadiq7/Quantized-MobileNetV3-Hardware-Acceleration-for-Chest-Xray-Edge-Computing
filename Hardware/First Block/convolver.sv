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
    output reg [4:0] channel_out,     
    output reg valid_out,             
    output reg done                  
);

    // Padded input dimensions
    localparam n_padded = n + 2*p;
    
    // Output dimensions after convolution with stride
    localparam o = ((n_padded - k) / s) + 1;

    // Line buffer stores padded rows of the input image
    reg [N-1:0] line_buffer [(k-1)*(n_padded)-1:0];

    // Window buffer represents the current k x k window used for convolution
    wire [N-1:0] window_buffer [k*k-1:0];

    reg [$clog2(n*n)-1:0] input_counter;        // Tracks input elements processed
    reg [$clog2(o*o*OUT_CHANNELS)-1:0] output_counter; // Tracks outputs generated
    reg [$clog2(n_padded)-1:0] x_counter;       // Position in current row
    reg [$clog2(n_padded)-1:0] y_counter;       // Current row
    reg [$clog2(OUT_CHANNELS)-1:0] channel_counter; // Current output channel
    reg [$clog2(k)-1:0] row_counter;            // Rows in sliding window

    // Weight buffer for the current output channel
    reg [N-1:0] current_weights [k*k*IN_CHANNELS-1:0];

    // State machine to control the convolution process
    localparam IDLE = 3'b000, LOAD = 3'b001, PAD = 3'b010, COMPUTE = 3'b011, 
                NEXT_CHANNEL = 3'b100, DONE = 3'b101;
    reg [2:0] state, next_state;

    integer i, j; 

    reg debug_first_outputs;

    // Load weights for current channel 
    always @(posedge clk) begin
        if (rst) begin
            for (i = 0; i < k*k*IN_CHANNELS; i = i + 1) begin
                current_weights[i] <= 0;
            end
        end else if (state == NEXT_CHANNEL || state == IDLE || (state == LOAD && input_counter == 0)) begin
            for (i = 0; i < k*k*IN_CHANNELS; i = i + 1) begin
                current_weights[i] <= weight[(channel_counter*k*k*IN_CHANNELS + i)*N +: N];
            end
        end
    end

    // Line buffer shift register logic with padding
    always @(posedge clk) begin
        if (rst) begin
            for (i = 0; i < (k-1)*(n_padded); i = i + 1) begin
                line_buffer[i] <= 0;
            end
        end else if (en && (state == LOAD || state == PAD)) begin
            // Shift data in line buffer
            for (i = (k-1)*(n_padded)-1; i > 0; i = i - 1) begin
                line_buffer[i] <= line_buffer[i-1];
            end
            
            if (state == LOAD) begin
                // Load actual data when in LOAD state
                line_buffer[0] <= activation_in;
            end else begin
                // Load zeros for padding
                line_buffer[0] <= 0;
            end
        end
    end

    // Window buffer assignment
    genvar x, y;
    generate
        for (y = 0; y < k; y = y + 1) begin : window_row
            for (x = 0; x < k; x = x + 1) begin : window_col
                if (y == k-1) begin
                    // Bottom row from newest data
                    assign window_buffer[y*k + x] = line_buffer[x];
                end else begin
                    // Rest from line buffer
                    assign window_buffer[y*k + x] = line_buffer[y*(n_padded) + x];
                end
            end
        end
    endgenerate

    reg [2*N-1:0] conv_acc; 
    reg [N-1:0] conv_temp;
    
    always @(*) begin
        conv_acc = 0;
        debug_first_outputs = debug_first_outputs; 

        for (i = 0; i < k*k; i = i + 1) begin
            conv_acc = conv_acc + ($signed(window_buffer[i]) * $signed(current_weights[i]));
        end
        if (conv_acc != 0) begin
            conv_acc = conv_acc + (1 << (Q-1));
            conv_temp = conv_acc >>> Q;
        end else begin
            conv_temp = 0;
        end
    end

    // Next state logic
    always @(*) begin
        next_state = state;

        case (state)
            IDLE: begin
                if (en) next_state = LOAD;
            end
            
            LOAD: begin
                if (input_counter >= n*n - 1) begin
                    next_state = COMPUTE;
                end
            end
            
            PAD: begin
                next_state = COMPUTE;
            end
            
            COMPUTE: begin
                if (y_counter >= n_padded - k + 1) begin 
                    if (channel_counter >= OUT_CHANNELS - 1) begin
                        next_state = DONE;
                    end else begin
                        next_state = NEXT_CHANNEL;
                    end
                end
                else if (output_counter >= o*o*OUT_CHANNELS) begin
                    next_state = DONE;
                end
            end
            
            NEXT_CHANNEL: begin
                next_state = COMPUTE;
            end
            
            DONE: begin
                next_state = IDLE;
            end
        endcase
    end

    // State machine and control logic
    always @(posedge clk) begin
        if (rst) begin
            state <= IDLE;
            input_counter <= 0;
            output_counter <= 0;
            x_counter <= 0;
            y_counter <= 0;
            channel_counter <= 0;
            row_counter <= 0;
            valid_out <= 0;
            done <= 0;
            conv_out <= 0;
            channel_out <= 0;
            debug_first_outputs <= 1;
        end else if (en) begin
            state <= next_state;
            
            case (state)
                IDLE: begin
                    if (next_state == LOAD) begin
                        input_counter <= 0;
                        channel_counter <= 0;
                        output_counter <= 0;
                        x_counter <= 0;
                        y_counter <= 0;
                        row_counter <= 0;
                        done <= 0;
                        debug_first_outputs <= 1;
                    end
                end
                
                LOAD: begin
                    // Processing input data
                    if (input_counter < n*n) begin
                        input_counter <= input_counter + 1;
                    end
                    
                    x_counter <= x_counter + 1;
                    valid_out <= 0;
                    
                    if (x_counter == n-1) begin
                        x_counter <= 0;
                        y_counter <= y_counter + 1;
                        
                        if (row_counter < k) begin
                            row_counter <= row_counter + 1;
                        end
                    end
                    
                    if (input_counter >= n*n - 1) begin
                        x_counter <= 0;
                        y_counter <= 0;
                    end
                end
                
                PAD: begin
                    // Add padding 
                    valid_out <= 0;
                    x_counter <= 0;
                    y_counter <= 0;
                end
                
                COMPUTE: begin
                    if (x_counter < n_padded - k + 1 && y_counter < n_padded - k + 1) begin
                        if (x_counter % s == 0 && y_counter % s == 0) begin

                            conv_out <= conv_temp;
                            channel_out <= channel_counter;
                            valid_out <= 1;
                            
                            if (output_counter < o*o*OUT_CHANNELS) begin
                                output_counter <= output_counter + 1;
                            end
                        end else begin
                            valid_out <= 0;
                        end
                    end else begin
                        valid_out <= 0;
                    end
                    x_counter <= x_counter + 1;
                    if (x_counter >= n_padded - k) begin
                        x_counter <= 0;
                        y_counter <= y_counter + 1;
                    end

                    if (y_counter >= n_padded - k + 1) begin
                        if (channel_counter >= OUT_CHANNELS - 1) begin
                            state <= DONE;
                        end else begin
                            state <= NEXT_CHANNEL;
                        end
                    end
                end
                
                NEXT_CHANNEL: begin
                    if (channel_counter < OUT_CHANNELS-1) begin
                        channel_counter <= channel_counter + 1;
                    end
                    x_counter <= 0;
                    y_counter <= 0;
                    valid_out <= 0;
                end
                
                DONE: begin
                    done <= 1;
                    valid_out <= 0;
                end
            endcase
        end
    end

endmodule
