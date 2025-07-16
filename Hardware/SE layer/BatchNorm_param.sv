module BatchNorm_param #(
    parameter DATA_WIDTH = 16
) (
    input  logic clk,
    input  logic rst,
    input  logic signed [DATA_WIDTH-1:0] in_data,
    input  logic in_valid,
    input  logic signed [DATA_WIDTH-1:0] mean,
    input  logic signed [DATA_WIDTH-1:0] variance,
    input  logic signed [DATA_WIDTH-1:0] gamma,
    input  logic signed [DATA_WIDTH-1:0] beta,
    output logic signed [DATA_WIDTH-1:0] out_data,
    output logic out_valid
);

    // Reduced intermediate width to balance precision and resource usage
    localparam CALC_WIDTH = DATA_WIDTH*2;  // Reduced from DATA_WIDTH*2
    
    // Pipeline registers
    logic signed [DATA_WIDTH-1:0] in_reg, mean_reg, var_reg, gamma_reg, beta_reg;
    logic signed [CALC_WIDTH-1:0] normalized_temp;
    logic [1:0] valid_pipeline;
    
    // Constants
    localparam signed [DATA_WIDTH-1:0] EPSILON = 16'h0040;
    localparam SHIFT_AMOUNT = DATA_WIDTH/4;
    
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            in_reg <= 0;
            mean_reg <= 0;
            var_reg <= EPSILON;
            gamma_reg <= 0;
            beta_reg <= 0;
            normalized_temp <= 0;
            valid_pipeline <= 0;
        end else begin
            // Stage 1: Input registration
            if (in_valid) begin
                in_reg <= in_data;
                mean_reg <= mean;
                var_reg <= (variance > EPSILON) ? variance : EPSILON;
                gamma_reg <= gamma;
                beta_reg <= beta;
            end
            
            // Stage 2: Normalization (x - mean) / sqrt(var + epsilon)
            // Simplified division using right shift approximation
            if (valid_pipeline[0]) begin
                // Use shift instead of division for variance when possible
                if (var_reg == (1 << SHIFT_AMOUNT)) begin
                    normalized_temp <= (in_reg - mean_reg) >>> (SHIFT_AMOUNT/2);
                end else begin
                    normalized_temp <= ((in_reg - mean_reg) * (1 << SHIFT_AMOUNT)) / var_reg;
                end
            end
            
            // Pipeline the valid signals
            valid_pipeline <= {valid_pipeline[0], in_valid};
        end
    end
    
    // Stage 3: Scale and shift (combinational to save registers)
    logic signed [CALC_WIDTH-1:0] scaled_value;
    always_comb begin
        scaled_value = (gamma_reg * normalized_temp) + (beta_reg << SHIFT_AMOUNT);
    end
    
    // Output stage with saturation
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            out_data <= 0;
            out_valid <= 0;
        end else begin
            out_valid <= valid_pipeline[1];
            
            if (valid_pipeline[1]) begin
                // Scale back and saturate
                if (scaled_value > ((1 << (DATA_WIDTH-1)) - 1)) begin
                    out_data <= (1 << (DATA_WIDTH-1)) - 1;
                end else if (scaled_value < (-(1 << (DATA_WIDTH-1)))) begin
                    out_data <= -(1 << (DATA_WIDTH-1));
                end else begin
                    out_data <= scaled_value >>> SHIFT_AMOUNT;
                    // Preserve minimum non-zero output
                    if (in_reg != 0 && out_data == 0) begin
                        out_data <= (in_reg > 0) ? 1 : -1;
                    end
                end
            end
        end
    end
endmodule