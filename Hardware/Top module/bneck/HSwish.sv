// SYNTHESIS-CLEAN H-Swish activation function
module HSwish #(
    parameter N = 16,           // Data width
    parameter CHANNELS = 16     // Number of channels
) (
    input  logic clk,
    input  logic rst,
    
    // Input interface
    input  logic [N-1:0] data_in,
    input  logic [$clog2(CHANNELS)-1:0] channel_in,
    input  logic valid_in,
    
    // Output interface
    output logic [N-1:0] data_out,
    output logic [$clog2(CHANNELS)-1:0] channel_out,
    output logic valid_out
);

    // Use wider arithmetic for intermediate calculations
    localparam CALC_WIDTH = N + 8;
    
    // Pipeline registers
    logic [N-1:0] data_reg [0:2];
    logic [$clog2(CHANNELS)-1:0] channel_reg [0:2];
    logic valid_reg [0:2];
    
    // Intermediate calculation signals
    logic signed [CALC_WIDTH-1:0] x_plus_3;
    logic signed [CALC_WIDTH-1:0] relu6_result;
    logic signed [CALC_WIDTH*2-1:0] mult_result;
    logic signed [N-1:0] hswish_result;
    
    // Constants for H-Swish: x * ReLU6(x + 3) / 6
    localparam signed [N-1:0] THREE = 3 << 8;  // 3.0 in 8.8 fixed point
    localparam signed [N-1:0] SIX = 6 << 8;    // 6.0 in 8.8 fixed point

    always_ff @(posedge clk) begin
        if (rst) begin
            data_reg[0] <= {N{1'b0}};
            data_reg[1] <= {N{1'b0}};
            data_reg[2] <= {N{1'b0}};
            channel_reg[0] <= {$clog2(CHANNELS){1'b0}};
            channel_reg[1] <= {$clog2(CHANNELS){1'b0}};
            channel_reg[2] <= {$clog2(CHANNELS){1'b0}};
            valid_reg[0] <= 1'b0;
            valid_reg[1] <= 1'b0;
            valid_reg[2] <= 1'b0;
            x_plus_3 <= {CALC_WIDTH{1'b0}};
            relu6_result <= {CALC_WIDTH{1'b0}};
            mult_result <= {CALC_WIDTH*2{1'b0}};
            hswish_result <= {N{1'b0}};
            data_out <= {N{1'b0}};
            channel_out <= {$clog2(CHANNELS){1'b0}};
            valid_out <= 1'b0;
        end else begin
            // Stage 1: Input registration and x + 3 calculation
            if (valid_in) begin
                data_reg[0] <= data_in;
                channel_reg[0] <= channel_in;
                valid_reg[0] <= 1'b1;
                
                // Calculate x + 3
                x_plus_3 <= $signed(data_in) + $signed(THREE);
            end else begin
                valid_reg[0] <= 1'b0;
            end
            
            // Stage 2: ReLU6(x + 3) calculation
            if (valid_reg[0]) begin
                data_reg[1] <= data_reg[0];
                channel_reg[1] <= channel_reg[0];
                valid_reg[1] <= 1'b1;
                
                // ReLU6: clamp(x + 3, 0, 6)
                if (x_plus_3 <= 0) begin
                    relu6_result <= 0;
                end else if (x_plus_3 >= SIX) begin
                    relu6_result <= SIX;
                end else begin
                    relu6_result <= x_plus_3;
                end
            end else begin
                valid_reg[1] <= 1'b0;
            end
            
            // Stage 3: Multiplication x * ReLU6(x + 3)
            if (valid_reg[1]) begin
                data_reg[2] <= data_reg[1];
                channel_reg[2] <= channel_reg[1];
                valid_reg[2] <= 1'b1;
                
                // Multiply x * ReLU6(x + 3)
                mult_result <= $signed(data_reg[1]) * relu6_result;
            end else begin
                valid_reg[2] <= 1'b0;
            end
            
            // Output stage: Division by 6 and output
            if (valid_reg[2]) begin
                // Divide by 6 and scale appropriately
                logic signed [CALC_WIDTH*2-1:0] divided_result;
                divided_result = mult_result / SIX;
                
                // Scale down to output width with saturation
                if (divided_result > ((1 << (N-1)) - 1)) begin
                    hswish_result <= (1 << (N-1)) - 1;
                end else if (divided_result < (-(1 << (N-1)))) begin
                    hswish_result <= -(1 << (N-1));
                end else begin
                    hswish_result <= divided_result[N-1:0];
                end
                
                data_out <= hswish_result;
                channel_out <= channel_reg[2];
                valid_out <= 1'b1;
            end else begin
                data_out <= {N{1'b0}};
                channel_out <= {$clog2(CHANNELS){1'b0}};
                valid_out <= 1'b0;
            end
        end
    end

endmodule