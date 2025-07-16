module Relu #(
    parameter N = 16,           // Data width
    parameter CHANNELS = 16     // Number of channels
) (
    input wire clk,
    input wire rst,
    
    // Input interface
    input wire [N-1:0] data_in,
    input wire [$clog2(CHANNELS)-1:0] channel_in,
    input wire valid_in,
    
    // Output interface
    output reg [N-1:0] data_out,
    output reg [$clog2(CHANNELS)-1:0] channel_out,
    output reg valid_out
);

    // Input validation to prevent X propagation
    wire [N-1:0] validated_data;
    wire [$clog2(CHANNELS)-1:0] validated_channel;
    wire validated_valid;
    
    assign validated_data = (^data_in === 1'bx) ? {N{1'b0}} : data_in;
    assign validated_channel = (^channel_in === 1'bx) ? {$clog2(CHANNELS){1'b0}} : channel_in;
    assign validated_valid = (valid_in === 1'bx) ? 1'b0 : valid_in;
    
    // Pipeline registers for better timing closure
    reg [N-1:0] data_reg;
    reg [$clog2(CHANNELS)-1:0] channel_reg;
    reg valid_reg;
    
    // Optimized ReLU computation: max(0, x)
    // For signed fixed-point: if MSB is 1 (negative), output 0, else output x
    always @(posedge clk) begin
        if (rst) begin
            // Synchronous reset for all outputs
            data_out <= {N{1'b0}};
            channel_out <= {$clog2(CHANNELS){1'b0}};
            valid_out <= 1'b0;
            
            // Reset pipeline registers
            data_reg <= {N{1'b0}};
            channel_reg <= {$clog2(CHANNELS){1'b0}};
            valid_reg <= 1'b0;
            
        end else begin
            // Pipeline stage 1: Input registration
            data_reg <= validated_data;
            channel_reg <= validated_channel;
            valid_reg <= validated_valid;
            
            // Pipeline stage 2: ReLU computation and output
            if (valid_reg) begin
                // ReLU: output 0 if input is negative (MSB = 1), else output input
                if (data_reg[N-1] == 1'b1) begin
                    data_out <= {N{1'b0}};  // Negative input -> 0
                end else begin
                    data_out <= data_reg;  // Positive/zero input -> pass through
                end
                
                channel_out <= channel_reg;
                valid_out <= 1'b1;
                
            end else begin
                // No valid input - clear outputs
                data_out <= {N{1'b0}};
                channel_out <= {$clog2(CHANNELS){1'b0}};
                valid_out <= 1'b0;
            end
        end
    end

endmodule 