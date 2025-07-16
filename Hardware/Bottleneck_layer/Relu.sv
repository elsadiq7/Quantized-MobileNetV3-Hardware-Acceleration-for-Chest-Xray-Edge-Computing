// SYNTHESIS-CLEAN ReLU activation function
module Relu #(
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

    // Simple pipeline for better timing
    logic [N-1:0] data_reg;
    logic [$clog2(CHANNELS)-1:0] channel_reg;
    logic valid_reg;

    always_ff @(posedge clk) begin
        if (rst) begin
            data_reg <= {N{1'b0}};
            channel_reg <= {$clog2(CHANNELS){1'b0}};
            valid_reg <= 1'b0;
            data_out <= {N{1'b0}};
            channel_out <= {$clog2(CHANNELS){1'b0}};
            valid_out <= 1'b0;
        end else begin
            // Stage 1: Input registration
            data_reg <= data_in;
            channel_reg <= channel_in;
            valid_reg <= valid_in;
            
            // Stage 2: ReLU computation and output
            if (valid_reg) begin
                data_out <= ($signed(data_reg) > 0) ? data_reg : {N{1'b0}};
                channel_out <= channel_reg;
                valid_out <= 1'b1;
            end else begin
                data_out <= {N{1'b0}};
                channel_out <= {$clog2(CHANNELS){1'b0}};
                valid_out <= 1'b0;
            end
        end
    end

endmodule 