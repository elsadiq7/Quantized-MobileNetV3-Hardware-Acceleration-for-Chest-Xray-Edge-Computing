`timescale 1ns / 1ps

// SYNTHESIS-CLEAN Optimized BottleNeck Module
module BottleNeck_Optimized #(
    parameter N = 16,                    // Data width
    parameter Q = 8,                     // Fractional bits
    parameter IN_CHANNELS = 16,          // Input channels
    parameter EXPAND_CHANNELS = 16,      // Expanded channels
    parameter OUT_CHANNELS = 16,         // Output channels
    parameter FEATURE_SIZE = 112,        // Feature map size
    parameter KERNEL_SIZE = 3,           // Depthwise kernel size
    parameter STRIDE = 2,                // Stride for depthwise conv
    parameter PADDING = 1,               // Padding for depthwise conv
    parameter ACTIVATION_TYPE = 0,       // 0: ReLU, 1: H-Swish
    parameter SE_ENABLE = 0,             // 1: Enable SE module, 0: Disable SE
    parameter SE_REDUCTION = 4           // SE reduction ratio
) (
    input wire clk,
    input wire rst,
    input wire en,
    
    // Input interface
    input wire [N-1:0] data_in,
    input wire [$clog2(IN_CHANNELS)-1:0] channel_in,
    input wire valid_in,
    
    // SE module parameters (simplified)
    input wire [N-1:0] se_mean1, se_variance1, se_gamma1, se_beta1,
    input wire [N-1:0] se_mean2, se_variance2, se_gamma2, se_beta2,
    input wire se_load_kernel_conv1, se_load_kernel_conv2,
    
    // Output interface
    output wire [N-1:0] data_out,
    output wire [$clog2(OUT_CHANNELS)-1:0] channel_out,
    output wire valid_out,
    output wire done
);

    // Calculate output feature size based on convolution parameters
    localparam OUT_FEATURE_SIZE = (FEATURE_SIZE + 2*PADDING - KERNEL_SIZE) / STRIDE + 1;
    localparam USE_SHORTCUT = (STRIDE == 1 && IN_CHANNELS == OUT_CHANNELS);
    
    // Core bottleneck signals
    wire [N-1:0] bottleneck_data_out;
    wire [$clog2(OUT_CHANNELS)-1:0] bottleneck_channel_out;
    wire bottleneck_valid_out;
    wire bottleneck_done;
    
    // SE module signals
    wire [N-1:0] se_data_out;
    wire se_valid_out;
    
    // Shortcut signals
    wire [N-1:0] shortcut_data_out;
    wire [$clog2(OUT_CHANNELS)-1:0] shortcut_channel_out;
    wire shortcut_valid_out;
    wire shortcut_done;

    // Core bottleneck module - always instantiated
    BottleNeck_const_func #(
        .N(N), .Q(Q),
        .IN_CHANNELS(IN_CHANNELS),
        .EXPAND_CHANNELS(EXPAND_CHANNELS),
        .OUT_CHANNELS(OUT_CHANNELS),
        .FEATURE_SIZE(FEATURE_SIZE),
        .KERNEL_SIZE(KERNEL_SIZE),
        .STRIDE(STRIDE),
        .PADDING(PADDING),
        .ACTIVATION_TYPE(ACTIVATION_TYPE)
    ) bottleneck_core (
        .clk(clk),
        .rst(rst),
        .en(en),
        .data_in(data_in),
        .channel_in(channel_in),
        .valid_in(valid_in),
        .data_out(bottleneck_data_out),
        .channel_out(bottleneck_channel_out),
        .valid_out(bottleneck_valid_out),
        .done(bottleneck_done)
    );
    
    // Conditional SE module
    generate
        if (SE_ENABLE) begin : gen_se_module
            SE_module #(
                .DATA_WIDTH(N),
                .IN_CHANNELS(OUT_CHANNELS),
                .REDUCTION(SE_REDUCTION),
                .IN_HEIGHT(OUT_FEATURE_SIZE),
                .IN_WIDTH(OUT_FEATURE_SIZE)
            ) se_inst (
                .clk(clk),
                .rst(rst),
                .in_data(bottleneck_data_out),
                .mean1(se_mean1), 
                .variance1(se_variance1), 
                .gamma1(se_gamma1), 
                .beta1(se_beta1),
                .mean2(se_mean2), 
                .variance2(se_variance2), 
                .gamma2(se_gamma2), 
                .beta2(se_beta2),
                .load_kernel_conv1(se_load_kernel_conv1),
                .load_kernel_conv2(se_load_kernel_conv2),
                .input_valid(bottleneck_valid_out),
                .out_data(se_data_out),
                .out_valid(se_valid_out),
                // Debug outputs not connected
                .pool_out_debug(),
                .bn1_out_debug(),
                .relu_out_debug(),
                .conv1_out_debug(),
                .bn2_out_debug(),
                .conv2_out_debug(),
                .hsigmoid_out_debug()
            );
        end else begin : gen_se_bypass
            // SE module bypassed - direct connection
            assign se_data_out = bottleneck_data_out;
            assign se_valid_out = bottleneck_valid_out;
        end
    endgenerate
    
    // Conditional shortcut module
    generate
        if (USE_SHORTCUT) begin : gen_shortcut_module
            shortcut_with_actual_modules #(
                .N(N), .Q(Q),
                .IN_CHANNELS(IN_CHANNELS),
                .OUT_CHANNELS(OUT_CHANNELS),
                .FEATURE_SIZE(OUT_FEATURE_SIZE)
            ) shortcut_inst (
                .clk(clk),
                .rst(rst),
                .en(en),
                .data_in(se_data_out),
                .channel_in(bottleneck_channel_out),
                .valid_in(se_valid_out),
                .data_out(shortcut_data_out),
                .channel_out(shortcut_channel_out),
                .valid_out(shortcut_valid_out),
                .done(shortcut_done)
            );
        end else begin : gen_shortcut_bypass
            // No shortcut - direct connection
            assign shortcut_data_out = se_data_out;
            assign shortcut_channel_out = bottleneck_channel_out;
            assign shortcut_valid_out = se_valid_out;
            assign shortcut_done = bottleneck_done;
        end
    endgenerate
    
    // Output assignments
    assign data_out = shortcut_data_out;
    assign channel_out = shortcut_channel_out;
    assign valid_out = shortcut_valid_out;
    assign done = shortcut_done;

endmodule 