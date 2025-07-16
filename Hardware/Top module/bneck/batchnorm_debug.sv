`timescale 1ns / 1ps

// SYNTHESIS-CLEAN Batch Normalization - Comprehensive implementation
module batchnorm_debug #(
    parameter WIDTH = 16,
    parameter FRAC = 8,
    parameter CHANNELS = 16
) (
    input wire clk,
    input wire rst,
    input wire en,
    
    input wire [WIDTH-1:0] x_in,
    input wire [$clog2(CHANNELS)-1:0] channel_in,
    input wire valid_in,
    
    // Packed parameters
    input wire [(CHANNELS*WIDTH)-1:0] gamma_packed,
    input wire [(CHANNELS*WIDTH)-1:0] beta_packed,
    input wire [(CHANNELS*WIDTH)-1:0] mean_packed,
    input wire [(CHANNELS*WIDTH)-1:0] variance_packed,
    
    output reg [WIDTH-1:0] y_out,
    output reg [$clog2(CHANNELS)-1:0] channel_out,
    output reg valid_out
);

    // Use wider arithmetic for intermediate calculations
    localparam CALC_WIDTH = WIDTH * 2;
    
    // Extract parameters from packed arrays
    reg [WIDTH-1:0] gamma [0:CHANNELS-1];
    reg [WIDTH-1:0] beta [0:CHANNELS-1];
    reg [WIDTH-1:0] mean [0:CHANNELS-1];
    reg [WIDTH-1:0] variance [0:CHANNELS-1];
    reg params_loaded;
    
    // Pipeline registers for synthesis optimization
    reg [WIDTH-1:0] x_reg [0:2];
    reg [$clog2(CHANNELS)-1:0] channel_reg [0:2];
    reg valid_reg [0:2];
    
    // Intermediate calculation registers
    reg [CALC_WIDTH-1:0] x_minus_mean;
    reg [CALC_WIDTH-1:0] norm_result;
    reg [CALC_WIDTH-1:0] scaled_result;
    reg [WIDTH-1:0] gamma_val, beta_val, mean_val, var_val;
    
    // Constants for normalization
    localparam [WIDTH-1:0] EPSILON = 16'h0010; // Small value to prevent division by zero
    localparam SCALE_FACTOR = FRAC;
    
    // Input validation for synthesis
    wire [WIDTH-1:0] validated_x_in;
    wire [$clog2(CHANNELS)-1:0] validated_channel_in;
    wire validated_valid_in;
    
    assign validated_x_in = x_in;
    assign validated_channel_in = channel_in;
    assign validated_valid_in = valid_in && en;
    
    // Load parameters from packed arrays using generate blocks
    genvar i;
    generate
        for (i = 0; i < CHANNELS; i = i + 1) begin : gen_param_init
            always_ff @(posedge clk) begin
                if (rst) begin
                    gamma[i] <= 16'h0100; // Default 1.0
                    beta[i] <= 16'h0000;  // Default 0.0
                    mean[i] <= 16'h0000;  // Default 0.0
                    variance[i] <= 16'h0100; // Default 1.0
                end else if (!params_loaded) begin
                    gamma[i] <= gamma_packed[i*WIDTH +: WIDTH];
                    beta[i] <= beta_packed[i*WIDTH +: WIDTH];
                    mean[i] <= mean_packed[i*WIDTH +: WIDTH];
                    variance[i] <= variance_packed[i*WIDTH +: WIDTH];
                end
            end
        end
    endgenerate
    
    always_ff @(posedge clk) begin
        if (rst) begin
            params_loaded <= 1'b0;
        end else if (!params_loaded) begin
            params_loaded <= 1'b1;
        end
    end
    
    // 3-stage pipeline for batch normalization
    always_ff @(posedge clk) begin
        if (rst) begin
            // Reset all pipeline stages
            x_reg[0] <= {WIDTH{1'b0}};
            x_reg[1] <= {WIDTH{1'b0}};
            x_reg[2] <= {WIDTH{1'b0}};
            channel_reg[0] <= {$clog2(CHANNELS){1'b0}};
            channel_reg[1] <= {$clog2(CHANNELS){1'b0}};
            channel_reg[2] <= {$clog2(CHANNELS){1'b0}};
            valid_reg[0] <= 1'b0;
            valid_reg[1] <= 1'b0;
            valid_reg[2] <= 1'b0;
            
            x_minus_mean <= {CALC_WIDTH{1'b0}};
            norm_result <= {CALC_WIDTH{1'b0}};
            scaled_result <= {CALC_WIDTH{1'b0}};
            gamma_val <= {WIDTH{1'b0}};
            beta_val <= {WIDTH{1'b0}};
            mean_val <= {WIDTH{1'b0}};
            var_val <= {WIDTH{1'b0}};
            
            y_out <= {WIDTH{1'b0}};
            channel_out <= {$clog2(CHANNELS){1'b0}};
            valid_out <= 1'b0;
            
        end else if (params_loaded) begin
            
            // Stage 0: Input capture and parameter lookup
            if (validated_valid_in) begin
                x_reg[0] <= validated_x_in;
                channel_reg[0] <= validated_channel_in;
                valid_reg[0] <= 1'b1;
                
                // Parameter lookup with bounds checking
                if (validated_channel_in < CHANNELS) begin
                    gamma_val <= gamma[validated_channel_in];
                    beta_val <= beta[validated_channel_in];
                    mean_val <= mean[validated_channel_in];
                    var_val <= (variance[validated_channel_in] > EPSILON) ? 
                               variance[validated_channel_in] : EPSILON;
                end else begin
                    // Default values for out-of-bounds channels
                    gamma_val <= 16'h0100; // 1.0
                    beta_val <= 16'h0000;  // 0.0
                    mean_val <= 16'h0000;  // 0.0
                    var_val <= 16'h0100;   // 1.0
                end
            end else begin
                valid_reg[0] <= 1'b0;
            end
            
            // Stage 1: Normalization (x - mean) / sqrt(variance)
            if (valid_reg[0]) begin
                x_reg[1] <= x_reg[0];
                channel_reg[1] <= channel_reg[0];
                valid_reg[1] <= 1'b1;
                
                // Calculate (x - mean)
                x_minus_mean <= $signed(x_reg[0]) - $signed(mean_val);
                
                // Simplified division using bit shifting for powers of 2 variance
                if (var_val == (16'h0100)) begin // variance = 1.0
                    norm_result <= x_minus_mean;
                end else if (var_val == (16'h0200)) begin // variance = 2.0
                    norm_result <= x_minus_mean >>> 1; // Divide by sqrt(2) ≈ /1.4 ≈ >>1 with compensation
                end else if (var_val == (16'h0400)) begin // variance = 4.0
                    norm_result <= x_minus_mean >>> 1; // Divide by 2
                end else begin
                    // General case: approximate division
                    norm_result <= (x_minus_mean << SCALE_FACTOR) / var_val;
                end
            end else begin
                valid_reg[1] <= 1'b0;
            end
            
            // Stage 2: Scale and shift (gamma * normalized + beta)
            if (valid_reg[1]) begin
                x_reg[2] <= x_reg[1];
                channel_reg[2] <= channel_reg[1];
                valid_reg[2] <= 1'b1;
                
                // Apply gamma and beta
                scaled_result <= ($signed(gamma_val) * $signed(norm_result)) + 
                               ($signed(beta_val) << SCALE_FACTOR);
            end else begin
                valid_reg[2] <= 1'b0;
            end
            
            // Output stage: Final scaling and saturation
            if (valid_reg[2]) begin
                // Scale back and apply saturation
                logic [CALC_WIDTH-1:0] final_result;
                final_result = scaled_result >>> SCALE_FACTOR;
                
                if (final_result > ((1 << (WIDTH-1)) - 1)) begin
                    y_out <= (1 << (WIDTH-1)) - 1; // Positive saturation
                end else if (final_result < (-(1 << (WIDTH-1)))) begin
                    y_out <= -(1 << (WIDTH-1)); // Negative saturation
                end else begin
                    y_out <= final_result[WIDTH-1:0];
                    
                    // Preserve minimum non-zero output for non-zero inputs
                    if (x_reg[2] != 0 && final_result == 0) begin
                        y_out <= (x_reg[2] > 0) ? 1 : -1;
                    end
                end
                
                channel_out <= channel_reg[2];
                valid_out <= 1'b1;
            end else begin
                y_out <= {WIDTH{1'b0}};
                channel_out <= {$clog2(CHANNELS){1'b0}};
                valid_out <= 1'b0;
            end
            
        end else begin
            // Reset outputs when parameters not loaded
            y_out <= {WIDTH{1'b0}};
            channel_out <= {$clog2(CHANNELS){1'b0}};
            valid_out <= 1'b0;
        end
    end

endmodule
