module Relu6 #(
    parameter dataWidth = 16,
    parameter fracWidth = 8,
    parameter PIPELINE = 0  // 0 = combinational, 1 = pipelined
) (
    input wire clk,          // Clock (only used if PIPELINE = 1)
    input wire rst,          // Reset (only used if PIPELINE = 1)
    input wire en,           // Enable (only used if PIPELINE = 1)
    input signed [dataWidth-1:0] x,
    output logic [dataWidth-1:0] y,
    output logic valid       // Valid signal (only used if PIPELINE = 1)
);

    // Optimized constants for synthesis
    localparam signed [dataWidth-1:0] SIX_FP = (6 << fracWidth);  // 6.0 in fixed point
    localparam signed [dataWidth-1:0] ZERO = {dataWidth{1'b0}};   // 0.0 in fixed point
    
    // Internal signals for computation
    logic signed [dataWidth-1:0] max_zero_result;
    logic signed [dataWidth-1:0] final_result;
    logic is_negative;
    logic is_greater_than_six;
    
    // Optimized comparison logic
    assign is_negative = x[dataWidth-1];  // MSB indicates sign
    assign is_greater_than_six = (x > SIX_FP);
    
    // Step 1: max(0, x) - optimized for synthesis
    assign max_zero_result = is_negative ? ZERO : x;
    
    // Step 2: min(max_zero_result, 6) - optimized for synthesis  
    assign final_result = is_greater_than_six ? SIX_FP : max_zero_result;
    
    generate
        if (PIPELINE == 1) begin : pipelined_implementation
            // Pipelined version for timing-critical paths
            reg signed [dataWidth-1:0] x_reg;
            reg signed [dataWidth-1:0] max_zero_reg;
            reg signed [dataWidth-1:0] y_reg;
            reg en_reg1, en_reg2;
            reg valid_reg;
            
            // Stage 1: Input registration and max(0, x)
            always @(posedge clk) begin
                if (rst) begin
                    x_reg <= 0;
                    max_zero_reg <= 0;
                    en_reg1 <= 1'b0;
                end else begin
                    x_reg <= x;
                    en_reg1 <= en;
                    max_zero_reg <= is_negative ? ZERO : x;
                end
            end
            
            // Stage 2: min(max_zero_result, 6) and output
            always @(posedge clk) begin
                if (rst) begin
                    y_reg <= 0;
                    en_reg2 <= 1'b0;
                    valid_reg <= 1'b0;
                end else begin
                    en_reg2 <= en_reg1;
                    valid_reg <= en_reg2;
                    
                    if (en_reg1) begin
                        if (max_zero_reg > SIX_FP) begin
                            y_reg <= SIX_FP;
                        end else begin
                            y_reg <= max_zero_reg;
                        end
                    end
                end
            end
            
            assign y = y_reg;
            assign valid = valid_reg;
            
        end else begin : combinational_implementation
            // Combinational version for low-latency paths
            assign y = final_result;
            assign valid = 1'b1;  // Always valid in combinational mode
        end
    endgenerate

endmodule