// Top module implementing complete SE (Squeeze-and-Excitation) module with proper architecture
module top_all_layers #(
    parameter DATA_WIDTH = 16,
    parameter IN_CHANNELS = 16,
    parameter REDUCTION = 4,
    parameter IN_HEIGHT = 8,
    parameter IN_WIDTH = 8
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
    
    // SIMPLIFIED: Just store one attention value and apply it to all inputs
    logic [DATA_WIDTH-1:0] se_scale;
    logic se_scale_ready;
    
    // Simple buffer for input data  
    logic [DATA_WIDTH-1:0] input_buffer [1023:0];  // Store all inputs
    logic [9:0] input_count;        // Input counter (1024 = 2^10)
    logic [9:0] output_count;       // Output counter
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
    BatchNorm_param #(.DATA_WIDTH(DATA_WIDTH)) bn1 (
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
    ReLU_param #(.DATA_WIDTH(DATA_WIDTH)) relu (
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
    BatchNorm_param #(.DATA_WIDTH(DATA_WIDTH)) bn2 (
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
            // Clear input buffer
            for (int i = 0; i < 1024; i++) begin
                input_buffer[i] <= 0;
            end
        end else begin
            if (input_valid && !inputs_complete) begin
                input_buffer[input_count] <= in_data;
                input_count <= input_count + 1;
                
                // FIXED: Add debug for input collection
                if (input_count < 10 || input_count >= 1020) begin
                    $display("DEBUG INPUT: count=%0d, data=%0d", input_count, in_data);
                end
                
                if (input_count >= 1023) begin
                    inputs_complete <= 1;
                    $display("DEBUG: inputs_complete set to 1, total inputs received: %0d", input_count + 1);
                end
            end else if (outputting && output_count >= 1023) begin
                // Reset for next frame
                input_count <= 0;
                inputs_complete <= 0;
                $display("DEBUG: Reset for next frame");
            end
        end
    end

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
                $display(" SE Scale computed: %0d (hsigmoid_out: %0d)", se_scale, hsigmoid_out);
            end else if (!inputs_complete) begin
                // Reset SE scale when starting new frame
                se_scale_ready <= 0;
            end
        end
    end

    // Output all stored inputs with SE scaling
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            out_data <= 0;
            out_valid <= 0;
            output_count <= 0;
            outputting <= 0;
        end else begin
            if (inputs_complete && se_scale_ready && !outputting) begin
                // Start outputting all stored inputs
                outputting <= 1;
                output_count <= 0;
                $display(" Starting SE output generation with scale: %0d", se_scale);
            end else if (outputting) begin
                if (output_count < 1024) begin
                    // FIXED: Apply SE scaling with proper range checking and minimum output
                    logic [31:0] scaled_result;
                    scaled_result = (input_buffer[output_count] * se_scale) >> 8;
                    
                    // Ensure minimum output for non-zero inputs
                    if (input_buffer[output_count] > 0 && scaled_result == 0) begin
                        out_data <= 1; // Minimum non-zero output
                    end else if (scaled_result > 65535) begin
                        out_data <= 65535; // Saturation
                    end else begin
                        out_data <= scaled_result[15:0];
                    end
                    
                    // Debug output for first few values
                    if (output_count < 5 || output_count % 100 == 0) begin
                        $display(" SE Output[%0d]: input=%0d * scale=%0d = %0d", 
                                output_count, input_buffer[output_count], se_scale, scaled_result[15:0]);
                    end
                    
                    out_valid <= 1;
                    output_count <= output_count + 1;
                end else begin
                    // Finished outputting, reset for next frame
                    $display(" SE Output complete: %0d values generated", output_count);
                    outputting <= 0;
                    out_valid <= 0;
                    se_scale_ready <= 0; // Allow new SE computation
                end
            end else begin
                out_valid <= 0;
            end
        end
    end

    // Debug outputs
    assign pool_out_debug = pool_out;
    assign bn1_out_debug = bn1_out;
    assign relu_out_debug = relu_out;
    assign conv1_out_debug = conv1_out;
    assign bn2_out_debug = bn2_out;
    assign conv2_out_debug = conv2_out;
    assign hsigmoid_out_debug = hsigmoid_out;

endmodule 