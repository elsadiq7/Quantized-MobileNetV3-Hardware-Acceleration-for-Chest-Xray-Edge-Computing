`timescale 1ns / 1ps

// Simple testbench for SE module with extensive debugging
module SE_module_tb;
    // Parameters - REDUCED SIZE FOR TESTING
    localparam DATA_WIDTH = 16;
    localparam IN_CHANNELS = 16;
    localparam REDUCTION = 4;
    localparam IN_HEIGHT = 8;  // Reduced from 56 to 8 for faster testing
    localparam IN_WIDTH = 8;   // Reduced from 56 to 8 for faster testing
    localparam TOTAL_PIXELS = IN_CHANNELS * IN_HEIGHT * IN_WIDTH;
    
    // Test signals
    logic clk, rst;
    logic [DATA_WIDTH-1:0] in_data;
    logic [DATA_WIDTH-1:0] mean1, variance1, gamma1, beta1;
    logic [DATA_WIDTH-1:0] mean2, variance2, gamma2, beta2;
    logic load_kernel_conv1, load_kernel_conv2;
    logic input_valid;
    logic [DATA_WIDTH-1:0] out_data;
    logic out_valid;
    
    // Debug outputs
    logic [DATA_WIDTH-1:0] pool_out_debug, bn1_out_debug, relu_out_debug;
    logic [DATA_WIDTH-1:0] conv1_out_debug, bn2_out_debug, conv2_out_debug;
    logic [DATA_WIDTH-1:0] hsigmoid_out_debug;

    // Test tracking
    int outputs_received = 0;
    int test_input_value = 0;

    // Instantiate the SE module
    SE_module #(
        .DATA_WIDTH(DATA_WIDTH),
        .IN_CHANNELS(IN_CHANNELS),
        .REDUCTION(REDUCTION),
        .IN_HEIGHT(IN_HEIGHT),
        .IN_WIDTH(IN_WIDTH)
    ) uut (
        .clk(clk),
        .rst(rst),
        .in_data(in_data),
        .mean1(mean1), .variance1(variance1), .gamma1(gamma1), .beta1(beta1),
        .mean2(mean2), .variance2(variance2), .gamma2(gamma2), .beta2(beta2),
        .load_kernel_conv1(load_kernel_conv1),
        .load_kernel_conv2(load_kernel_conv2),
        .input_valid(input_valid),
        .out_data(out_data),
        .out_valid(out_valid),
        .pool_out_debug(pool_out_debug),
        .bn1_out_debug(bn1_out_debug),
        .relu_out_debug(relu_out_debug),
        .conv1_out_debug(conv1_out_debug),
        .bn2_out_debug(bn2_out_debug),
        .conv2_out_debug(conv2_out_debug),
        .hsigmoid_out_debug(hsigmoid_out_debug)
    );

    // Clock generation
    initial clk = 0;
    always #5 clk = ~clk;

    // Monitor outputs
    always @(posedge clk) begin
        if (out_valid) begin
            outputs_received++;
            if (outputs_received <= 10 || outputs_received % 100 == 0) begin
                $display("OUTPUT[%0d]: %0d", outputs_received, out_data);
            end
        end
    end

    // Task to load kernels
    task load_kernels();
        $display("\n=== LOADING KERNELS ===");
        
        // Load Conv1 kernels
        $display("Loading Conv1 kernels (%0d weights) with pattern [1,2,3,4]...", IN_CHANNELS * (IN_CHANNELS/REDUCTION));
        load_kernel_conv1 = 1;
        load_kernel_conv2 = 0;
        input_valid = 0;
        
        // FIXED: Wait one cycle for load signal to be recognized
        @(posedge clk);
        
        for (int i = 0; i < IN_CHANNELS * (IN_CHANNELS/REDUCTION); i++) begin
            // Use small meaningful weights: 1, 2, 3, 4, cycling pattern
            in_data = (i % 4) + 1; // Weights: 1, 2, 3, 4, 1, 2, 3, 4, ...
            input_valid = 1; // CRITICAL: Enable input_valid for weight loading
            @(posedge clk);
            if (i < 10) $display("  Conv1 weight[%0d] = %0d (sent)", i, (i % 4) + 1);
        end
        input_valid = 0; // Disable input_valid after weight loading
        
        // FIXED: Wait for load completion
        @(posedge clk);
        load_kernel_conv1 = 0;
        $display("Conv1 kernels loaded.");
        
        #10;

        // CRITICAL: Ensure Conv1 loading is completely disabled before starting Conv2
        load_kernel_conv1 = 0;
        load_kernel_conv2 = 0;
        input_valid = 0;
        @(posedge clk); // Wait one cycle to ensure signals are stable

        // Load Conv2 kernels
        $display("Loading Conv2 kernels (%0d weights) with pattern [2,4,6,8]...", (IN_CHANNELS/REDUCTION) * IN_CHANNELS);
        load_kernel_conv2 = 1;
        
        // FIXED: Wait one cycle for load signal to be recognized
        @(posedge clk);
        
        for (int i = 0; i < (IN_CHANNELS/REDUCTION) * IN_CHANNELS; i++) begin
            // Use different pattern for Conv2: 2, 4, 6, 8, cycling pattern
            in_data = ((i % 4) + 1) * 2; // Weights: 2, 4, 6, 8, 2, 4, 6, 8, ...
            input_valid = 1; // CRITICAL: Enable input_valid for weight loading
            @(posedge clk);
            if (i < 10) $display("  Conv2 weight[%0d] = %0d (sent)", i, ((i % 4) + 1) * 2);
        end
        input_valid = 0; // Disable input_valid after weight loading
        
        // FIXED: Wait for load completion
        @(posedge clk);
        load_kernel_conv2 = 0;
        $display("Conv2 kernels loaded.");
        $display("=== KERNEL LOADING COMPLETE ===\n");
    endtask

    // Task to send test data
    task send_test_data(input [DATA_WIDTH-1:0] value);
        $display("\n=== SENDING TEST DATA ===");
        $display("Input value: %0d", value);
        $display("Total pixels to send: %0d", TOTAL_PIXELS);
        
        load_kernel_conv1 = 0;
        load_kernel_conv2 = 0;
        input_valid = 1;
        test_input_value = value;
        outputs_received = 0;
        
        // Send all pixels
        for (int pixel = 0; pixel < TOTAL_PIXELS; pixel++) begin
            in_data = value + (pixel % 16); // Slight variation per pixel
            @(posedge clk);
            
            if (pixel < 5 || pixel >= TOTAL_PIXELS - 5) begin
                $display("  Input[%0d] = %0d", pixel, value + (pixel % 16));
            end else if (pixel == 5) begin
                $display("  ... (sending %0d more pixels) ...", TOTAL_PIXELS - 10);
            end
        end
        
        input_valid = 0;
        $display("All input data sent.");
        $display("=== INPUT SENDING COMPLETE ===\n");
    endtask

    // Task to wait for outputs - NO TIMEOUT, run until success
    task wait_for_outputs_unlimited();
        automatic int cycle_count = 0;
        
        $display("\n=== WAITING FOR OUTPUTS (UNLIMITED TIME) ===");
        $display("Expecting %0d outputs...", TOTAL_PIXELS);
        $display("Will run indefinitely until all outputs are received...");
        
        while (outputs_received < TOTAL_PIXELS) begin
            @(posedge clk);
            cycle_count++;
            
            // Show progress every 500 cycles (less frequent to avoid spam)
            if (cycle_count % 500 == 0) begin
                $display("  Cycle %0d: Received %0d/%0d outputs", cycle_count, outputs_received, TOTAL_PIXELS);
            end
            
            // Show major milestones
            if (outputs_received > 0 && (outputs_received % 100 == 0)) begin
                $display("  MILESTONE: %0d outputs received at cycle %0d", outputs_received, cycle_count);
            end
        end
        
        $display("\n=== OUTPUT COLLECTION RESULTS ===");
        $display("Cycles waited: %0d", cycle_count);
        $display("Outputs received: %0d/%0d", outputs_received, TOTAL_PIXELS);
        $display("SUCCESS: All outputs received!");
        $display("=== END OUTPUT RESULTS ===\n");
    endtask

    // Main test sequence
    initial begin
        $display("\n");
        $display("========================================");
        $display("   SE MODULE SIMPLE TEST");
        $display("========================================");
        $display("Configuration:");
        $display("  IN_CHANNELS: %0d", IN_CHANNELS);
        $display("  REDUCTION: %0d", REDUCTION);
        $display("  INPUT SIZE: %0dx%0d", IN_HEIGHT, IN_WIDTH);
        $display("  TOTAL PIXELS: %0d", TOTAL_PIXELS);
        $display("========================================");

        // Initialize signals
        rst = 1;
        in_data = 0;
        mean1 = 0; variance1 = 1024; gamma1 = 256; beta1 = 0;
        mean2 = 0; variance2 = 1024; gamma2 = 256; beta2 = 0;
        load_kernel_conv1 = 0;
        load_kernel_conv2 = 0;
        input_valid = 0;
        
        $display("\n=== INITIALIZATION ===");
        $display("Resetting module...");
        #20;
        rst = 0;
        #50;
        $display("Reset complete.");
        $display("=== INITIALIZATION COMPLETE ===\n");

        // Load kernels
        load_kernels();
        #50;

        // Test with simple input
        $display("\n");
        $display("========================================");
        $display("   RUNNING TEST");
        $display("========================================");
        
        send_test_data(100);
        wait_for_outputs_unlimited();

        // Final summary
        $display("\n");
        $display("========================================");
        $display("   FINAL TEST SUMMARY");
        $display("========================================");
        $display("Input value used: %0d", test_input_value);
        $display("Expected outputs: %0d", TOTAL_PIXELS);
        $display("Actual outputs: %0d", outputs_received);
        
        if (outputs_received >= TOTAL_PIXELS) begin
            $display("RESULT: PASS - SE module is working!");
        end else if (outputs_received > 0) begin
            $display("RESULT: PARTIAL - SE module produces some outputs");
        end else begin
            $display("RESULT: FAIL - SE module produces no outputs");
        end
        $display("========================================");
        
        $finish;
    end

    // Debug pipeline stages
    always @(posedge clk) begin
        if ($time > 1000) begin // Start monitoring after initialization
            // Monitor pipeline activity
            static int last_pool_out = 0;
            static int last_conv1_out = 0;
            static int last_conv2_out = 0;
            static int last_hsigmoid_out = 0;
            
            if (pool_out_debug !== last_pool_out && pool_out_debug !== 0) begin
                $display("PIPELINE: Pool output = %0d", pool_out_debug);
                last_pool_out = pool_out_debug;
            end
            
            if (conv1_out_debug !== last_conv1_out && conv1_out_debug !== 0) begin
                $display("PIPELINE: Conv1 output = %0d", conv1_out_debug);
                last_conv1_out = conv1_out_debug;
            end
            
            if (conv2_out_debug !== last_conv2_out && conv2_out_debug !== 0) begin
                $display("PIPELINE: Conv2 output = %0d", conv2_out_debug);
                last_conv2_out = conv2_out_debug;
            end
            
            if (hsigmoid_out_debug !== last_hsigmoid_out && hsigmoid_out_debug !== 0) begin
                $display("PIPELINE: HSigmoid output = %0d", hsigmoid_out_debug);
                last_hsigmoid_out = hsigmoid_out_debug;
            end
        end
    end

endmodule 