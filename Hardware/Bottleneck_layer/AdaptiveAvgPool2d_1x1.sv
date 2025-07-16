// SYNTHESIS-CLEAN AdaptiveAvgPool2d(1x1) - Global Average Pooling
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
    
    // Accumulators for each channel - synthesis optimized
    logic [ACC_WIDTH-1:0] channel_sum [CHANNELS-1:0];
    
    // Simple counters
    logic [$clog2(TOTAL_INPUTS):0] total_input_count;
    logic [$clog2(CHANNELS):0] output_count;
    
    // Intermediate calculation signals
    logic [$clog2(CHANNELS):0] channel_idx;
    logic [ACC_WIDTH-1:0] sum_val, avg_val, remainder;

    // Initialize channel accumulators with generate block for synthesis
    genvar i;
    generate
        for (i = 0; i < CHANNELS; i = i + 1) begin : gen_acc_init
            always_ff @(posedge clk) begin
                if (rst) begin
                    channel_sum[i] <= 0;
                end
            end
        end
    endgenerate

    always_ff @(posedge clk) begin
        if (rst) begin
            state <= IDLE;
            total_input_count <= 0;
            output_count <= 0;
            out_data <= 0;
            out_valid <= 0;
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
                    end
                end
                
                ACCUMULATING: begin
                    out_valid <= 0;
                    if (in_valid) begin
                        // Calculate channel index with bounds checking
                        channel_idx = total_input_count / TOTAL_PIXELS_PER_CHANNEL;
                        
                        if (channel_idx < CHANNELS) begin
                            channel_sum[channel_idx] <= channel_sum[channel_idx] + in_data;
                        end
                        
                        total_input_count <= total_input_count + 1;
                        
                        // Check if we've received all inputs
                        if (total_input_count >= TOTAL_INPUTS - 1) begin
                            state <= OUTPUTTING;
                            output_count <= 0;
                        end
                    end else begin
                        // If in_valid goes low, check if we have enough inputs to proceed
                        if (total_input_count >= TOTAL_INPUTS) begin
                            state <= OUTPUTTING;
                            output_count <= 0;
                        end
                        // Otherwise stay in ACCUMULATING and wait for more inputs
                    end
                end
                
                OUTPUTTING: begin
                    if (output_count < CHANNELS) begin
                        // Calculate average with rounding
                        sum_val = channel_sum[output_count];
                        avg_val = sum_val / TOTAL_PIXELS_PER_CHANNEL;
                        remainder = sum_val % TOTAL_PIXELS_PER_CHANNEL;
                        
                        // Add rounding: if remainder >= TOTAL_PIXELS_PER_CHANNEL/2, round up
                        if (remainder >= (TOTAL_PIXELS_PER_CHANNEL >> 1)) begin
                            avg_val = avg_val + 1;
                        end
                        
                        // Saturation to prevent overflow
                        if (avg_val > ((1 << DATA_WIDTH) - 1)) begin
                            out_data <= (1 << DATA_WIDTH) - 1;
                        end else begin
                            out_data <= avg_val[DATA_WIDTH-1:0];
                        end
                        
                        out_valid <= 1;
                        output_count <= output_count + 1;
                    end else begin
                        // Finished outputting all channels
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