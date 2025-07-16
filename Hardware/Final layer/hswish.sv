/*
    Hard Swish (h-swish) activation function.
    Formula: y = x * ReLU6(x + 3) / 6
*/
module hswish #(
    parameter WIDTH = 16,
    parameter FRAC = 8
) (
    input wire clk,
    input wire rst,
    input wire en,
    input wire signed [WIDTH-1:0] data_in,
    input wire valid_in,
    output reg signed [WIDTH-1:0] data_out,
    output reg valid_out
);

    // Constants in fixed-point Q{WIDTH}.{FRAC} format
    localparam signed [WIDTH-1:0] THREE = 3 << FRAC;
    localparam signed [WIDTH-1:0] SIX = 6 << FRAC;
    localparam signed [WIDTH-1:0] ZERO = 0;

    // Pipeline registers for a 4-stage pipeline
    reg signed [WIDTH-1:0] data_reg [0:3];
    reg valid_reg [0:3];

    // Intermediate values
    wire signed [WIDTH-1:0] x_plus_3 = data_reg[0] + THREE;
    wire signed [WIDTH-1:0] relu6_val;
    wire signed [2*WIDTH-1:0] product;
    localparam RECIPROCAL_OF_6 = 10923; // Q0.16 representation of 1/6

    // ReLU6: min(max(val, 0), 6)
    assign relu6_val = (x_plus_3 < ZERO) ? ZERO : (x_plus_3 > SIX) ? SIX : x_plus_3;

    // Multiplication: x * relu6_val
    assign product = data_reg[1] * relu6_val;

    // Division by 6
    wire signed [2*WIDTH-1:0] precise_div_by_6 = (product * RECIPROCAL_OF_6) >>> 16;

    always @(posedge clk) begin
        if (rst) begin
            for (int i = 0; i < 4; i++) begin
                data_reg[i] <= ZERO;
                valid_reg[i] <= 1'b0;
            end
            data_out <= ZERO;
            valid_out <= 1'b0;
        end else if (en) begin
            // Pipeline Stage 0: Input registration
            data_reg[0] <= data_in;
            valid_reg[0] <= valid_in;

            // Pipeline Stage 1: Delay for relu6_val calculation
            data_reg[1] <= data_reg[0];
            valid_reg[1] <= valid_reg[0];

            // Pipeline Stage 2: Delay for product calculation
            data_reg[2] <= data_reg[1];
            valid_reg[2] <= valid_reg[1];

            // Pipeline Stage 3: Register intermediate result and valid
            data_reg[3] <= precise_div_by_6 >>> FRAC;
            valid_reg[3] <= valid_reg[2];

            // Final output assignment
            data_out <= data_reg[3];
            valid_out <= valid_reg[3];
        end
    end

endmodule
