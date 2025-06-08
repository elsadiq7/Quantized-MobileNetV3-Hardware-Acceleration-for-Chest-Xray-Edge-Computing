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

    // Counters and state for batch processing
    reg [$clog2(BATCH_SIZE):0] counter;
    reg [4:0] current_channel;
    
    // Accumulators for each channel
    reg [WIDTH-1:0] sum [0:CHANNELS-1];
    reg [WIDTH-1:0] sum_sq [0:CHANNELS-1];
    
    // Processing state
    reg [1:0] state;
    localparam  IDLE = 2'b00,
                ACCUMULATE = 2'b01,
                OUTPUT = 2'b10,
                DONE = 2'b11;
            
    // Squared input (for variance calculation)
    reg [2*WIDTH-1:0] x_sq;

    // Calculate square of input (needed for variance)
    always @(*) begin
        x_sq = x_in * x_in;
    end
    
    // Main processing state machine
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // Reset all state variables and accumulators
            state <= IDLE;
            counter <= 0;
            current_channel <= 0;
            valid_out <= 0;
            done <= 0;
            channel_out <= 0;
            
            // Reset accumulators for all channels
            for (int i = 0; i < CHANNELS; i++) begin
                sum[i] <= 0;
                sum_sq[i] <= 0;
            end
        end else if (en) begin
            case (state)
                IDLE: begin
                    // Start processing when valid input arrives
                    if (valid_in) begin
                        state <= ACCUMULATE;
                        counter <= 1;
                        current_channel <= channel_in;
                        
                        // Initialize the accumulator
                        for (int i = 0; i < CHANNELS; i++) begin
                            sum[i] <= 0;
                            sum_sq[i] <= 0;
                        end
                        
                        // Add first input to accumulator
                        if (channel_in < CHANNELS) begin
                            sum[channel_in] <= x_in;
                            sum_sq[channel_in] <= x_sq[WIDTH-1:0];
                        end
                        
                        valid_out <= 0;
                        done <= 0;
                    end
                end
                
                ACCUMULATE: begin
                    if (valid_in) begin
                        // Add new input to appropriate channel accumulator
                        if (channel_in < CHANNELS) begin
                            sum[channel_in] <= sum[channel_in] + x_in;
                            sum_sq[channel_in] <= sum_sq[channel_in] + x_sq[WIDTH-1:0];
                        end
                        
                        // Increment counter
                        if (channel_in == current_channel) begin
                            counter <= counter + 1;
                        end
                        
                        // If we've collected enough samples, output results
                        if (counter >= BATCH_SIZE-1 && channel_in == current_channel) begin
                            state <= OUTPUT;
                            counter <= 0;
                        end
                    end
                end
                
                OUTPUT: begin
                    // Output statistics for each channel
                    if (counter < CHANNELS) begin
                        sum_out <= sum[counter];
                        sum_sq_out <= sum_sq[counter];
                        channel_out <= counter;
                        valid_out <= 1;
                        counter <= counter + 1;
                    end else begin
                        // All channels output, go to DONE
                        state <= DONE;
                        valid_out <= 0;
                    end
                end
                
                DONE: begin
                    // Signal completion
                    done <= 1;
                    valid_out <= 0;
                    
                    // Reset for next batch if new input arrives
                    if (valid_in) begin
                        state <= ACCUMULATE;
                        counter <= 1;
                        current_channel <= channel_in;
                        
                        // Initialize the accumulator
                        for (int i = 0; i < CHANNELS; i++) begin
                            sum[i] <= 0;
                            sum_sq[i] <= 0;
                        end
                        
                        // Add first input to accumulator
                        if (channel_in < CHANNELS) begin
                            sum[channel_in] <= x_in;
                            sum_sq[channel_in] <= x_sq[WIDTH-1:0];
                        end
                        
                        done <= 0;
                    end
                end
            endcase
        end
    end

endmodule