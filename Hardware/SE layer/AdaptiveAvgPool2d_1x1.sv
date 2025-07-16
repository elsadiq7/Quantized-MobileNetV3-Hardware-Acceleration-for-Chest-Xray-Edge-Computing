// Area-efficient serial AdaptiveAvgPool2d(1x1) - Global Average Pooling
module AdaptiveAvgPool2d_1x1 #(
    parameter DATA_WIDTH = 16,
    parameter IN_HEIGHT = 8,
    parameter IN_WIDTH = 8,
    parameter CHANNELS = 16
) (
    input  logic clk,
    input  logic rst,
    input  logic [DATA_WIDTH-1:0] in_data,
    input  logic in_valid,                    // Input data valid signal
    output logic [DATA_WIDTH-1:0] out_data,
    output logic out_valid
);
    // Calculate constants
    localparam TOTAL_PIXELS_PER_CHANNEL = IN_HEIGHT * IN_WIDTH;
    localparam TOTAL_INPUTS = CHANNELS * TOTAL_PIXELS_PER_CHANNEL;
    
    // Use wider accumulator to prevent overflow
    localparam ACC_WIDTH = DATA_WIDTH + $clog2(TOTAL_PIXELS_PER_CHANNEL) + 2;
    
    // State machine
    typedef enum logic [1:0] {
        IDLE,
        ACCUMULATING,
        OUTPUTTING
    } state_t;
    state_t state;
    
    // Accumulators for each channel
    logic [ACC_WIDTH-1:0] channel_sum [CHANNELS-1:0];
    
    // Simple counters
    logic [$clog2(TOTAL_INPUTS):0] total_input_count;
    logic [$clog2(CHANNELS):0] output_count;
    
    // Intermediate calculation signals
    logic [$clog2(CHANNELS):0] channel_idx;
    logic [ACC_WIDTH-1:0] sum_val, avg_val, remainder;
    
    integer i;

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= IDLE;
            total_input_count <= 0;
            output_count <= 0;
            out_data <= 0;
            out_valid <= 0;
            
            // Clear all accumulators
            for (i = 0; i < CHANNELS; i = i + 1) begin
                channel_sum[i] <= 0;
            end
            
        end else begin
            case (state)
                IDLE: begin
                    out_valid <= 0;
                    if (in_valid) begin
                        // Start accumulation and process first sample immediately
                        state <= ACCUMULATING;
                        total_input_count <= 1;  // Count this first sample
                        output_count <= 0;
                        
                        // Process first sample immediately (channel 0)
                        channel_sum[0] <= in_data;
                        
                        // Clear remaining accumulators
                        for (i = 1; i < CHANNELS; i = i + 1) begin
                            channel_sum[i] <= 0;
                        end
                    end
                end
                
                ACCUMULATING: begin
                    out_valid <= 0;
                    if (in_valid) begin
                        // FIXED: Better channel index calculation with bounds checking
                        channel_idx = total_input_count / TOTAL_PIXELS_PER_CHANNEL;
                        
                        if (channel_idx < CHANNELS) begin
                            channel_sum[channel_idx] <= channel_sum[channel_idx] + in_data;
                            
                            // Debug for first and last few inputs
                            if (total_input_count < 5 || total_input_count >= TOTAL_INPUTS - 5) begin
                                $display(" AdaptiveAvgPool2d: input[%0d] = %0d for channel[%0d], sum=%0d", 
                                        total_input_count, in_data, channel_idx, channel_sum[channel_idx] + in_data);
                            end
                        end
                        
                        total_input_count <= total_input_count + 1;
                        
                        // Check if we've received all inputs
                        if (total_input_count >= TOTAL_INPUTS - 1) begin
                            state <= OUTPUTTING;
                            output_count <= 0;
                            $display(" AdaptiveAvgPool2d: All %0d inputs received, starting output phase", TOTAL_INPUTS);
                        end
                    end else begin
                        // FIXED: If in_valid goes low, check if we have enough inputs to proceed
                        if (total_input_count >= TOTAL_INPUTS) begin
                            state <= OUTPUTTING;
                            output_count <= 0;
                            $display(" AdaptiveAvgPool2d: Enough inputs (%0d), starting output phase", total_input_count);
                        end
                        // Otherwise stay in ACCUMULATING and wait for more inputs
                    end
                end
                
                OUTPUTTING: begin
                    if (output_count < CHANNELS) begin
                        // FIXED: Better average calculation with rounding
                        sum_val = channel_sum[output_count];
                        avg_val = sum_val / TOTAL_PIXELS_PER_CHANNEL;
                        remainder = sum_val % TOTAL_PIXELS_PER_CHANNEL;
                        
                        // Add rounding: if remainder >= TOTAL_PIXELS_PER_CHANNEL/2, round up
                        if (remainder >= (TOTAL_PIXELS_PER_CHANNEL >> 1)) begin
                            avg_val = avg_val + 1;
                        end
                        
                        // FIXED: Saturation to prevent overflow
                        if (avg_val > ((1 << DATA_WIDTH) - 1)) begin
                            out_data <= (1 << DATA_WIDTH) - 1;
                        end else begin
                            out_data <= avg_val[DATA_WIDTH-1:0];
                        end
                        
                        $display(" AdaptiveAvgPool2d: Output channel %0d = %0d (sum=%0d, avg=%0d)", 
                                output_count, avg_val[DATA_WIDTH-1:0], sum_val, avg_val);
                        out_valid <= 1;
                        output_count <= output_count + 1;
                        
                        // FIXED: Check if this is the last channel and ensure proper completion
                        if (output_count >= CHANNELS - 1) begin
                            $display(" AdaptiveAvgPool2d: Last channel %0d output, will complete next cycle", output_count);
                        end
                    end else begin
                        // Finished outputting all channels
                        $display(" AdaptiveAvgPool2d: All %0d channels output complete", CHANNELS);
                        out_valid <= 0;
                        state <= IDLE;
                    end
                end
                
                default: begin
                    state <= IDLE;
                    out_valid <= 0;
                end
            endcase
        end
    end
endmodule 