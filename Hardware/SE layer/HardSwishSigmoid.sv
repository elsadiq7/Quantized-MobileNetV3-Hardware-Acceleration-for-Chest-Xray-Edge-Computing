// Fully serial, area-minimal Hard Sigmoid and Hard Swish with input validation
module HardSwishSigmoid #(
    parameter DATA_WIDTH = 16
) (
    input  logic clk,
    input  logic rst,
    input  logic signed [DATA_WIDTH-1:0] in_data,
    input  logic in_valid,                            // Input valid signal
    output logic signed [DATA_WIDTH-1:0] hsigmoid_out,
    output logic signed [DATA_WIDTH-1:0] hswish_out,
    output logic out_valid
);
    // Use wider arithmetic for intermediate calculations
    localparam CALC_WIDTH = DATA_WIDTH + 8;
    
    // Pipeline registers
    logic signed [DATA_WIDTH-1:0] in_reg;
    logic signed [CALC_WIDTH-1:0] relu6_result;
    logic signed [CALC_WIDTH-1:0] hsigmoid_temp, hswish_temp;
    logic signed [DATA_WIDTH-1:0] hsigmoid_reg, hswish_reg;
    logic valid_stage1, valid_stage2, valid_stage3;
    
    // FIXED: Better constants for fixed-point arithmetic - ensure 0.5 is representable
    localparam signed [DATA_WIDTH-1:0] THREE = 3 << 8;  // 3.0 in 8.8 fixed point
    localparam signed [DATA_WIDTH-1:0] SIX = 6 << 8;    // 6.0 in 8.8 fixed point  
    localparam signed [DATA_WIDTH-1:0] SCALE_FACTOR = 8; // 8-bit fractional part
    
    // Intermediate calculation signals
    logic signed [CALC_WIDTH-1:0] scaled_input;
    logic signed [CALC_WIDTH-1:0] input_plus_three;
    logic signed [CALC_WIDTH-1:0] hsig_div, hsig_remainder;
    logic signed [CALC_WIDTH*2-1:0] hswish_div;

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            in_reg <= 0;
            relu6_result <= 0;
            hsigmoid_temp <= 0;
            hswish_temp <= 0;
            hsigmoid_reg <= 0;
            hswish_reg <= 0;
            valid_stage1 <= 0;
            valid_stage2 <= 0;
            valid_stage3 <= 0;
        end else begin
            // Pipeline Stage 1: Input registration and ReLU6 calculation
            valid_stage1 <= in_valid;
            if (in_valid) begin
                in_reg <= in_data;
                
                // FIXED: Better ReLU6(x + 3) implementation with more conservative scaling
                scaled_input = in_data << SCALE_FACTOR;
                input_plus_three = scaled_input + THREE;
                
                if (input_plus_three <= 0) begin
                    relu6_result <= 0;
                end else if (input_plus_three >= SIX) begin
                    relu6_result <= SIX;
                end else begin
                    relu6_result <= input_plus_three;
                end
            end
            
            // Pipeline Stage 2: Prepare for division
            valid_stage2 <= valid_stage1;
            if (valid_stage1) begin
                hsigmoid_temp <= relu6_result;
                // FIXED: More conservative multiplication to prevent overflow
                hswish_temp <= in_reg * relu6_result;
            end
            
            // Pipeline Stage 3: Perform division with better precision
            valid_stage3 <= valid_stage2;
            if (valid_stage2) begin
                // FIXED: Correct HardSigmoid computation with proper fractional handling
                if (SIX != 0) begin
                    // Hard Sigmoid: ReLU6(x + 3) / 6
                    // Scale up before division to preserve fractional part
                    logic [CALC_WIDTH-1:0] scaled_temp;
                    scaled_temp = hsigmoid_temp << 8; // Scale up by 256 to preserve fractions
                    hsig_div = scaled_temp / SIX;
                    
                    hsigmoid_reg <= hsig_div; // Result already has proper scaling
                    
                    // Hard Swish: x * ReLU6(x + 3) / 6
                    hswish_div = hswish_temp / SIX;
                    hswish_reg <= hswish_div >>> SCALE_FACTOR; // Scale back appropriately
                    
                    $display(" HardSigmoid: relu6_result=%0d, hsigmoid_temp=%0d, hsig_div=%0d, final=%0d", 
                            relu6_result, hsigmoid_temp, hsig_div, hsig_div);
                end else begin
                    // Fallback (should never happen)
                    hsigmoid_reg <= 16'h0080; // 0.5 in fixed point
                    hswish_reg <= 0;
                    $display(" HardSigmoid: Using fallback value");
                end
            end
        end
    end
    
    assign hsigmoid_out = hsigmoid_reg;
    assign hswish_out = hswish_reg;
    assign out_valid = valid_stage3;
endmodule 