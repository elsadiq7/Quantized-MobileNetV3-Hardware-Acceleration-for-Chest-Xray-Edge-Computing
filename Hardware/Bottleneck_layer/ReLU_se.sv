// SYNTHESIS-CLEAN ReLU activation for SE module
module ReLU_se #(
    parameter DATA_WIDTH = 16
) (
    input  logic clk,
    input  logic rst,
    input  logic [DATA_WIDTH-1:0] in_data,
    input  logic in_valid,
    output logic [DATA_WIDTH-1:0] out_data,
    output logic out_valid
);

    // Simple pipeline for better timing
    logic [DATA_WIDTH-1:0] data_reg;
    logic valid_reg;

    always_ff @(posedge clk) begin
        if (rst) begin
            data_reg <= {DATA_WIDTH{1'b0}};
            valid_reg <= 1'b0;
            out_data <= {DATA_WIDTH{1'b0}};
            out_valid <= 1'b0;
        end else begin
            // Stage 1: Input registration
            data_reg <= in_data;
            valid_reg <= in_valid;
            
            // Stage 2: ReLU computation and output
            if (valid_reg) begin
                out_data <= ($signed(data_reg) > 0) ? data_reg : {DATA_WIDTH{1'b0}};
                out_valid <= 1'b1;
            end else begin
                out_data <= {DATA_WIDTH{1'b0}};
                out_valid <= 1'b0;
            end
        end
    end

endmodule