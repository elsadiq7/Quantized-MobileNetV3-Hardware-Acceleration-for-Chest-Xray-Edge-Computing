module linear_external_weights #(
    parameter WIDTH = 16,
    parameter FRAC = 8,
    parameter IN_FEATURES = 64,
    parameter OUT_FEATURES = 128,
    parameter FEATURE_SIZE = 7
)(
    input wire clk,
    input wire rst,
    input wire en,
    
    // Input features (collected from previous layer)
    input wire signed [WIDTH-1:0] feature_in [0:IN_FEATURES-1],
    input wire valid_in,
    
    // Weight memory interface - OPTIMIZED: External access only for large weights
    output reg [$clog2(IN_FEATURES*OUT_FEATURES)-1:0] weight_addr,
    output reg weight_req,
    input wire signed [WIDTH-1:0] weight_data,
    input wire weight_valid,
    
    // Bias memory (small enough for internal storage)
    input wire signed [WIDTH-1:0] bias_data [0:OUT_FEATURES-1],
    
    // Output
    output reg signed [WIDTH-1:0] data_out [0:OUT_FEATURES-1],
    output reg valid_out
);

    // OPTIMIZED: State machine for sequential processing
    typedef enum logic [2:0] {
        IDLE,
        LOAD_WEIGHTS,
        COMPUTE,
        ACCUMULATE,
        OUTPUT_READY
    } linear_state_t;
    
    linear_state_t state;
    
    // OPTIMIZED: Reduced internal storage
    reg [$clog2(OUT_FEATURES)-1:0] output_idx;
    reg [$clog2(IN_FEATURES)-1:0] input_idx;
    reg signed [WIDTH*2-1:0] accumulator;  // Single accumulator instead of array
    reg signed [WIDTH-1:0] current_weight;
    reg signed [WIDTH-1:0] feature_reg [0:IN_FEATURES-1];  // Input feature buffer
    
    // OPTIMIZED: Single DSP48 for all multiplications (resource sharing)
    wire signed [WIDTH*2-1:0] mult_result;
    assign mult_result = feature_reg[input_idx] * current_weight;
    
    always @(posedge clk) begin
        if (rst) begin
            state <= IDLE;
            output_idx <= 0;
            input_idx <= 0;
            accumulator <= 0;
            weight_addr <= 0;
            weight_req <= 1'b0;
            valid_out <= 1'b0;
            current_weight <= 0;
            
            // Reset output array
            for (int i = 0; i < OUT_FEATURES; i++) begin
                data_out[i] <= 0;
            end
            
        end else if (en) begin
            case (state)
                IDLE: begin
                    if (valid_in) begin
                        // Copy input features to internal buffer
                        for (int i = 0; i < IN_FEATURES; i++) begin
                            feature_reg[i] <= feature_in[i];
                        end
                        state <= LOAD_WEIGHTS;
                        output_idx <= 0;
                        input_idx <= 0;
                        accumulator <= 0;
                        weight_req <= 1'b1;
                        weight_addr <= 0;
                    end
                end
                
                LOAD_WEIGHTS: begin
                    if (weight_valid) begin
                        current_weight <= weight_data;
                        state <= COMPUTE;
                        weight_req <= 1'b0;
                    end
                end
                
                COMPUTE: begin
                    // OPTIMIZED: Sequential multiply-accumulate
                    accumulator <= accumulator + mult_result;
                    
                    if (input_idx < IN_FEATURES - 1) begin
                        input_idx <= input_idx + 1;
                        weight_addr <= output_idx * IN_FEATURES + input_idx + 1;
                        weight_req <= 1'b1;
                        state <= LOAD_WEIGHTS;
                    end else begin
                        state <= ACCUMULATE;
                    end
                end
                
                ACCUMULATE: begin
                    // Add bias and store result
                    data_out[output_idx] <= accumulator[WIDTH+FRAC-1:FRAC] + bias_data[output_idx];
                    
                    if (output_idx < OUT_FEATURES - 1) begin
                        output_idx <= output_idx + 1;
                        input_idx <= 0;
                        accumulator <= 0;
                        weight_addr <= (output_idx + 1) * IN_FEATURES;
                        weight_req <= 1'b1;
                        state <= LOAD_WEIGHTS;
                    end else begin
                        state <= OUTPUT_READY;
                        valid_out <= 1'b1;
                    end
                end
                
                OUTPUT_READY: begin
                    valid_out <= 1'b1;
                    if (!valid_in) begin  // Wait for consumer to read
                        state <= IDLE;
                        valid_out <= 1'b0;
                    end
                end
                
                default: state <= IDLE;
            endcase
        end
    end

endmodule 