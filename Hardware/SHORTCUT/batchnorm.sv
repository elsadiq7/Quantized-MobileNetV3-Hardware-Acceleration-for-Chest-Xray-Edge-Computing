module batchnorm #(
    parameter WIDTH = 16,
    parameter FRAC = 8,
    parameter CHANNELS = 48
) (
    input wire clk,
    input wire rst,
    input wire en,
    
    // Input data
    input wire [WIDTH-1:0] x_in,
    input wire [$clog2(CHANNELS)-1:0] channel_in,
    input wire valid_in,
    
    // Batch normalization parameters (packed arrays)
    input wire [(CHANNELS*WIDTH)-1:0] gamma_packed,  // Scale parameters
    input wire [(CHANNELS*WIDTH)-1:0] beta_packed,   // Shift parameters
    
    // Output data
    output reg [WIDTH-1:0] y_out,
    output reg [$clog2(CHANNELS)-1:0] channel_out,
    output reg valid_out
);

    // FPGA-optimized batch normalization parameters
    (* ram_style = "block" *) reg [WIDTH-1:0] gamma_memory [0:CHANNELS-1];  // Scale parameters  
    (* ram_style = "block" *) reg [WIDTH-1:0] beta_memory [0:CHANNELS-1];   // Bias parameters
    
    // Control registers
    reg params_loaded;
    reg memory_initialized;
    
    // Synthesis-friendly memory initialization
    integer init_idx;
    always @(posedge clk) begin
        if (rst) begin
            memory_initialized <= 1'b0;
            params_loaded <= 1'b0;
        end else if (!memory_initialized) begin
            // Initialize memories to safe values
            for (init_idx = 0; init_idx < CHANNELS; init_idx = init_idx + 1) begin
                gamma_memory[init_idx] <= 1 << FRAC;  // Unity scale
                beta_memory[init_idx] <= {WIDTH{1'b0}};  // Zero bias
            end
            memory_initialized <= 1'b1;
        end else if (!params_loaded && en && memory_initialized) begin
            // Load parameters from packed arrays
            for (init_idx = 0; init_idx < CHANNELS; init_idx = init_idx + 1) begin
                gamma_memory[init_idx] <= gamma_packed[init_idx*WIDTH +: WIDTH];
                beta_memory[init_idx] <= beta_packed[init_idx*WIDTH +: WIDTH];
            end
            params_loaded <= 1'b1;
        end
    end
    
    // Fixed epsilon for numerical stability (not used in simplified inference)
    localparam signed [WIDTH-1:0] EPSILON = 1 << (FRAC-4);
    
    // Improved pipeline registers for 4-stage processing
    reg [WIDTH-1:0] x_reg [0:3];
    reg [$clog2(CHANNELS)-1:0] ch_reg [0:3];
    reg [WIDTH-1:0] gamma_reg [0:2];
    reg [WIDTH-1:0] beta_reg [0:2];
    reg valid_reg [0:3];
    
    // FPGA-optimized intermediate calculation registers
    reg [2*WIDTH-1:0] mult_result;
    reg [2*WIDTH+7:0] scaled_extended;
    reg [WIDTH-1:0] scaled_shifted;
    reg [WIDTH-1:0] final_result;
    
    // Input validation with bounds checking
    wire [WIDTH-1:0] validated_x;
    wire [$clog2(CHANNELS)-1:0] validated_ch;
    wire validated_valid;
    wire channel_in_bounds;
    
    assign validated_x = (^x_in === 1'bx) ? {WIDTH{1'b0}} : x_in;
    assign channel_in_bounds = (channel_in < CHANNELS);
    assign validated_ch = ((^channel_in === 1'bx) || !channel_in_bounds) ? {$clog2(CHANNELS){1'b0}} : channel_in;
    assign validated_valid = (valid_in === 1'bx) ? 1'b0 : (valid_in && channel_in_bounds);
    
    // Main processing pipeline - single always block for better synthesis
    integer stage;
    always @(posedge clk) begin
        if (rst) begin
            // Reset all pipeline stages
            for (stage = 0; stage < 4; stage = stage + 1) begin
                x_reg[stage] <= {WIDTH{1'b0}};
                ch_reg[stage] <= {$clog2(CHANNELS){1'b0}};
                valid_reg[stage] <= 1'b0;
            end
            for (stage = 0; stage < 3; stage = stage + 1) begin
                gamma_reg[stage] <= {WIDTH{1'b0}};
                beta_reg[stage] <= {WIDTH{1'b0}};
            end
            
            y_out <= {WIDTH{1'b0}};
            channel_out <= {$clog2(CHANNELS){1'b0}};
            valid_out <= 1'b0;
            mult_result <= {2*WIDTH{1'b0}};
            scaled_extended <= {(2*WIDTH+8){1'b0}};
            scaled_shifted <= {WIDTH{1'b0}};
            final_result <= {WIDTH{1'b0}};
            
        end else begin
            
            // Stage 0: Input validation and parameter fetch with safe indexing
            if (en && validated_valid && params_loaded && memory_initialized) begin
                x_reg[0] <= validated_x;
                ch_reg[0] <= validated_ch;
                // Safe parameter fetch with bounds checking
                if (validated_ch < CHANNELS) begin
                    gamma_reg[0] <= gamma_memory[validated_ch];
                    beta_reg[0] <= beta_memory[validated_ch];
                end else begin
                    // Default parameters for out-of-bounds access
                    gamma_reg[0] <= 1 << FRAC;  // Unity scale
                    beta_reg[0] <= {WIDTH{1'b0}};  // Zero bias
                end
                valid_reg[0] <= 1'b1;
            end else begin
                x_reg[0] <= {WIDTH{1'b0}};
                ch_reg[0] <= {$clog2(CHANNELS){1'b0}};
                gamma_reg[0] <= 1 << FRAC;
                beta_reg[0] <= {WIDTH{1'b0}};
                valid_reg[0] <= 1'b0;
            end
            
            // Stage 1: Pipeline delay for memory access
            if (valid_reg[0]) begin
                x_reg[1] <= x_reg[0];
                ch_reg[1] <= ch_reg[0];
                gamma_reg[1] <= gamma_reg[0];
                beta_reg[1] <= beta_reg[0];
                valid_reg[1] <= 1'b1;
            end else begin
                valid_reg[1] <= 1'b0;
            end
            
            // Stage 2: Multiplication (DSP48 optimized)
            if (valid_reg[1]) begin
                x_reg[2] <= x_reg[1];
                ch_reg[2] <= ch_reg[1];
                gamma_reg[2] <= gamma_reg[1];
                beta_reg[2] <= beta_reg[1];
                valid_reg[2] <= 1'b1;
                
                // Perform multiplication: x * gamma
                mult_result <= $signed(x_reg[1]) * $signed(gamma_reg[1]);
            end else begin
                valid_reg[2] <= 1'b0;
            end
            
            // Stage 3: Scaling and bias addition
            if (valid_reg[2]) begin
                x_reg[3] <= x_reg[2];
                ch_reg[3] <= ch_reg[2];
                valid_reg[3] <= 1'b1;
                
                // Sign-extend multiplication result
                scaled_extended <= {{8{mult_result[2*WIDTH-1]}}, mult_result};
                
                // Fixed-point scaling: divide by 2^FRAC and add bias
                scaled_shifted <= (mult_result >>> FRAC);
                final_result <= scaled_shifted + $signed(beta_reg[2]);
                
            end else begin
                valid_reg[3] <= 1'b0;
            end
            
            // Stage 4: Output with saturation protection
            if (valid_reg[3]) begin
                // Apply saturation for overflow protection
                if (final_result[WIDTH-1] && (&final_result[WIDTH-2:WIDTH-8])) begin
                    // Large negative value - clamp to zero (ReLU-like behavior for inference)
                    y_out <= {WIDTH{1'b0}};
                end else if (!final_result[WIDTH-1] && (|final_result[WIDTH-2:WIDTH-8])) begin
                    // Large positive value - clamp to maximum
                    y_out <= {1'b0, {(WIDTH-1){1'b1}}};
                end else begin
                    // Normal range - pass through
                    y_out <= final_result;
                end
                
                channel_out <= ch_reg[3];
                valid_out <= 1'b1;
                
            end else begin
                valid_out <= 1'b0;
                y_out <= {WIDTH{1'b0}};
                channel_out <= {$clog2(CHANNELS){1'b0}};
            end
        end
    end

endmodule 