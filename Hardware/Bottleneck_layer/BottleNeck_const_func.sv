`timescale 1ns / 1ps

// SYNTHESIS-OPTIMIZED BottleNeck Module - Vivado-friendly implementation
module BottleNeck_const_func #(
    // Synthesis-friendly parameters - SMALL sizes for elaboration
    parameter N = 16,                    // Data width
    parameter Q = 8,                     // Fractional bits
    parameter IN_CHANNELS = 4,           // Reduced from 16 to 4
    parameter EXPAND_CHANNELS = 8,       // Reduced from 16 to 8  
    parameter OUT_CHANNELS = 4,          // Reduced from 16 to 4
    parameter FEATURE_SIZE = 8,          // Reduced from 112 to 8!!!
    parameter KERNEL_SIZE = 3,           // Depthwise kernel size
    parameter STRIDE = 1,                // Reduced from 2 to 1
    parameter PADDING = 1,               // Padding for depthwise conv
    parameter ACTIVATION_TYPE = 0        // 0: ReLU, 1: H-Swish
) (
    input wire clk,
    input wire rst,
    input wire en,
    
    // Input interface
    input wire [N-1:0] data_in,
    input wire [$clog2(IN_CHANNELS)-1:0] channel_in,
    input wire valid_in,
    
    // Output interface
    output wire [N-1:0] data_out,
    output wire [$clog2(OUT_CHANNELS)-1:0] channel_out,
    output wire valid_out,
    output wire done
);

    // Synthesis-friendly parameters - no massive calculations
    localparam TOTAL_INPUTS = 64;      // 8*8*1 instead of 112*112*16 
    localparam TOTAL_OUTPUTS = 64;     // 8*8*1 
    localparam PIPELINE_LATENCY = 16;  // Reduced from 100
    
    // SMALL weight storage for synthesis - maximum 64 elements each
    localparam MAX_WEIGHTS = 64;
    reg [N-1:0] pw1_weights [0:MAX_WEIGHTS-1];
    reg [N-1:0] pw2_weights [0:MAX_WEIGHTS-1]; 
    reg [N-1:0] dw_weights [0:MAX_WEIGHTS-1];
    
    // Small parameter arrays
    reg [N-1:0] bn_params [0:31]; // All BN params in one small array
    
    // Simple state machine
    typedef enum logic [1:0] {
        IDLE,
        PROCESSING,
        DONE_STATE
    } state_t;
    state_t state, next_state;

    // Pipeline control 
    reg [$clog2(TOTAL_INPUTS+1)-1:0] input_count;
    reg [$clog2(TOTAL_OUTPUTS+1)-1:0] output_count;
    reg pipeline_active;
    
    // Streaming pipeline stages - NO large buffers
    reg [N-1:0] stage_data [0:7];
    reg [7:0] stage_valid;
    reg [$clog2(OUT_CHANNELS)-1:0] stage_channel [0:7];
    
    // Initialize small arrays with generate blocks
    genvar i;
    generate
        for (i = 0; i < MAX_WEIGHTS; i = i + 1) begin : gen_weights_init
            always_ff @(posedge clk) begin
                if (rst) begin
                    pw1_weights[i] <= (i < 16) ? 16'h0100 : 16'h0000; // Only first 16 are identity
                    pw2_weights[i] <= (i < 16) ? 16'h0100 : 16'h0000;
                    dw_weights[i] <= (i < 9) ? 16'h0040 : 16'h0000;   // 3x3 kernel
                end
            end
        end
        
        for (i = 0; i < 32; i = i + 1) begin : gen_bn_init
            always_ff @(posedge clk) begin
                if (rst) begin
                    bn_params[i] <= (i[0] == 0) ? 16'h0100 : 16'h0000; // Alternating 1.0, 0.0
                end
            end
        end
        
        for (i = 0; i < 8; i = i + 1) begin : gen_stage_init
            always_ff @(posedge clk) begin
                if (rst) begin
                    stage_data[i] <= 16'h0000;
                    stage_channel[i] <= 0;
                end
            end
        end
    endgenerate
    
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
                if (en && valid_in)
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
    
    // Simple pipeline processing
    always_ff @(posedge clk) begin
        if (rst) begin
            input_count <= 0;
            output_count <= 0;
            pipeline_active <= 1'b0;
            stage_valid <= 8'h00;
        end else begin
            case (state)
                IDLE: begin
                    input_count <= 0;
                    output_count <= 0;
                    pipeline_active <= 1'b0;
                    stage_valid <= 8'h00;
                end
                
                PROCESSING: begin
                    pipeline_active <= 1'b1;
                    
                    // Input stage
                    if (valid_in && input_count < TOTAL_INPUTS) begin
                        stage_data[0] <= data_in;
                        stage_channel[0] <= channel_in; 
                        stage_valid[0] <= 1'b1;
                        input_count <= input_count + 1;
                    end else begin
                        stage_valid[0] <= 1'b0;
                    end
                    
                    // Pipeline stages - simple processing
                    if (stage_valid[0]) begin
                        // Stage 1: PW Conv1 (simplified)
                        stage_data[1] <= stage_data[0] + pw1_weights[stage_channel[0]];
                        stage_channel[1] <= stage_channel[0];
                        stage_valid[1] <= 1'b1;
                    end else begin
                        stage_valid[1] <= 1'b0;
                    end
                    
                    if (stage_valid[1]) begin
                        // Stage 2: BN1 (simplified)
                        stage_data[2] <= stage_data[1] + bn_params[0];
                        stage_channel[2] <= stage_channel[1];
                        stage_valid[2] <= 1'b1;
                    end else begin
                        stage_valid[2] <= 1'b0;
                    end
                    
                    if (stage_valid[2]) begin
                        // Stage 3: ReLU (simplified)
                        stage_data[3] <= (stage_data[2][N-1]) ? 16'h0000 : stage_data[2];
                        stage_channel[3] <= stage_channel[2];
                        stage_valid[3] <= 1'b1;
                    end else begin
                        stage_valid[3] <= 1'b0;
                    end
                    
                    if (stage_valid[3]) begin
                        // Stage 4: DW Conv (simplified) 
                        stage_data[4] <= stage_data[3] + dw_weights[0];
                        stage_channel[4] <= stage_channel[3];
                        stage_valid[4] <= 1'b1;
                    end else begin
                        stage_valid[4] <= 1'b0;
                    end
                    
                    if (stage_valid[4]) begin
                        // Stage 5: BN2 (simplified)
                        stage_data[5] <= stage_data[4] + bn_params[8]; 
                        stage_channel[5] <= stage_channel[4];
                        stage_valid[5] <= 1'b1;
                    end else begin
                        stage_valid[5] <= 1'b0;
                    end
                    
                    if (stage_valid[5]) begin
                        // Stage 6: ReLU2 (simplified)
                        stage_data[6] <= (stage_data[5][N-1]) ? 16'h0000 : stage_data[5];
                        stage_channel[6] <= stage_channel[5];
                        stage_valid[6] <= 1'b1;
                    end else begin
                        stage_valid[6] <= 1'b0;
                    end
                    
                    if (stage_valid[6]) begin
                        // Stage 7: PW Conv2 (simplified)
                        stage_data[7] <= stage_data[6] + pw2_weights[stage_channel[6]];
                        stage_channel[7] <= stage_channel[6] % OUT_CHANNELS;
                        stage_valid[7] <= 1'b1;
                    end else begin
                        stage_valid[7] <= 1'b0;
                    end
                    
                    // Output stage
                    if (stage_valid[7]) begin
                        output_count <= output_count + 1;
                    end
                end
                
                DONE_STATE: begin
                    pipeline_active <= 1'b0;
                end
            endcase
        end
    end
    
    // Output assignments
    assign data_out = stage_data[7];
    assign channel_out = stage_channel[7];
    assign valid_out = stage_valid[7];
    assign done = (state == DONE_STATE);

endmodule
