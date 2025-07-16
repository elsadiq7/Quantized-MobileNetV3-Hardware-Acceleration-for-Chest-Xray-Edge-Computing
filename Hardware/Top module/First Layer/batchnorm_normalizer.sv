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
    // Fixed point values - optimized for synthesis
    localparam signed [WIDTH-1:0] EPSILON = 16'h0010; // Minimum variance value
    localparam signed [WIDTH-1:0] ONE_FP = 16'h0100;   // 1.0 in fixed point
    
    // Pipeline stages for better timing
    reg [WIDTH-1:0] x_in_stage1, x_in_stage2, x_in_stage3;
    reg [WIDTH-1:0] mean_stage1, mean_stage2;
    reg [WIDTH-1:0] variance_stage1, variance_stage2;
    reg [WIDTH-1:0] gamma_stage1, gamma_stage2, gamma_stage3;
    reg [WIDTH-1:0] beta_stage1, beta_stage2, beta_stage3;
    reg enable_stage1, enable_stage2, enable_stage3;
    
    // Stage 1: Compute x - mean and prepare variance
    reg signed [WIDTH-1:0] x_centered;
    reg signed [WIDTH-1:0] var_plus_eps;
    
    // Stage 2: Compute normalization factor using reciprocal approximation
    reg signed [WIDTH-1:0] norm_factor;
    reg signed [WIDTH-1:0] x_centered_reg;
    
    // Stage 3: Apply gamma and beta scaling
    reg signed [2*WIDTH-1:0] gamma_x_norm;
    reg signed [WIDTH-1:0] x_normalized;
    
    // Pipeline Stage 1: Input registration and centering
    always @(posedge clk) begin
        if (rst) begin
            x_in_stage1 <= 0;
            mean_stage1 <= 0;
            variance_stage1 <= 0;
            gamma_stage1 <= 0;
            beta_stage1 <= 0;
            enable_stage1 <= 1'b0;
            x_centered <= 0;
            var_plus_eps <= 0;
        end else begin
            x_in_stage1 <= x_in;
            mean_stage1 <= mean;
            variance_stage1 <= variance;
            gamma_stage1 <= gamma;
            beta_stage1 <= beta;
            enable_stage1 <= enable;
            
            // Compute x - mean
            x_centered <= $signed(x_in) - $signed(mean);
            
            // Add epsilon to variance for numerical stability
            var_plus_eps <= $signed(variance) + EPSILON;
        end
    end
    
    // Pipeline Stage 2: Normalization using reciprocal approximation
    always @(posedge clk) begin
        if (rst) begin
            x_in_stage2 <= 0;
            mean_stage2 <= 0;
            variance_stage2 <= 0;
            gamma_stage2 <= 0;
            beta_stage2 <= 0;
            enable_stage2 <= 1'b0;
            norm_factor <= 0;
            x_centered_reg <= 0;
        end else begin
            x_in_stage2 <= x_in_stage1;
            mean_stage2 <= mean_stage1;
            variance_stage2 <= variance_stage1;
            gamma_stage2 <= gamma_stage1;
            beta_stage2 <= beta_stage1;
            enable_stage2 <= enable_stage1;
            x_centered_reg <= x_centered;
            
            // Reciprocal approximation for 1/sqrt(var + eps)
            // Using Newton-Raphson approximation: x_{n+1} = x_n * (3 - a*x_n^2) / 2
            // For FPGA efficiency, use simple scaling instead of complex sqrt
            if (var_plus_eps > EPSILON) begin
                // Approximate 1/sqrt(var_plus_eps) using bit shifts for power-of-2 cases
                if (var_plus_eps <= (ONE_FP >> 2)) begin // var < 0.25
                    norm_factor <= ONE_FP << 1; // ~2.0
                end else if (var_plus_eps <= ONE_FP) begin // var < 1.0
                    norm_factor <= ONE_FP; // ~1.0
                end else if (var_plus_eps <= (ONE_FP << 2)) begin // var < 4.0
                    norm_factor <= ONE_FP >> 1; // ~0.5
                end else begin
                    norm_factor <= ONE_FP >> 2; // ~0.25
                end
            end else begin
                norm_factor <= ONE_FP << 2; // Large factor for very small variance
            end
        end
    end
    
    // Pipeline Stage 3: Apply normalization and scaling
    always @(posedge clk) begin
        if (rst) begin
            x_in_stage3 <= 0;
            gamma_stage3 <= 0;
            beta_stage3 <= 0;
            enable_stage3 <= 1'b0;
            x_normalized <= 0;
            gamma_x_norm <= 0;
        end else begin
            x_in_stage3 <= x_in_stage2;
            gamma_stage3 <= gamma_stage2;
            beta_stage3 <= beta_stage2;
            enable_stage3 <= enable_stage2;
            
            // Normalize: x_norm = x_centered * norm_factor
            x_normalized <= (($signed(x_centered_reg) * $signed(norm_factor)) + (1 << (FRAC-1))) >>> FRAC;
            
            // Apply gamma scaling: gamma * x_normalized
            gamma_x_norm <= $signed(gamma_stage2) * $signed(x_normalized);
        end
    end
    
    // Output Stage: Final scaling and output
    always @(posedge clk) begin
        if (rst) begin
            y_out <= 0;
            valid_out <= 1'b0;
        end else begin
            if (enable_stage3) begin
                // Final result: y = gamma * x_normalized + beta
                // Apply rounding before truncation
                y_out <= $signed(((gamma_x_norm + (1 << (FRAC-1))) >>> FRAC) + $signed(beta_stage3));
            end
            
            valid_out <= enable_stage3;
        end
    end
    
endmodule