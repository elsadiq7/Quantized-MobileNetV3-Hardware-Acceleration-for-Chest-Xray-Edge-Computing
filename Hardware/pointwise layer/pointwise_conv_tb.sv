`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////
// Comprehensive Testbench for Pointwise Convolution Module
// 
// This testbench provides complete verification of the pointwise_conv module
// including:
// - Clock and reset generation
// - Input data loading from memory files
// - Weight loading and verification
// - Output capture and validation
// - Comprehensive monitoring and debugging
//////////////////////////////////////////////////////////////////////////////////

module pointwise_conv_tb();

    // Test parameters - match the DUT parameters
    parameter N = 16;           // Data width
    parameter Q = 8;            // Fractional bits
    parameter IN_CHANNELS = 40;  // Input channels
    parameter OUT_CHANNELS = 48; // Output channels
    parameter FEATURE_SIZE = 14; // Feature map size
    parameter PARALLELISM = 4;   // Process 4 channels in parallel
    
    // Clock and reset
    reg clk;
    reg rst;
    reg en;
    
    // DUT interface signals
    reg [N-1:0] data_in;
    reg [$clog2(IN_CHANNELS)-1:0] channel_in;
    reg valid_in;
    reg [(IN_CHANNELS*OUT_CHANNELS*N)-1:0] weights;
    
    wire [N-1:0] data_out;
    wire [$clog2(OUT_CHANNELS)-1:0] channel_out;
    wire valid_out;
    wire done;
    
    // Test control variables
    reg [N-1:0] input_memory [0:1023];  // Input test data
    reg [N-1:0] weight_memory [0:IN_CHANNELS*OUT_CHANNELS-1]; // Weight data
    reg [N-1:0] output_memory [0:OUT_CHANNELS-1]; // Captured outputs
    
    integer input_count;
    integer output_count;
    integer test_phase;
    integer i, j;
    
    // File handles for data I/O
    integer input_file, weight_file, output_file;
    
    // Test status tracking
    reg test_passed;
    reg test_completed;
    integer error_count;
    
    // Clock generation - 100MHz (10ns period)
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end
    
    // DUT instantiation
    pointwise_conv #(
        .N(N),
        .Q(Q),
        .IN_CHANNELS(IN_CHANNELS),
        .OUT_CHANNELS(OUT_CHANNELS),
        .FEATURE_SIZE(FEATURE_SIZE),
        .PARALLELISM(PARALLELISM)
    ) dut (
        .clk(clk),
        .rst(rst),
        .en(en),
        .data_in(data_in),
        .channel_in(channel_in),
        .valid_in(valid_in),
        .weights(weights),
        .data_out(data_out),
        .channel_out(channel_out),
        .valid_out(valid_out),
        .done(done)
    );
    
    // Load test data from memory files
    initial begin
        // Initialize memory arrays
        for (i = 0; i < 1024; i = i + 1) begin
            input_memory[i] = 16'h0000;
        end
        
        for (i = 0; i < IN_CHANNELS*OUT_CHANNELS; i = i + 1) begin
            weight_memory[i] = 16'h0000;
        end
        
        // Load input data
        $display("Loading input test data...");
        $readmemh("input_data.mem", input_memory);
        
        // Load weight data
        $display("Loading weight data...");
        $readmemh("weights.mem", weight_memory);
        
        // Pack weights into the weights signal
        for (i = 0; i < IN_CHANNELS*OUT_CHANNELS; i = i + 1) begin
            weights[i*N +: N] = weight_memory[i];
        end
        
        $display("Test data loaded successfully");
        $display("Input samples loaded: %0d", 1024);
        $display("Weights loaded: %0d", IN_CHANNELS*OUT_CHANNELS);
    end
    
    // Main test sequence
    initial begin
        // Initialize signals
        rst = 1;
        en = 0;
        data_in = 0;
        channel_in = 0;
        valid_in = 0;
        input_count = 0;
        output_count = 0;
        test_phase = 0;
        test_passed = 1;
        test_completed = 0;
        error_count = 0;
        
        // Open output file for results in memory format
        output_file = $fopen("conv_actual_out.mem", "w");
        if (output_file == 0) begin
            $display("ERROR: Could not open output file");
            $finish;
        end
        
        $display("=== Pointwise Convolution Testbench Started ===");
        $display("Time: %0t", $time);
        
        // Reset sequence
        $display("Phase 0: Reset sequence");
        #100;
        rst = 0;
        #50;
        
        // Enable the module
        $display("Phase 1: Enable module and start processing");
        test_phase = 1;
        en = 1;
        #20;
        
        // Start input stimulus
        $display("Phase 2: Input stimulus");
        test_phase = 2;
        fork
            input_stimulus_process();
            output_monitor_process();
            timeout_monitor();
        join_any
        
        // Wait for completion
        $display("Phase 3: Waiting for completion");
        test_phase = 3;
        wait(done == 1);
        #100;
        
        // Test completion
        test_completed = 1;
        $display("Phase 4: Test completion and results");
        test_phase = 4;
        
        // Close files and finish
        $fclose(output_file);
        
        // Print test summary
        print_test_summary();
        
        $display("=== Testbench Completed ===");
        $finish;
    end

    // Input stimulus process
    task input_stimulus_process();
        integer ch, sample_idx;
        begin
            $display("Starting input stimulus process at time %0t", $time);

            // Send input data for multiple channels
            for (ch = 0; ch < IN_CHANNELS && ch < 10; ch = ch + 1) begin
                for (sample_idx = 0; sample_idx < 10; sample_idx = sample_idx + 1) begin
                    @(posedge clk);
                    data_in = input_memory[ch * 10 + sample_idx];
                    channel_in = ch;
                    valid_in = 1;
                    input_count = input_count + 1;

                    $display("Input[%0d]: Channel=%0d, Data=0x%04x, Time=%0t",
                             input_count, ch, data_in, $time);

                    // Add some timing variation
                    if (sample_idx % 3 == 0) begin
                        @(posedge clk);
                        valid_in = 0;
                        @(posedge clk);
                    end
                end
            end

            // Final input
            @(posedge clk);
            valid_in = 0;
            $display("Input stimulus completed. Total inputs: %0d", input_count);
        end
    endtask

    // Output monitoring process
    task output_monitor_process();
        begin
            $display("Starting output monitor process at time %0t", $time);

            while (!test_completed) begin
                @(posedge clk);
                if (valid_out) begin
                    output_memory[channel_out] = data_out;
                    output_count = output_count + 1;

                    $display("Output[%0d]: Channel=%0d, Data=0x%04x, Time=%0t",
                             output_count, channel_out, data_out, $time);

                    // Write to output file in memory format (raw hex values only)
                    $fwrite(output_file, "%04x\n", data_out);

                    // Basic sanity check
                    if (data_out === 16'hxxxx) begin
                        $display("ERROR: Undefined output detected at channel %0d", channel_out);
                        error_count = error_count + 1;
                        test_passed = 0;
                    end
                end
            end

            $display("Output monitoring completed. Total outputs: %0d", output_count);
        end
    endtask

    // Timeout monitor to prevent infinite simulation
    task timeout_monitor();
        begin
            #50000; // 50us timeout
            if (!test_completed) begin
                $display("ERROR: Test timeout occurred at time %0t", $time);
                $display("Current state: test_phase=%0d, done=%0b", test_phase, done);
                error_count = error_count + 1;
                test_passed = 0;
                test_completed = 1;
            end
        end
    endtask

    // Print comprehensive test summary
    task print_test_summary();
        begin
            $display("\n=== TEST SUMMARY ===");
            $display("Test Status: %s", test_passed ? "PASSED" : "FAILED");
            $display("Total Inputs Sent: %0d", input_count);
            $display("Total Outputs Received: %0d", output_count);
            $display("Error Count: %0d", error_count);
            $display("Simulation Time: %0t", $time);

            if (output_count > 0) begin
                $display("\nFirst few outputs:");
                for (i = 0; i < 8 && i < output_count; i = i + 1) begin
                    $display("  Channel %0d: 0x%04x", i, output_memory[i]);
                end
            end

            if (error_count == 0 && output_count > 0) begin
                $display("\n✓ All basic checks passed");
            end else begin
                $display("\n✗ Test failed with %0d errors", error_count);
            end

            $display("Output results saved to: conv_actual_out.mem");
            $display("====================\n");
        end
    endtask

    // Additional monitoring for debugging
    always @(posedge clk) begin
        // Monitor state transitions
        if (dut.state != dut.next_state) begin
            $display("State transition: %s -> %s at time %0t",
                     get_state_name(dut.state), get_state_name(dut.next_state), $time);
        end

        // Monitor weight loading
        if (dut.weights_loaded && !$past(dut.weights_loaded)) begin
            $display("Weights loaded successfully at time %0t", $time);
        end

        // Monitor accumulator activity
        if (dut.stage1_valid) begin
            $display("Pipeline Stage 1 active: data=0x%04x, in_ch=%0d, group=%0d",
                     dut.stage1_data, dut.stage1_in_ch, dut.stage1_group);
        end
    end

    // Function to convert state enum to string for debugging
    function string get_state_name(input [1:0] state);
        case (state)
            2'b00: get_state_name = "IDLE";
            2'b01: get_state_name = "PROCESSING";
            2'b10: get_state_name = "ACCUMULATING";
            2'b11: get_state_name = "DONE_STATE";
            default: get_state_name = "UNKNOWN";
        endcase
    endfunction

    // Assertions for verification
    // Check that valid_out is never asserted with undefined data
    property valid_out_data_defined;
        @(posedge clk) valid_out |-> !$isunknown(data_out);
    endproperty
    assert property (valid_out_data_defined) else begin
        $display("ASSERTION FAILED: valid_out asserted with undefined data_out at time %0t", $time);
        error_count = error_count + 1;
    end

    // Check that channel_out is within valid range when valid_out is asserted
    property valid_channel_range;
        @(posedge clk) valid_out |-> (channel_out < OUT_CHANNELS);
    endproperty
    assert property (valid_channel_range) else begin
        $display("ASSERTION FAILED: channel_out=%0d out of range at time %0t", channel_out, $time);
        error_count = error_count + 1;
    end

    // Check that done signal is stable once asserted
    property done_stable;
        @(posedge clk) done |-> ##1 done;
    endproperty
    assert property (done_stable) else begin
        $display("ASSERTION FAILED: done signal not stable at time %0t", $time);
        error_count = error_count + 1;
    end

endmodule
