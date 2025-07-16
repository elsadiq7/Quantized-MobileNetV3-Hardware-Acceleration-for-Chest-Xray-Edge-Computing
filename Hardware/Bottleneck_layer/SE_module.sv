// SYNTHESIS-CLEAN SE (Squeeze-and-Excitation) module with proper architecture
module SE_module #(
    parameter DATA_WIDTH = 16,
    parameter IN_CHANNELS = 16,
    parameter REDUCTION = 4,
    parameter IN_HEIGHT = 56,
    parameter IN_WIDTH = 56
) (
    input logic clk,
    input logic rst,
    input logic [DATA_WIDTH-1:0] in_data,
    input logic [DATA_WIDTH-1:0] mean1,      // BatchNorm params for first BN
    input logic [DATA_WIDTH-1:0] variance1,
    input logic [DATA_WIDTH-1:0] gamma1,
    input logic [DATA_WIDTH-1:0] beta1,
    input logic [DATA_WIDTH-1:0] mean2,      // BatchNorm params for second BN  
    input logic [DATA_WIDTH-1:0] variance2,
    input logic [DATA_WIDTH-1:0] gamma2,
    input logic [DATA_WIDTH-1:0] beta2,
    input logic load_kernel_conv1,           // Load kernel for first conv (channel reduction)
    input logic load_kernel_conv2,           // Load kernel for second conv (channel expansion)
    input logic input_valid,                 // Input data valid signal
    output logic [DATA_WIDTH-1:0] out_data,  // Final SE output: input * attention
    output logic out_valid,
    // Debug outputs
    output logic [DATA_WIDTH-1:0] pool_out_debug,
    output logic [DATA_WIDTH-1:0] bn1_out_debug,
    output logic [DATA_WIDTH-1:0] relu_out_debug,
    output logic [DATA_WIDTH-1:0] conv1_out_debug,
    output logic [DATA_WIDTH-1:0] bn2_out_debug,
    output logic [DATA_WIDTH-1:0] conv2_out_debug,
    output logic [DATA_WIDTH-1:0] hsigmoid_out_debug
);
    // Internal wires
    logic [DATA_WIDTH-1:0] pool_out, bn1_out, relu_out, conv1_out, bn2_out, conv2_out, hsigmoid_out;
    logic pool_valid, bn1_valid, relu_valid, conv1_valid, bn2_valid, conv2_valid, hsigmoid_valid;
    
    // Store one attention value and apply it to all inputs
    logic [DATA_WIDTH-1:0] se_scale;
    logic se_scale_ready;
    
    // Calculate buffer size with synthesis-friendly limits
    localparam TOTAL_INPUTS = IN_HEIGHT * IN_WIDTH * IN_CHANNELS;
    localparam BUFFER_SIZE = (TOTAL_INPUTS > 1024) ? 1024 : TOTAL_INPUTS; // Cap at 1K for synthesis
    localparam COUNTER_WIDTH = $clog2(TOTAL_INPUTS + 1);

    // Synthesis-optimized buffer for input data
    logic [DATA_WIDTH-1:0] input_buffer [BUFFER_SIZE-1:0];
    logic [COUNTER_WIDTH-1:0] input_count;
    logic [COUNTER_WIDTH-1:0] output_count;
    logic inputs_complete;
    logic outputting;

    // AdaptiveAvgPool2d(1) - Global Average Pooling
    AdaptiveAvgPool2d_1x1 #(
        .DATA_WIDTH(DATA_WIDTH), 
        .IN_HEIGHT(IN_HEIGHT), 
        .IN_WIDTH(IN_WIDTH), 
        .CHANNELS(IN_CHANNELS)
    ) pool (
        .clk(clk), 
        .rst(rst), 
        .in_data(in_data), 
        .in_valid(input_valid),
        .out_data(pool_out), 
        .out_valid(pool_valid)
    );

    // First Conv2D: channel reduction (in_channels -> in_channels/reduction)
    Conv2D #(
        .DATA_WIDTH(DATA_WIDTH),
        .IN_CHANNELS(IN_CHANNELS),
        .OUT_CHANNELS(IN_CHANNELS/REDUCTION)
    ) conv1 (
        .clk(clk), 
        .rst(rst), 
        .load_kernel(load_kernel_conv1), 
        .in_data(pool_out), 
        .in_valid(pool_valid), 
        .out_data(conv1_out), 
        .out_valid(conv1_valid)
    );

    // First BatchNorm (after first conv, before ReLU)
    BatchNorm_se #(.DATA_WIDTH(DATA_WIDTH)) bn1 (
        .clk(clk), 
        .rst(rst), 
        .in_data(conv1_out), 
        .in_valid(conv1_valid),
        .mean(mean1), 
        .variance(variance1), 
        .gamma(gamma1), 
        .beta(beta1), 
        .out_data(bn1_out), 
        .out_valid(bn1_valid)
    );

    // ReLU activation
    ReLU_se #(.DATA_WIDTH(DATA_WIDTH)) relu (
        .clk(clk), 
        .rst(rst), 
        .in_data(bn1_out), 
        .in_valid(bn1_valid),
        .out_data(relu_out), 
        .out_valid(relu_valid)
    );

    // Second Conv2D: channel expansion (in_channels/reduction -> in_channels)
    Conv2D #(
        .DATA_WIDTH(DATA_WIDTH),
        .IN_CHANNELS(IN_CHANNELS/REDUCTION),
        .OUT_CHANNELS(IN_CHANNELS)
    ) conv2 (
        .clk(clk), 
        .rst(rst), 
        .load_kernel(load_kernel_conv2), 
        .in_data(relu_out), 
        .in_valid(relu_valid), 
        .out_data(conv2_out), 
        .out_valid(conv2_valid)
    );

    // Second BatchNorm (after second conv, before hsigmoid)
    BatchNorm_se #(.DATA_WIDTH(DATA_WIDTH)) bn2 (
        .clk(clk), 
        .rst(rst), 
        .in_data(conv2_out), 
        .in_valid(conv2_valid),
        .mean(mean2), 
        .variance(variance2), 
        .gamma(gamma2), 
        .beta(beta2), 
        .out_data(bn2_out), 
        .out_valid(bn2_valid)
    );

    // Hard Sigmoid activation to get attention weights
    HardSwishSigmoid #(.DATA_WIDTH(DATA_WIDTH)) hsigmoid_module (
        .clk(clk), 
        .rst(rst), 
        .in_data(bn2_out), 
        .in_valid(bn2_valid),
        .hsigmoid_out(hsigmoid_out), 
        .hswish_out(), // Not used
        .out_valid(hsigmoid_valid)
    );

    // Store all input data
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            input_count <= 0;
            inputs_complete <= 0;
            // Clear input buffer with generate block for synthesis
        end else begin
            if (input_valid && !inputs_complete && input_count < BUFFER_SIZE) begin
                input_buffer[input_count] <= in_data;
                input_count <= input_count + 1;
                
                // Complete after receiving all expected inputs
                if (input_count >= (TOTAL_INPUTS - 1)) begin
                    inputs_complete <= 1;
                end
            end else if (outputting && output_count >= (TOTAL_INPUTS - 1)) begin
                // Reset for next frame
                input_count <= 0;
                inputs_complete <= 0;
            end
        end
    end

    // Initialize buffer with generate block for synthesis
    genvar i;
    generate
        for (i = 0; i < BUFFER_SIZE; i = i + 1) begin : gen_buffer_init
            always_ff @(posedge clk) begin
                if (rst) begin
                    input_buffer[i] <= 0;
                end
            end
        end
    endgenerate

    // Store first SE scale value and use it for all outputs
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            se_scale <= 16'h0100; // Default scale (1.0 in fixed point)
            se_scale_ready <= 0;
        end else begin
            if (hsigmoid_valid && !se_scale_ready) begin
                // Store the SE attention scale
                se_scale <= hsigmoid_out;
                se_scale_ready <= 1;
            end else if (!inputs_complete) begin
                // Reset SE scale when starting new frame
                se_scale_ready <= 0;
            end
        end
    end

    // Output all stored inputs with SE scaling
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            output_count <= 0;
            outputting <= 0;
            out_data <= 0;
            out_valid <= 0;
        end else begin
            if (inputs_complete && se_scale_ready && !outputting) begin
                // Start outputting
                outputting <= 1;
                output_count <= 0;
            end
            
            if (outputting && output_count < TOTAL_INPUTS && output_count < BUFFER_SIZE) begin
                // Output data with SE scaling
                logic [DATA_WIDTH*2-1:0] scaled_data;
                scaled_data = input_buffer[output_count] * se_scale;
                out_data <= scaled_data[DATA_WIDTH+7:8]; // Scale down appropriately
                out_valid <= 1;
                output_count <= output_count + 1;
                
                // Check if finished
                if (output_count >= (TOTAL_INPUTS - 1)) begin
                    outputting <= 0;
                end
            end else begin
                out_valid <= 0;
            end
        end
    end

    // Debug output assignments (kept for compatibility)
    assign pool_out_debug = pool_out;
    assign bn1_out_debug = bn1_out;
    assign relu_out_debug = relu_out;
    assign conv1_out_debug = conv1_out;
    assign bn2_out_debug = bn2_out;
    assign conv2_out_debug = conv2_out;
    assign hsigmoid_out_debug = hsigmoid_out;

endmodule 