`timescale 1ns / 1ps

module chest_xray_classifier_tb;

    // Parameters for the integrated system
    parameter WIDTH = 16;
    parameter FRAC = 8;
    parameter NUM_CLASSES = 15;
    parameter CLK_PERIOD = 10; // 100MHz clock
    
    // Test image parameters (smaller for simulation)
    parameter TEST_IMAGE_SIZE = 224;
    parameter TEST_PIXELS = TEST_IMAGE_SIZE * TEST_IMAGE_SIZE; // 50,176 pixels
    
    // Testbench signals
    reg clk;
    reg rst;
    reg en;
    
    // Image input signals
    reg [15:0] pixel_in;
    reg pixel_valid;
    
    // Weight loading signals
    reg [WIDTH-1:0] weight_data_in;
    reg [19:0] weight_addr_in; // Large enough for biggest weight array
    reg weight_valid_in;
    reg [3:0] weight_type_select;
    
    // Accelerator weight interface
    wire [WIDTH-1:0] acc_weight_data;
    wire [WIDTH-1:0] acc_bn_data;
    wire [7:0] acc_weight_addr;
    wire [5:0] acc_bn_addr;
    wire acc_weight_en;
    wire acc_bn_en;
    
    // Final layer weights - REMOVED: Now handled internally by weight memory manager
    // The massive weight arrays are no longer exposed as I/O ports
    
    // DDR4 AXI4 interface signals
    wire [31:0] m_axi_araddr;
    wire [7:0] m_axi_arlen;
    wire [2:0] m_axi_arsize;
    wire [1:0] m_axi_arburst;
    wire m_axi_arvalid;
    wire m_axi_arready;
    wire [511:0] m_axi_rdata;
    wire [1:0] m_axi_rresp;
    wire m_axi_rlast;
    wire m_axi_rvalid;
    wire m_axi_rready;
    
    // Weight request interface signals
    wire [31:0] weight_request_addr;
    wire [3:0] weight_request_type;
    wire weight_request_valid;
    wire [WIDTH-1:0] weight_response_data;
    wire weight_response_valid;
    
    // System outputs
    wire signed [WIDTH-1:0] classification_result [0:NUM_CLASSES-1];
    wire classification_valid;
    wire processing_done;
    wire ready_for_image;
    
    // Weight memory manager signals
    wire weights_loaded;
    wire memory_ready;
    
    // Test control variables
    integer test_phase;
    integer pixel_count;
    integer cycle_count;
    integer test_case;
    integer error_count;
    integer success_count;
    
    // Test image memory
    reg [15:0] test_image [0:TEST_PIXELS-1];
    
    // Expected results for validation
    reg [WIDTH-1:0] expected_results [0:4][0:NUM_CLASSES-1]; // 5 test cases
    
    // Timing measurement
    integer start_time, end_time, processing_cycles;
    
    // Performance counters
    integer total_cycles;
    integer accelerator_cycles;
    integer bottleneck_cycles;
    integer final_layer_cycles;
    
    // =====================================================================
    // CLOCK GENERATION
    // =====================================================================
    initial begin
        clk = 0;
        forever #(CLK_PERIOD/2) clk = ~clk;
    end
    
    // =====================================================================
    // MODULE INSTANTIATIONS
    // =====================================================================
    
    // Weight Memory Manager
    weight_memory_manager #(
        .WIDTH(WIDTH),
        .FRAC(FRAC),
        .NUM_CLASSES(NUM_CLASSES)
    ) weight_mgr_inst (
        .clk(clk),
        .rst(rst),
        .en(en),
        .weight_data_in(weight_data_in),
        .weight_addr_in(weight_addr_in),
        .weight_valid_in(weight_valid_in),
        .weight_type_select(weight_type_select),
        .acc_weight_data(acc_weight_data),
        .acc_bn_data(acc_bn_data),
        .acc_weight_addr(acc_weight_addr),
        .acc_bn_addr(acc_bn_addr),
        .acc_weight_en(acc_weight_en),
        .acc_bn_en(acc_bn_en),
        
        // DDR4 AXI4 interface (tied off for simulation)
        .ddr_araddr(m_axi_araddr),
        .ddr_arlen(m_axi_arlen),
        .ddr_arsize(m_axi_arsize),
        .ddr_arburst(m_axi_arburst),
        .ddr_arvalid(m_axi_arvalid),
        .ddr_arready(1'b0),
        .ddr_rdata(512'h0),
        .ddr_rresp(2'b00),
        .ddr_rlast(1'b0),
        .ddr_rvalid(1'b0),
        .ddr_rready(m_axi_rready),
        
        // Final layer weight interface - FIXED: Using new weight memory interface
        .final_weight_addr(),  // Connected internally to final layer
        .final_weight_req(),   // Connected internally to final layer
        .final_weight_data(),  // Connected internally to final layer
        .final_weight_valid(), // Connected internally to final layer
        .final_weight_type(),  // Connected internally to final layer
        
        // Weight request interface (tied off for simulation)
        .weight_request_addr(32'h0),
        .weight_request_type(4'h0),
        .weight_request_valid(1'b0),
        .weight_response_data(weight_response_data),
        .weight_response_valid(weight_response_valid),
        
        .weights_loaded(weights_loaded),
        .memory_ready(memory_ready)
    );
    
    // Main DUT - Chest X-Ray Classifier
    chest_xray_classifier_top #(
        .WIDTH(WIDTH),
        .FRAC(FRAC),
        .NUM_CLASSES(NUM_CLASSES)
    ) dut (
        .clk(clk),
        .rst(rst),
        .en(en),
        .pixel_in(pixel_in),
        .pixel_valid(pixel_valid),
        
        // DDR4 AXI4 interface (tied off for simulation)
        .m_axi_araddr(m_axi_araddr),
        .m_axi_arlen(m_axi_arlen),
        .m_axi_arsize(m_axi_arsize),
        .m_axi_arburst(m_axi_arburst),
        .m_axi_arvalid(m_axi_arvalid),
        .m_axi_arready(1'b0),
        .m_axi_rdata(512'h0),
        .m_axi_rresp(2'b00),
        .m_axi_rlast(1'b0),
        .m_axi_rvalid(1'b0),
        .m_axi_rready(m_axi_rready),
        
        // Weight interfaces - FIXED: Only accelerator weights, final layer weights handled internally
        .acc_weight_data(acc_weight_data),
        .acc_bn_data(acc_bn_data),
        .acc_weight_addr(acc_weight_addr),
        .acc_bn_addr(acc_bn_addr),
        .acc_weight_en(acc_weight_en),
        .acc_bn_en(acc_bn_en),
        
        // Outputs
        .classification_result(classification_result),
        .classification_valid(classification_valid),
        .processing_done(processing_done),
        .ready_for_image(ready_for_image)
    );
    
    // =====================================================================
    // TEST INITIALIZATION AND SETUP
    // =====================================================================
    initial begin
        $display("==========================================================");
        $display("CHEST X-RAY CLASSIFIER COMPREHENSIVE TESTBENCH");
        $display("==========================================================");
        $display("Start Time: %0t", $time);
        
        // Initialize signals
        rst = 1;
        en = 0;
        pixel_in = 0;
        pixel_valid = 0;
        weight_data_in = 0;
        weight_addr_in = 0;
        weight_valid_in = 0;
        weight_type_select = 0;
        
        // Initialize counters
        test_phase = 0;
        pixel_count = 0;
        cycle_count = 0;
        test_case = 0;
        error_count = 0;
        success_count = 0;
        total_cycles = 0;
        
        // Wait for clock stabilization
        repeat(10) @(posedge clk);
        
        // Release reset
        rst = 0;
        @(posedge clk);
        
        $display("System initialized. Starting test sequence...");
        $display("");
        
        // Run test sequence
        run_comprehensive_tests();
        
        // Final report
        generate_final_report();
        
        $finish;
    end
    
    // =====================================================================
    // MAIN TEST SEQUENCE
    // =====================================================================
    task run_comprehensive_tests();
        begin
            $display("=== COMPREHENSIVE TEST SEQUENCE START ===");
            
            // Test 1: Basic system initialization
            test_system_initialization();
            
            // Test 2: Weight loading verification
            test_weight_loading();
            
            // Test 3: Single image classification
            test_single_image_classification();
            
            // Test 4: Multiple image processing
            test_multiple_image_processing();
            
            // Test 5: Stress test with rapid inputs
            test_stress_conditions();
            
            // Test 6: Edge cases and error conditions
            test_edge_cases();
            
            $display("=== COMPREHENSIVE TEST SEQUENCE COMPLETE ===");
        end
    endtask
    
    // =====================================================================
    // TEST 1: SYSTEM INITIALIZATION
    // =====================================================================
    task test_system_initialization();
        begin
            $display("Test 1: System Initialization");
            $display("------------------------------");
            test_phase = 1;
            
            // Enable system
            en = 1;
            @(posedge clk);
            
            // Wait for initialization
            repeat(100) @(posedge clk);
            
            // Check initial state
            if (ready_for_image === 1'bx || ready_for_image === 1'bz) begin
                $display("ERROR: ready_for_image signal is undefined");
                error_count++;
            end else begin
                $display("✓ System initialization successful");
                success_count++;
            end
            
            $display("Test 1 Complete\n");
        end
    endtask
    
    // =====================================================================
    // TEST 2: WEIGHT LOADING
    // =====================================================================
    task test_weight_loading();
        begin
            $display("Test 2: Weight Loading Verification");
            $display("-----------------------------------");
            test_phase = 2;
            
            // Load accelerator weights
            load_test_weights(4'h0, 144);  // Accelerator conv weights
            load_test_weights(4'h1, 32);   // Accelerator BN weights
            
            // Load final layer weights (simplified)
            load_test_weights(4'h2, 1000); // Sample of final layer weights
            
            // Wait for weight loading completion
            wait_for_condition("weights_loaded", 10000);
            
            if (weights_loaded && memory_ready) begin
                $display("✓ Weight loading completed successfully");
                success_count++;
            end else begin
                $display("ERROR: Weight loading failed");
                error_count++;
            end
            
            $display("Test 2 Complete\n");
        end
    endtask
    
    // =====================================================================
    // TEST 3: SINGLE IMAGE CLASSIFICATION
    // =====================================================================
    task test_single_image_classification();
        begin
            $display("Test 3: Single Image Classification");
            $display("------------------------------------");
            test_phase = 3;
            test_case = 0;
            
            // Generate test image
            generate_test_image(0);
            
            // Wait for system ready
            wait_for_condition("ready_for_image", 1000);
            
            // Measure start time
            start_time = cycle_count;
            
            // Feed image data
            feed_image_data();
            
            // Wait for processing completion
            wait_for_condition("processing_done", 50000);
            
            // Measure end time
            end_time = cycle_count;
            processing_cycles = end_time - start_time;
            
            // Validate results
            if (processing_done && classification_valid) begin
                $display("✓ Image classification completed in %0d cycles", processing_cycles);
                display_classification_results();
                success_count++;
            end else begin
                $display("ERROR: Image classification failed");
                error_count++;
            end
            
            $display("Test 3 Complete\n");
        end
    endtask
    
    // =====================================================================
    // TEST 4: MULTIPLE IMAGE PROCESSING
    // =====================================================================
    task test_multiple_image_processing();
        begin
            $display("Test 4: Multiple Image Processing");
            $display("----------------------------------");
            test_phase = 4;
            
            for (test_case = 0; test_case < 3; test_case++) begin
                $display("Processing test image %0d...", test_case);
                
                // Generate different test image
                generate_test_image(test_case);
                
                // Reset system for new image
                reset_for_new_image();
                
                // Process image
                feed_image_data();
                wait_for_condition("processing_done", 50000);
                
                if (processing_done && classification_valid) begin
                    $display("✓ Test image %0d processed successfully", test_case);
                    success_count++;
                end else begin
                    $display("ERROR: Test image %0d processing failed", test_case);
                    error_count++;
                end
            end
            
            $display("Test 4 Complete\n");
        end
    endtask
    
    // =====================================================================
    // TEST 5: STRESS CONDITIONS
    // =====================================================================
    task test_stress_conditions();
        begin
            $display("Test 5: Stress Test Conditions");
            $display("-------------------------------");
            test_phase = 5;
            
            // Test rapid enable/disable cycles
            for (int i = 0; i < 10; i++) begin
                en = 0;
                repeat(5) @(posedge clk);
                en = 1;
                repeat(5) @(posedge clk);
            end
            
            // Test with maximum frequency pixel input
            generate_test_image(0);
            feed_image_data_rapid();
            
            // Wait for completion
            wait_for_condition("processing_done", 100000);
            
            if (processing_done) begin
                $display("✓ Stress test completed successfully");
                success_count++;
            end else begin
                $display("ERROR: Stress test failed");
                error_count++;
            end
            
            $display("Test 5 Complete\n");
        end
    endtask
    
    // =====================================================================
    // TEST 6: EDGE CASES
    // =====================================================================
    task test_edge_cases();
        begin
            $display("Test 6: Edge Cases and Error Conditions");
            $display("---------------------------------------");
            test_phase = 6;
            
            // Test with all-zero image
            generate_zero_image();
            reset_for_new_image();
            feed_image_data();
            wait_for_condition("processing_done", 50000);
            
            if (processing_done) begin
                $display("✓ All-zero image processed");
                success_count++;
            end else begin
                $display("ERROR: All-zero image processing failed");
                error_count++;
            end
            
            // Test with maximum value image
            generate_max_image();
            reset_for_new_image();
            feed_image_data();
            wait_for_condition("processing_done", 50000);
            
            if (processing_done) begin
                $display("✓ Maximum value image processed");
                success_count++;
            end else begin
                $display("ERROR: Maximum value image processing failed");
                error_count++;
            end
            
            $display("Test 6 Complete\n");
        end
    endtask
    
    // =====================================================================
    // HELPER TASKS
    // =====================================================================
    
    task load_test_weights(input [3:0] weight_type, input integer count);
        begin
            $display("Loading %0d weights of type %0d", count, weight_type);
            weight_type_select = weight_type;
            
            for (int i = 0; i < count; i++) begin
                weight_data_in = $random & 16'hFFFF; // Random test data
                weight_addr_in = i;
                weight_valid_in = 1;
                @(posedge clk);
            end
            
            weight_valid_in = 0;
            @(posedge clk);
        end
    endtask
    
    task generate_test_image(input integer image_type);
        begin
            case (image_type)
                0: begin // Random image
                    for (int i = 0; i < TEST_PIXELS; i++) begin
                        test_image[i] = $random & 16'hFFFF;
                    end
                end
                1: begin // Gradient image
                    for (int i = 0; i < TEST_PIXELS; i++) begin
                        test_image[i] = i % 65536;
                    end
                end
                2: begin // Checkerboard pattern
                    for (int i = 0; i < TEST_PIXELS; i++) begin
                        test_image[i] = ((i / TEST_IMAGE_SIZE) + i) % 2 ? 16'hFFFF : 16'h0000;
                    end
                end
                default: begin
                    for (int i = 0; i < TEST_PIXELS; i++) begin
                        test_image[i] = 16'h8000; // Mid-value
                    end
                end
            endcase
        end
    endtask
    
    task generate_zero_image();
        begin
            for (int i = 0; i < TEST_PIXELS; i++) begin
                test_image[i] = 16'h0000;
            end
        end
    endtask
    
    task generate_max_image();
        begin
            for (int i = 0; i < TEST_PIXELS; i++) begin
                test_image[i] = 16'hFFFF;
            end
        end
    endtask
    
    task feed_image_data();
        begin
            pixel_count = 0;
            
            for (int i = 0; i < TEST_PIXELS; i++) begin
                pixel_in = test_image[i];
                pixel_valid = 1;
                @(posedge clk);
                pixel_count++;
                
                if (pixel_count % 10000 == 0) begin
                    $display("Fed %0d pixels", pixel_count);
                end
            end
            
            pixel_valid = 0;
            @(posedge clk);
            $display("Image feeding complete: %0d pixels", pixel_count);
        end
    endtask
    
    task feed_image_data_rapid();
        begin
            pixel_count = 0;
            
            for (int i = 0; i < TEST_PIXELS; i++) begin
                pixel_in = test_image[i];
                pixel_valid = 1;
                @(posedge clk);
                pixel_count++;
            end
            
            pixel_valid = 0;
            @(posedge clk);
        end
    endtask
    
    task reset_for_new_image();
        begin
            en = 0;
            repeat(10) @(posedge clk);
            en = 1;
            repeat(10) @(posedge clk);
        end
    endtask
    
    task wait_for_condition(input string condition, input integer timeout);
        integer wait_cycles;
        begin
            wait_cycles = 0;
            
            case (condition)
                "ready_for_image": begin
                    while (!ready_for_image && wait_cycles < timeout) begin
                        @(posedge clk);
                        wait_cycles++;
                    end
                end
                "processing_done": begin
                    while (!processing_done && wait_cycles < timeout) begin
                        @(posedge clk);
                        wait_cycles++;
                    end
                end
                "weights_loaded": begin
                    while (!weights_loaded && wait_cycles < timeout) begin
                        @(posedge clk);
                        wait_cycles++;
                    end
                end
            endcase
            
            if (wait_cycles >= timeout) begin
                $display("WARNING: Timeout waiting for %s", condition);
            end
        end
    endtask
    
    task display_classification_results();
        begin
            $display("Classification Results:");
            for (int i = 0; i < NUM_CLASSES; i++) begin
                $display("  Class[%2d]: 0x%04x (%0d)", i, classification_result[i], classification_result[i]);
            end
        end
    endtask
    
    task generate_final_report();
        begin
            $display("");
            $display("==========================================================");
            $display("FINAL TEST REPORT");
            $display("==========================================================");
            $display("Total Tests Passed: %0d", success_count);
            $display("Total Tests Failed: %0d", error_count);
            $display("Success Rate: %.1f%%", (success_count * 100.0) / (success_count + error_count));
            $display("Total Simulation Cycles: %0d", cycle_count);
            $display("Average Processing Cycles: %0d", processing_cycles);
            
            if (error_count == 0) begin
                $display("🎉 ALL TESTS PASSED! System is functioning correctly.");
            end else begin
                $display("❌ Some tests failed. Please review the errors above.");
            end
            
            $display("==========================================================");
            $display("End Time: %0t", $time);
        end
    endtask
    
    // =====================================================================
    // CONTINUOUS MONITORING
    // =====================================================================
    
    // Cycle counter
    always @(posedge clk) begin
        if (!rst) begin
            cycle_count <= cycle_count + 1;
            total_cycles <= total_cycles + 1;
        end else begin
            cycle_count <= 0;
        end
    end
    
    // Timeout protection
    initial begin
        #1000000000; // 1 second timeout
        $display("ERROR: Simulation timeout reached!");
        $finish;
    end
    
    // Monitor key signals
    always @(posedge clk) begin
        if (!rst && en) begin
            // Monitor for unexpected conditions
            if (classification_valid === 1'bx || classification_valid === 1'bz) begin
                $display("WARNING: classification_valid is undefined at time %0t", $time);
            end
            
            if (processing_done === 1'bx || processing_done === 1'bz) begin
                $display("WARNING: processing_done is undefined at time %0t", $time);
            end
        end
    end

endmodule 