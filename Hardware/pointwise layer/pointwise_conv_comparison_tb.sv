`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////
// Comparison Testbench for Original vs Optimized Pointwise Convolution
// 
// This testbench compares the functionality of both implementations to ensure
// the optimized version produces equivalent results with reduced LUT usage.
//////////////////////////////////////////////////////////////////////////////////

module pointwise_conv_comparison_tb();

    // Test parameters
    parameter N = 16;
    parameter Q = 8;
    parameter IN_CHANNELS = 40;
    parameter OUT_CHANNELS = 48;
    parameter FEATURE_SIZE = 14;
    parameter PARALLELISM_ORIG = 4;
    parameter PARALLELISM_OPT = 1;
    
    // Clock and reset
    reg clk;
    reg rst;
    reg en;
    
    // Common interface signals
    reg [N-1:0] data_in;
    reg [$clog2(IN_CHANNELS)-1:0] channel_in;
    reg valid_in;
    reg [(IN_CHANNELS*OUT_CHANNELS*N)-1:0] weights;
    
    // Original module outputs
    wire [N-1:0] data_out_orig;
    wire [$clog2(OUT_CHANNELS)-1:0] channel_out_orig;
    wire valid_out_orig;
    wire done_orig;
    
    // Optimized module outputs
    wire [N-1:0] data_out_opt;
    wire [$clog2(OUT_CHANNELS)-1:0] channel_out_opt;
    wire valid_out_opt;
    wire done_opt;
    
    // Test control variables
    reg [N-1:0] input_memory [0:1023];
    reg [N-1:0] weight_memory [0:IN_CHANNELS*OUT_CHANNELS-1];
    reg [N-1:0] output_memory_orig [0:OUT_CHANNELS-1];
    reg [N-1:0] output_memory_opt [0:OUT_CHANNELS-1];
    
    integer input_count;
    integer output_count_orig, output_count_opt;
    integer test_phase;
    integer i;
    
    // File handles
    integer output_file_orig, output_file_opt, comparison_file;
    
    // Test status
    reg test_passed;
    reg test_completed;
    integer error_count;
    integer mismatch_count;
    
    // Clock generation - 100MHz
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end
    
    // Original module instantiation
    pointwise_conv #(
        .N(N),
        .Q(Q),
        .IN_CHANNELS(IN_CHANNELS),
        .OUT_CHANNELS(OUT_CHANNELS),
        .FEATURE_SIZE(FEATURE_SIZE),
        .PARALLELISM(PARALLELISM_ORIG)
    ) dut_original (
        .clk(clk),
        .rst(rst),
        .en(en),
        .data_in(data_in),
        .channel_in(channel_in),
        .valid_in(valid_in),
        .weights(weights),
        .data_out(data_out_orig),
        .channel_out(channel_out_orig),
        .valid_out(valid_out_orig),
        .done(done_orig)
    );
    
    // Optimized module instantiation
    pointwise_conv_optimized #(
        .N(N),
        .Q(Q),
        .IN_CHANNELS(IN_CHANNELS),
        .OUT_CHANNELS(OUT_CHANNELS),
        .FEATURE_SIZE(FEATURE_SIZE),
        .PARALLELISM(PARALLELISM_OPT)
    ) dut_optimized (
        .clk(clk),
        .rst(rst),
        .en(en),
        .data_in(data_in),
        .channel_in(channel_in),
        .valid_in(valid_in),
        .weights(weights),
        .data_out(data_out_opt),
        .channel_out(channel_out_opt),
        .valid_out(valid_out_opt),
        .done(done_opt)
    );
    
    // Load test data
    initial begin
        // Initialize arrays
        for (i = 0; i < 1024; i = i + 1) begin
            input_memory[i] = 16'h0000;
        end
        
        for (i = 0; i < IN_CHANNELS*OUT_CHANNELS; i = i + 1) begin
            weight_memory[i] = 16'h0000;
        end
        
        // Load input and weight data
        $display("Loading test data for comparison...");
        $readmemh("input_data.mem", input_memory);
        $readmemh("weights.mem", weight_memory);
        
        // Pack weights
        for (i = 0; i < IN_CHANNELS*OUT_CHANNELS; i = i + 1) begin
            weights[i*N +: N] = weight_memory[i];
        end
        
        $display("Test data loaded for comparison test");
    end
    
    // Main test sequence
    initial begin
        // Initialize
        rst = 1;
        en = 0;
        data_in = 0;
        channel_in = 0;
        valid_in = 0;
        input_count = 0;
        output_count_orig = 0;
        output_count_opt = 0;
        test_phase = 0;
        test_passed = 1;
        test_completed = 0;
        error_count = 0;
        mismatch_count = 0;
        
        // Open output files
        output_file_orig = $fopen("conv_original_out.mem", "w");
        output_file_opt = $fopen("conv_optimized_out.mem", "w");
        comparison_file = $fopen("comparison_results.txt", "w");
        
        $display("=== Pointwise Convolution Comparison Test Started ===");
        
        // Reset sequence
        #100;
        rst = 0;
        #50;
        
        // Enable both modules
        en = 1;
        #20;
        
        // Start input stimulus
        fork
            input_stimulus_process();
            output_monitor_orig();
            output_monitor_opt();
            timeout_monitor();
        join_any
        
        // Wait for both modules to complete
        wait(done_orig == 1 && done_opt == 1);
        #100;
        
        // Compare results
        compare_results();
        
        // Close files and finish
        $fclose(output_file_orig);
        $fclose(output_file_opt);
        $fclose(comparison_file);
        
        print_comparison_summary();
        $display("=== Comparison Test Completed ===");
        $finish;
    end
    
    // Input stimulus process
    task input_stimulus_process();
        integer ch, sample_idx;
        begin
            $display("Starting input stimulus for comparison test");
            
            for (ch = 0; ch < IN_CHANNELS && ch < 10; ch = ch + 1) begin
                for (sample_idx = 0; sample_idx < 10; sample_idx = sample_idx + 1) begin
                    @(posedge clk);
                    data_in = input_memory[ch * 10 + sample_idx];
                    channel_in = ch;
                    valid_in = 1;
                    input_count = input_count + 1;
                    
                    if (sample_idx % 3 == 0) begin
                        @(posedge clk);
                        valid_in = 0;
                        @(posedge clk);
                    end
                end
            end
            
            @(posedge clk);
            valid_in = 0;
            $display("Input stimulus completed for comparison");
        end
    endtask
    
    // Monitor original module output
    task output_monitor_orig();
        begin
            while (!test_completed) begin
                @(posedge clk);
                if (valid_out_orig) begin
                    output_memory_orig[channel_out_orig] = data_out_orig;
                    output_count_orig = output_count_orig + 1;
                    $fwrite(output_file_orig, "%04x\n", data_out_orig);
                end
            end
        end
    endtask
    
    // Monitor optimized module output
    task output_monitor_opt();
        begin
            while (!test_completed) begin
                @(posedge clk);
                if (valid_out_opt) begin
                    output_memory_opt[channel_out_opt] = data_out_opt;
                    output_count_opt = output_count_opt + 1;
                    $fwrite(output_file_opt, "%04x\n", data_out_opt);
                end
            end
        end
    endtask
    
    // Timeout monitor
    task timeout_monitor();
        begin
            #100000; // 100us timeout
            if (!test_completed) begin
                $display("ERROR: Comparison test timeout");
                error_count = error_count + 1;
                test_passed = 0;
                test_completed = 1;
            end
        end
    endtask
    
    // Compare results between original and optimized
    task compare_results();
        begin
            $display("\n=== COMPARING RESULTS ===");
            $fwrite(comparison_file, "Channel,Original,Optimized,Match\n");
            
            for (i = 0; i < OUT_CHANNELS; i = i + 1) begin
                if (output_memory_orig[i] !== output_memory_opt[i]) begin
                    mismatch_count = mismatch_count + 1;
                    $display("MISMATCH Channel %0d: Original=0x%04x, Optimized=0x%04x", 
                             i, output_memory_orig[i], output_memory_opt[i]);
                    $fwrite(comparison_file, "%0d,0x%04x,0x%04x,NO\n", 
                            i, output_memory_orig[i], output_memory_opt[i]);
                end else begin
                    $fwrite(comparison_file, "%0d,0x%04x,0x%04x,YES\n", 
                            i, output_memory_orig[i], output_memory_opt[i]);
                end
            end
            
            if (mismatch_count == 0) begin
                $display("✓ All outputs match between original and optimized versions");
            end else begin
                $display("✗ %0d mismatches found between versions", mismatch_count);
                test_passed = 0;
            end
        end
    endtask
    
    // Print comparison summary
    task print_comparison_summary();
        begin
            $display("\n=== COMPARISON SUMMARY ===");
            $display("Original Module Outputs: %0d", output_count_orig);
            $display("Optimized Module Outputs: %0d", output_count_opt);
            $display("Mismatches: %0d", mismatch_count);
            $display("Test Status: %s", test_passed ? "PASSED" : "FAILED");
            $display("========================\n");
        end
    endtask

endmodule
