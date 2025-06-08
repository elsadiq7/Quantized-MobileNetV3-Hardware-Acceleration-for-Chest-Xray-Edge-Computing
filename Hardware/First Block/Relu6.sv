module Relu6 #(
    parameter dataWidth = 16
) (
    input  signed [dataWidth-1:0] x,
    output logic  [dataWidth-1:0] y
);

    localparam [dataWidth-1:0] clipValue = 16'b0000_0110_0000_0000;  

    logic [dataWidth-1:0] maxValue;
    logic isNegative;

    logic [dataWidth-1:0] diff;
    logic isGreaterThanOrEqual6;

    always_comb begin
        // Step 1: Compute max(0, x)
        isNegative = x[dataWidth-1];  
        maxValue = isNegative ? {dataWidth{1'b0}} : x;  

        // Step 2: Compute min(maxValue, 6.0)
        diff = maxValue - clipValue;  
        isGreaterThanOrEqual6 = ~diff[dataWidth-1]; 

        y = isGreaterThanOrEqual6 ? clipValue : maxValue;
    end
endmodule