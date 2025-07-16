module HSwish_first #(
    parameter dataWidth = 16,
    parameter fracWidth = 8
)
(
    input wire clk,
    input wire rst,
    input wire en,
    input [dataWidth-1:0] x,
    output reg [dataWidth-1:0] y,
    output reg valid
);

    // Fixed-point constants - optimized for synthesis
    localparam signed [dataWidth-1:0] THREE = 16'h0300;       // 3.0 in fixed point
    localparam signed [dataWidth-1:0] SIX = 16'h0600;         // 6.0 in fixed point
    localparam signed [dataWidth-1:0] ZERO = 16'h0000;        // 0.0 in fixed point
    
    // Pipeline registers for better timing
    reg signed [dataWidth-1:0] x_reg1, x_reg2, x_reg3, x_reg4;
    reg en_reg1, en_reg2, en_reg3, en_reg4;
    
    // Stage 1: Compute x + 3 and pipeline input
    reg signed [dataWidth-1:0] x_plus_3;
    
    // Stage 2: Compute ReLU6(x+3) and prepare for multiplication
    reg signed [dataWidth-1:0] relu6_x_plus_3;
    
    // Stage 3: Multiply and prepare for division
    reg signed [2*dataWidth-1:0] mul_result;
    
    // Stage 4: Division by 6
    reg signed [2*dataWidth-1:0] scaled_result;
    
    // Pipeline Stage 1: Input registration and x+3 computation
    always @(posedge clk) begin
        if (rst) begin
            x_reg1 <= 0;
            en_reg1 <= 1'b0;
            x_plus_3 <= 0;
        end else begin
            x_reg1 <= x;
            en_reg1 <= en;
            
            // Compute x + 3
            x_plus_3 <= $signed(x) + THREE;
        end
    end
    
    // Pipeline Stage 2: ReLU6 computation
    always @(posedge clk) begin
        if (rst) begin
            x_reg2 <= 0;
            en_reg2 <= 1'b0;
            relu6_x_plus_3 <= 0;
        end else begin
            x_reg2 <= x_reg1;
            en_reg2 <= en_reg1;
            
            // ReLU6(x+3) - clamp to range [0,6]
            if ($signed(x_plus_3) < ZERO) begin
                relu6_x_plus_3 <= ZERO;
            end else if ($signed(x_plus_3) > SIX) begin
                relu6_x_plus_3 <= SIX;
            end else begin
                relu6_x_plus_3 <= x_plus_3;
            end
        end
    end
    
    // Pipeline Stage 3: Multiplication
    always @(posedge clk) begin
        if (rst) begin
            x_reg3 <= 0;
            en_reg3 <= 1'b0;
            mul_result <= 0;
        end else begin
            x_reg3 <= x_reg2;
            en_reg3 <= en_reg2;
            
            // Multiply x * ReLU6(x+3)
            mul_result <= $signed(x_reg2) * $signed(relu6_x_plus_3);
        end
    end
    
    // Pipeline Stage 4: Scaling and division by 6
    always @(posedge clk) begin
        if (rst) begin
            x_reg4 <= 0;
            en_reg4 <= 1'b0;
            scaled_result <= 0;
        end else begin
            x_reg4 <= x_reg3;
            en_reg4 <= en_reg3;
            
            // Apply fixed-point scaling with rounding
            scaled_result <= (mul_result + (1 << (fracWidth-1))) >>> fracWidth;
        end
    end
    
    // Output Stage: Final division by 6 and saturation
    always @(posedge clk) begin
        if (rst) begin
            y <= 0;
            valid <= 1'b0;
        end else begin
            valid <= en_reg4;
            
            if (en_reg4) begin
                // Approximate division by 6 using: (x * 43691) >> 18
                // This gives approximately x/6 for the range of values we expect
                automatic reg signed [2*dataWidth-1:0] div_temp;
                div_temp = (scaled_result * 43691) >>> 18;
                
                // Saturation to prevent overflow
                if (div_temp > ((1 << (dataWidth-1)) - 1)) begin
                    y <= ((1 << (dataWidth-1)) - 1); // Max positive value
                end else if (div_temp < -(1 << (dataWidth-1))) begin
                    y <= -(1 << (dataWidth-1)); // Max negative value
                end else begin
                    y <= div_temp[dataWidth-1:0];
                end
            end
        end
    end
    
endmodule