module batchnorm_accumulator #(
    parameter WIDTH = 16,
    parameter BATCH_SIZE = 10,
    parameter CHANNELS = 16
) (
    input wire clk,
    input wire rst,
    input wire en,
    input wire [WIDTH-1:0] x_in,
    input wire [4:0] channel_in,
    input wire valid_in,
    output reg [WIDTH-1:0] sum_out,
    output reg [WIDTH-1:0] sum_sq_out,
    output reg [4:0] channel_out,
    output reg valid_out,
    output reg done
);

    // Optimized counter widths for resource efficiency
    reg [$clog2(BATCH_SIZE+1):0] counter;
    reg [$clog2(CHANNELS)-1:0] current_channel;
    
    // Accumulators for each channel - optimized for block RAM inference
    (* ram_style = "block" *) reg [WIDTH-1:0] sum [0:CHANNELS-1];
    (* ram_style = "block" *) reg [WIDTH-1:0] sum_sq [0:CHANNELS-1];
    
    // Processing state - optimized encoding for minimal LUT usage
    reg [1:0] state;
    localparam [1:0] IDLE = 2'b00,
                     ACCUMULATE = 2'b01,
                     OUTPUT = 2'b10,
                     DONE = 2'b11;
            
    // Squared input (for variance calculation) - pipelined for timing
    reg [2*WIDTH-1:0] x_sq_reg;
    reg [WIDTH-1:0] x_in_reg;
    reg [4:0] channel_in_reg;
    reg valid_in_reg;

    // Bounds checking for synthesis safety
    wire [$clog2(CHANNELS)-1:0] safe_channel_in;
    wire [$clog2(CHANNELS)-1:0] safe_channel_in_reg;
    wire [$clog2(CHANNELS)-1:0] safe_counter;
    
    assign safe_channel_in = (channel_in < CHANNELS) ? channel_in[$clog2(CHANNELS)-1:0] : 0;
    assign safe_channel_in_reg = (channel_in_reg < CHANNELS) ? channel_in_reg[$clog2(CHANNELS)-1:0] : 0;
    assign safe_counter = (counter < CHANNELS) ? counter[$clog2(CHANNELS)-1:0] : 0;

    // Pipeline input stage for better timing
    always @(posedge clk) begin
        if (rst) begin
            x_sq_reg <= 0;
            x_in_reg <= 0;
            channel_in_reg <= 0;
            valid_in_reg <= 1'b0;
        end else begin
            x_in_reg <= x_in;
            channel_in_reg <= channel_in;
            valid_in_reg <= valid_in;
            // Calculate square with proper sizing
            x_sq_reg <= $signed(x_in) * $signed(x_in);
        end
    end
    
    // Initialize arrays for synthesis
    generate
        genvar i;
        for (i = 0; i < CHANNELS; i = i + 1) begin : init_sums
            initial begin
                sum[i] = 0;
                sum_sq[i] = 0;
            end
        end
    endgenerate
    
    // Main processing state machine - optimized for timing and resources
    always @(posedge clk) begin
        if (rst) begin
            state <= IDLE;
            counter <= 0;
            current_channel <= 0;
            valid_out <= 1'b0;
            done <= 1'b0;
            channel_out <= 0;
            sum_out <= 0;
            sum_sq_out <= 0;
        end else if (en) begin
            case (state)
                IDLE: begin
                    if (valid_in_reg) begin
                        state <= ACCUMULATE;
                        counter <= 1;
                        current_channel <= safe_channel_in_reg;
                        
                        // Add first input to accumulator with safe indexing
                        sum[safe_channel_in_reg] <= x_in_reg;
                        sum_sq[safe_channel_in_reg] <= x_sq_reg[WIDTH-1:0];
                        
                        valid_out <= 1'b0;
                        done <= 1'b0;
                    end
                end
                
                ACCUMULATE: begin
                    if (valid_in_reg) begin
                        // Add new input to appropriate channel accumulator with safe indexing
                        sum[safe_channel_in_reg] <= sum[safe_channel_in_reg] + x_in_reg;
                        sum_sq[safe_channel_in_reg] <= sum_sq[safe_channel_in_reg] + x_sq_reg[WIDTH-1:0];
                        
                        // Increment counter for current channel only
                        if (channel_in_reg == current_channel) begin
                            counter <= counter + 1'b1;
                        end
                        
                        // Check if we've collected enough samples
                        if ((counter >= (BATCH_SIZE-1)) && (channel_in_reg == current_channel)) begin
                            state <= OUTPUT;
                            counter <= 0;
                        end
                    end
                end
                
                OUTPUT: begin
                    // Output statistics for each channel sequentially
                    if (counter < CHANNELS) begin
                        sum_out <= sum[safe_counter];
                        sum_sq_out <= sum_sq[safe_counter];
                        channel_out <= counter[4:0]; // Ensure proper width
                        valid_out <= 1'b1;
                        counter <= counter + 1'b1;
                    end else begin
                        state <= DONE;
                        valid_out <= 1'b0;
                    end
                end
                
                DONE: begin
                    done <= 1'b1;
                    valid_out <= 1'b0;
                    
                    // Reset for next batch if new input arrives
                    if (valid_in_reg) begin
                        state <= ACCUMULATE;
                        counter <= 1;
                        current_channel <= safe_channel_in_reg;
                        
                        // Add first input to accumulator with safe indexing
                        sum[safe_channel_in_reg] <= x_in_reg;
                        sum_sq[safe_channel_in_reg] <= x_sq_reg[WIDTH-1:0];
                        
                        done <= 1'b0;
                    end
                end
                
                default: state <= IDLE; // Safety default
            endcase
        end
    end
    
    // Reset arrays using generate block for better synthesis
    generate
        for (i = 0; i < CHANNELS; i = i + 1) begin : reset_sums
            always @(posedge clk) begin
                if (rst) begin
                    sum[i] <= 0;
                    sum_sq[i] <= 0;
                end else if (state == IDLE && valid_in_reg) begin
                    // Clear accumulators when starting new batch
                    sum[i] <= 0;
                    sum_sq[i] <= 0;
                end
            end
        end
    endgenerate

endmodule