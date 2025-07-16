module pointwise_conv #(
    parameter N = 16,           // Data width
    parameter Q = 8,            // Fractional bits
    parameter IN_CHANNELS = 16, // Input channels
    parameter OUT_CHANNELS = 16,// Output channels
    parameter FEATURE_SIZE = 112, // Feature map size
    parameter PARALLELISM = 4   // Process 4 channels in parallel
) (
    input wire clk,
    input wire rst,
    input wire en,
    
    // Input interface
    input wire [N-1:0] data_in,
    input wire [$clog2(IN_CHANNELS)-1:0] channel_in,
    input wire valid_in,
    
    // Weight interface - simplified
    input wire [(IN_CHANNELS*OUT_CHANNELS*N)-1:0] weights,
    
    // Output interface
    output reg [N-1:0] data_out,
    output reg [$clog2(OUT_CHANNELS)-1:0] channel_out,
    output reg valid_out,
    output reg done
);

    // Use block RAM for weight storage
    (* ram_style = "block" *) reg [N-1:0] weight_memory [0:IN_CHANNELS*OUT_CHANNELS-1];
    
    // Simplified state machine
    typedef enum logic {
        IDLE,
        PROCESSING
    } state_t;
    
    state_t state;
    
    // Counters with reduced width where possible
    reg [$clog2(OUT_CHANNELS)-1:0] out_ch_count;
    reg [$clog2(FEATURE_SIZE*FEATURE_SIZE)-1:0] pixel_count;
    reg [$clog2(OUT_CHANNELS)-1:0] channel_count;
    
    // DSP48-optimized MAC pipeline
    reg signed [N-1:0] mult_a;
    reg signed [N-1:0] mult_b;
    wire signed [2*N-1:0] mult_result = mult_a * mult_b;
    reg signed [2*N-1:0] mult_reg;
    
    // Quantization
    wire signed [N-1:0] quantized_result;
    assign quantized_result = (^mult_reg[2*N-1:N+Q] == 1'b0 || &mult_reg[2*N-1:N+Q] == 1'b1) ? 
                             mult_reg[N+Q-1:Q] : 
                             {mult_reg[2*N-1], {N-1{~mult_reg[2*N-1]}}};

    // Input validation
    wire [N-1:0] validated_data_in = (valid_in) ? data_in : {N{1'b0}};
    
    // Weight loading at startup
    integer i;
    initial begin
        for (i = 0; i < IN_CHANNELS * OUT_CHANNELS; i = i + 1) begin
            weight_memory[i] = weights[i*N +: N];
        end
    end

    always @(posedge clk) begin
        if (rst) begin
            state <= IDLE;
            data_out <= 0;
            channel_out <= 0;
            valid_out <= 0;
            done <= 0;
            out_ch_count <= 0;
            pixel_count <= 0;
            channel_count <= 0;
            mult_a <= 0;
            mult_b <= 0;
            mult_reg <= 0;
        end else begin
            // Default outputs
            valid_out <= 0;
            
            case (state)
                IDLE: begin
                    if (en) begin
                        state <= PROCESSING;
                    end
                end
                
                PROCESSING: begin
                    if (valid_in) begin
                        // Pipeline stage 1: Multiplication
                        mult_a <= $signed(validated_data_in);
                        mult_b <= $signed(weight_memory[channel_in * OUT_CHANNELS + out_ch_count]);
                        
                        // Pipeline stage 2: Register multiplication result
                        mult_reg <= mult_result;
                        
                        // Pipeline stage 3: Output quantized result
                        data_out <= quantized_result;
                        channel_out <= out_ch_count;
                        valid_out <= 1;
                        
                        // Update counters
                        if (out_ch_count == OUT_CHANNELS-1) begin
                            out_ch_count <= 0;
                            if (pixel_count == FEATURE_SIZE*FEATURE_SIZE-1) begin
                                pixel_count <= 0;
                                done <= 1;
                                state <= IDLE;
                            end else begin
                                pixel_count <= pixel_count + 1;
                            end
                        end else begin
                            out_ch_count <= out_ch_count + 1;
                        end
                    end
                end
            endcase
        end
    end

endmodule