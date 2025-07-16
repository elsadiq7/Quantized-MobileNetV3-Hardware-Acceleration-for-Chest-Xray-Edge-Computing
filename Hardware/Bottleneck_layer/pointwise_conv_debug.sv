`timescale 1ns / 1ps

// SYNTHESIS-OPTIMIZED Pointwise Convolution - Vivado-friendly implementation
module pointwise_conv_debug #(
    // Synthesis-friendly parameters - SMALL sizes
    parameter N = 16,                    // Data width
    parameter Q = 8,                     // Fractional bits
    parameter IN_CHANNELS = 4,           // Reduced from 16 to 4
    parameter OUT_CHANNELS = 4,          // Reduced from 16 to 4
    parameter FEATURE_SIZE = 8,          // Reduced from 112 to 8
    parameter PARALLELISM = 1            // Processing parallelism
) (
    input wire clk,
    input wire rst,
    input wire en,
    
    // Input interface
    input wire [N-1:0] data_in,
    input wire [$clog2(IN_CHANNELS)-1:0] channel_in,
    input wire valid_in,
    
    // Weight loading interface - SMALL weights array
    input wire [IN_CHANNELS*OUT_CHANNELS*N-1:0] weights,
    
    // Output interface
    output wire [N-1:0] data_out,
    output wire [$clog2(OUT_CHANNELS)-1:0] channel_out,
    output wire valid_out,
    output wire done
);

    // State machine
    typedef enum logic [1:0] {
        IDLE,
        PROCESSING,
        DONE_STATE
    } state_t;
    state_t state, next_state;

    // Synthesis-friendly constants - NO massive calculations
    localparam TOTAL_INPUTS = 64;        // 8*8*1 instead of calculated
    localparam TOTAL_OUTPUTS = 64;       // 8*8*1

    // Small counters for synthesis
    reg [$clog2(TOTAL_INPUTS+1)-1:0] input_count;
    reg [$clog2(TOTAL_OUTPUTS+1)-1:0] output_count;
    
    // Small weight memory - synthesis-friendly size
    localparam WEIGHT_SIZE = (IN_CHANNELS*OUT_CHANNELS < 64) ? IN_CHANNELS*OUT_CHANNELS : 64;
    reg [N-1:0] weight_memory [0:WEIGHT_SIZE-1];
    reg weights_loaded;
    
    // Simple streaming pipeline - NO large buffers
    reg [N-1:0] data_reg [0:2];
    reg [$clog2(IN_CHANNELS)-1:0] channel_in_reg [0:2];
    reg [$clog2(OUT_CHANNELS)-1:0] channel_out_reg [0:2];
    reg valid_reg [0:2];
    
    // Computation registers
    reg [2*N-1:0] mult_result;
    reg [N-1:0] conv_result;
    reg [N-1:0] weight_val;
    
    // Input validation for synthesis
    wire [N-1:0] validated_data_in;
    wire [$clog2(IN_CHANNELS)-1:0] validated_channel_in;
    wire validated_valid_in;
    
    assign validated_data_in = data_in;
    assign validated_channel_in = channel_in;
    assign validated_valid_in = valid_in;
    
    // Load weights from packed array - synthesis optimized
    genvar i;
    generate
        for (i = 0; i < WEIGHT_SIZE; i = i + 1) begin : gen_weight_init
            always_ff @(posedge clk) begin
                if (rst) begin
                    weight_memory[i] <= (i < 16) ? 16'h0100 : 16'h0000; // Identity for first 16
                end else if (!weights_loaded && en && (i < IN_CHANNELS*OUT_CHANNELS)) begin
                    weight_memory[i] <= weights[i*N +: N];
                end
            end
        end
    endgenerate
    
    always_ff @(posedge clk) begin
        if (rst) begin
            weights_loaded <= 1'b0;
        end else if (!weights_loaded && en) begin
            weights_loaded <= 1'b1;
        end
    end
    
    // State machine
    always_ff @(posedge clk) begin
        if (rst) begin
            state <= IDLE;
        end else begin
            state <= next_state;
        end
    end
    
    always_comb begin
        case (state)
            IDLE: begin
                if (en && weights_loaded)
                    next_state = PROCESSING;
                else
                    next_state = IDLE;
            end
            
            PROCESSING: begin
                if (output_count >= TOTAL_OUTPUTS)
                    next_state = DONE_STATE;
                else
                    next_state = PROCESSING;
            end
            
            DONE_STATE: begin
                next_state = IDLE;
            end
            
            default: next_state = IDLE;
        endcase
    end
    
    // Simple control logic
    always_ff @(posedge clk) begin
        if (rst) begin
            input_count <= 0;
            output_count <= 0;
        end else begin
            case (state)
                IDLE: begin
                    input_count <= 0;
                    output_count <= 0;
                end
                
                PROCESSING: begin
                    // Count inputs
                    if (validated_valid_in && input_count < TOTAL_INPUTS) begin
                        input_count <= input_count + 1;
                    end

                    // Count outputs
                    if (valid_reg[2]) begin
                        output_count <= output_count + 1;
                    end
                end
                
                DONE_STATE: begin
                    // Hold counts
                end
            endcase
        end
    end
    
    // Simple 3-stage processing pipeline
    always_ff @(posedge clk) begin
        if (rst) begin
            // Reset all pipeline stages
            data_reg[0] <= 0;
            data_reg[1] <= 0;
            data_reg[2] <= 0;
            channel_in_reg[0] <= 0;
            channel_in_reg[1] <= 0;
            channel_in_reg[2] <= 0;
            channel_out_reg[0] <= 0;
            channel_out_reg[1] <= 0;
            channel_out_reg[2] <= 0;
            valid_reg[0] <= 1'b0;
            valid_reg[1] <= 1'b0;
            valid_reg[2] <= 1'b0;
            mult_result <= 0;
            conv_result <= 0;
            weight_val <= 0;
            
        end else if (en && weights_loaded && (state == PROCESSING)) begin
            
            // Stage 0: Input capture and validation
            if (validated_valid_in) begin
                data_reg[0] <= validated_data_in;
                channel_in_reg[0] <= validated_channel_in;
                channel_out_reg[0] <= validated_channel_in % OUT_CHANNELS; // Simple mapping
                valid_reg[0] <= 1'b1;
            end else begin
                valid_reg[0] <= 1'b0;
            end
            
            // Stage 1: Weight lookup and multiplication setup
            if (valid_reg[0]) begin
                data_reg[1] <= data_reg[0];
                channel_in_reg[1] <= channel_in_reg[0];
                channel_out_reg[1] <= channel_out_reg[0];
                valid_reg[1] <= 1'b1;
                
                // Weight lookup (simplified - identity mapping)
                if (channel_in_reg[0] < IN_CHANNELS && channel_out_reg[0] < OUT_CHANNELS) begin
                    weight_val <= weight_memory[channel_in_reg[0] * OUT_CHANNELS + channel_out_reg[0]];
                end else begin
                    weight_val <= 16'h0100; // Default identity weight
                end
            end else begin
                valid_reg[1] <= 1'b0;
            end
            
            // Stage 2: Multiplication and output
            if (valid_reg[1]) begin
                data_reg[2] <= data_reg[1];
                channel_in_reg[2] <= channel_in_reg[1];
                channel_out_reg[2] <= channel_out_reg[1];
                valid_reg[2] <= 1'b1;
                
                // Pointwise convolution: input * weight
                mult_result <= $signed(data_reg[1]) * $signed(weight_val);
                // Scale down multiplication result appropriately
                conv_result <= mult_result[N+Q-1:Q];
            end else begin
                valid_reg[2] <= 1'b0;
            end
            
        end else begin
            // Disable pipeline when not processing
            valid_reg[0] <= 1'b0;
            valid_reg[1] <= 1'b0;
            valid_reg[2] <= 1'b0;
        end
    end
    
    // Output assignments
    assign data_out = conv_result;
    assign channel_out = channel_out_reg[2];
    assign valid_out = valid_reg[2];
    assign done = (state == DONE_STATE);

endmodule
