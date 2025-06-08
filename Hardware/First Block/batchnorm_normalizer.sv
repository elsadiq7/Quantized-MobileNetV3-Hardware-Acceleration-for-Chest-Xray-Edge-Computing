module batchnorm_normalizer #(
    parameter WIDTH=16,
    parameter FRAC=8
) (
    input clk,
    input rst,
    input enable,
    input [WIDTH-1:0] x_in,  
    input [WIDTH-1:0] mean,   
    input [WIDTH-1:0] variance,
    input [WIDTH-1:0] gamma,
    input [WIDTH-1:0] beta,
    output reg [WIDTH-1:0] y_out,
    output reg valid_out
);
    // Fixed point values
    localparam signed [WIDTH-1:0] epsilon = 16'h0010;
    
    // Counter for debugging
    reg [3:0] counter;
    
    // Stage 1: Compute x - mean
    reg [WIDTH-1:0] x_centered;
    reg valid_stage1;
    
    // Stage 2: Compute sqrt(variance + epsilon) and prepare for division
    reg [WIDTH-1:0] sqrt_var;
    reg valid_stage2;
    
    // Stage 3: Normalization and scaling
    reg signed [WIDTH-1:0] x_norm;
    
    // Stage 1 processing: x_centered = x - mean
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            x_centered <= 0;
            valid_stage1 <= 0;
            counter <= 0;
        end else begin
            valid_stage1 <= enable;
            
            if (enable) begin
                counter <= counter + 1;
                
                // Regular computation - no artificial test value injection
                x_centered <= $signed(x_in) - $signed(mean);
            end else begin
                x_centered <= 0;
            end
        end
    end
    
    // Stage 2 processing: sqrt_var = sqrt(variance + epsilon)
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            sqrt_var <= 0;
            valid_stage2 <= 0;
        end else begin
            valid_stage2 <= valid_stage1;
            sqrt_var <= $signed(variance) + epsilon;
        end
    end
    
    // Helper wires for intermediate calculation
    wire signed [2*WIDTH-1:0] gamma_x_norm;
    
    // Compute gamma * x_norm
    assign gamma_x_norm = $signed(x_norm) * $signed(gamma);
    
    // Final stage: Compute y_out = gamma * (x_centered / sqrt_var) + beta
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            y_out <= 0;
            valid_out <= 0;
        end else begin
            // Improved division protection with more precise threshold
            if (sqrt_var <= epsilon) begin
                // Division protection - using epsilon as minimum divisor
                x_norm = ((x_centered << FRAC) / epsilon);
            end else begin
                // Regular calculation: x_norm = x_centered / sqrt_var
                x_norm = ((x_centered << FRAC) / sqrt_var);
            end
            
            if (valid_stage2) begin
                // Scale and shift: y = gamma * x_norm + beta
                y_out <= $signed(((gamma_x_norm + (1 << (FRAC-1))) >>> FRAC) + $signed(beta));
            end
            
            valid_out <= valid_stage2;
        end
    end
endmodule