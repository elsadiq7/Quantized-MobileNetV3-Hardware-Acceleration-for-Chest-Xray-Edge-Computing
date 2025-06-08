module HSwish #(
    parameter dataWidth = 16,
    parameter fracWidth = 8
)
(
    input [dataWidth-1:0] x,
    output [dataWidth-1:0] y
);

    localparam signed [dataWidth-1:0] THREE = 16'h0300;       
    localparam signed [dataWidth-1:0] SIX = 16'h0600;         
    localparam signed [dataWidth-1:0] ZERO = 16'h0000;        
    localparam signed [dataWidth-1:0] SIX_FP = 16'h0600;       
    
    // Intermediate values
    reg signed [dataWidth-1:0] x_plus_3;              
    reg signed [dataWidth-1:0] relu6_x_plus_3;       
    reg signed [2*dataWidth-1:0] mul1;              
    reg signed [dataWidth-1:0] div6;                  
    
    // Step 1: x + 3
    always @(*) begin
        x_plus_3 = $signed(x) + THREE;
    end
    
    // Step 2: ReLU6(x+3) - clamp to range [0,6]
    always @(*) begin
        if ($signed(x_plus_3) < ZERO)
            relu6_x_plus_3 = ZERO;
        else if ($signed(x_plus_3) > SIX)
            relu6_x_plus_3 = SIX;
        else
            relu6_x_plus_3 = x_plus_3;
    end
    
    // Step 3: Multiply by x
    always @(*) begin
        mul1 = $signed(x) * $signed(relu6_x_plus_3);
    end
    
    // Step 4: Divide by 6 
    always @(*) begin
        // Fixed-point division handling with rounding
        div6 = ($signed(mul1) + (1 << (fracWidth-1))) >>> fracWidth;
        
        // Division by 6
        div6 = ($signed(div6) << fracWidth) / SIX_FP;
    end
    
    assign y = div6;
    
endmodule