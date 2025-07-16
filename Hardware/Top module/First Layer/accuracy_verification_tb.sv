`timescale 1ns / 1ps

`define imageSize 224*224
`define imageOUTSize 112*112*16  // 112x112 output with 16 channels

module accuracy_verification_tb();
    // Test parameters - must match accelerator parameters
    parameter N = 16;     // 16-bit precision (8 int, 8 frac)
    parameter Q = 8;      // Number of fractional bits
    parameter n = 224;    // Input image size (224x224)
    parameter k = 3;      // Convolution kernel size (3x3)
    parameter s = 2;      // Stride (s×s)
    parameter p = 1;      // Padding (added parameter)
    parameter IN_CHANNELS = 1;  // Number of input channels
    parameter OUT_CHANNELS = 16;    // Number of output channels
    
    // Calculated parameters
    localparam FEATURE_SIZE = n/s;
    localparam TOTAL_OUTPUTS = FEATURE_SIZE*FEATURE_SIZE*OUT_CHANNELS;
    
    // Signals for DUT interface
    reg clk;
    reg reset;
    reg en;
    wire [15:0] addr;
    wire [15:0] pixel;
    wire req;
    
    // Signals for image handler
    wire valid;
    wire [15:0] pixel_TB;
    
    // Output signals
    wire [N-1:0] data_out;
    wire valid_out;
    wire done;
    wire ready_for_data;
    
    // Internal memories for test data
    reg [N-1:0] conv_weights [0:k*k*IN_CHANNELS*OUT_CHANNELS-1];
    reg [N-1:0] bn_params [0:2*OUT_CHANNELS-1]; // Combined gamma and beta
    
    // Expected output memory
    reg [N-1:0] expected_outputs [0:TOTAL_OUTPUTS-1];
    
    // Files for output and analysis
    integer file1, hexFile, txt_file, analysis_file, error_file, stats_file;
    integer receivedData = 0;
    integer sentSize = 0;
    integer j;
    
    // Flag to prevent repeated output saving
    reg all_outputs_saved = 0;
    
    // Timeout counter
    integer timeout_counter = 0;
    localparam TIMEOUT_LIMIT = 10000000; // 10M cycles
    
    // Statistics for analysis
    integer nonzero_outputs = 0;
    reg [N-1:0] max_value = 0;
    reg [N-1:0] min_value = 16'hFFFF;
    integer channel_counts[0:OUT_CHANNELS-1];
    
    // Accuracy verification variables
    integer total_errors = 0;
    integer exact_matches = 0;
    integer close_matches = 0;  // Within 1 LSB
    integer acceptable_matches = 0;  // Within 2 LSB
    integer large_errors = 0;   // > 4 LSB difference
    
    // Error tracking arrays
    reg [N-1:0] actual_values [0:TOTAL_OUTPUTS-1];
    reg [N-1:0] expected_values [0:TOTAL_OUTPUTS-1];
    reg [N-1:0] error_values [0:TOTAL_OUTPUTS-1];
    reg [31:0] error_positions [0:999];  // Track first 1000 error positions
    integer error_count = 0;
    
    // Statistical analysis
    real mean_error = 0.0;
    real max_error = 0.0;
    real min_error = 0.0;
    real error_variance = 0.0;
    real error_sum = 0.0;
    real error_sum_sq = 0.0;
    
    // Channel-wise error analysis
    integer channel_errors [0:OUT_CHANNELS-1];
    real channel_mean_errors [0:OUT_CHANNELS-1];
    real channel_max_errors [0:OUT_CHANNELS-1];
    
    // Debug variables
    integer i;
    
    // Initialize statistics
    initial begin
        for (i = 0; i < OUT_CHANNELS; i = i + 1) begin
            channel_counts[i] = 0;
            channel_errors[i] = 0;
            channel_mean_errors[i] = 0.0;
            channel_max_errors[i] = 0.0;
        end
    end
    
    // Instantiate the accelerator module
    accelerator #(
        .N(N), 
        .Q(Q), 
        .n(n), 
        .k(k), 
        .s(s),
        .p(p),
        .IN_CHANNELS(IN_CHANNELS), 
        .OUT_CHANNELS(OUT_CHANNELS)
    ) dut (
        .clk(clk),
        .rst(reset),
        .en(en),
        .pixel(pixel),
        .data_out(data_out),
        .valid_out(valid_out),
        .done(done),
        .ready_for_data(ready_for_data)
    );
    
    // Instantiate the image handler
    image_handler_send uut (
        .clk(clk),
        .rst(reset),
        .pixel(pixel_TB),
        .valid(valid)
    );
    
    // Connect image handler to accelerator
    assign pixel = pixel_TB;
    
    // Clock generation
    initial begin
        clk = 1'b0;
        forever begin
            #5 clk = ~clk;
        end
    end
    
    // Simulation timeout to prevent infinite loops
    always @(posedge clk) begin
        timeout_counter <= timeout_counter + 1;
        
        if (timeout_counter >= TIMEOUT_LIMIT) begin
            $display("ERROR: Simulation timeout reached after %0d cycles. Possible infinite loop or stall.", TIMEOUT_LIMIT);
            $display("Final state: receivedData=%0d, expectedOutputs=%0d", receivedData, TOTAL_OUTPUTS);
            $finish;
        end
        
        // Clear timeout when done is asserted
        if (done) begin
            timeout_counter <= 0;
        end
        
        // Monitor for extra outputs
        if (valid_out && receivedData >= TOTAL_OUTPUTS) begin
            $display("WARNING: Received more outputs than expected! Got %0d, expected %0d", 
                     receivedData+1, TOTAL_OUTPUTS);
        end
    end
    
    // Main test procedure
    initial begin
        // Initialize signals
        reset = 0;
        en = 0;
        
        // Load weights and parameters
        $display("Loading test data from memory files...");
        $readmemb("memory/conv1.mem", conv_weights);
        $readmemb("memory/bn1.mem", bn_params);
        
        // Load expected outputs
        $display("Loading expected outputs from hs1_op_fixed.mem...");
        $readmemb("memory/hs1_op_fixed.mem", expected_outputs);
        
        // Open output files
        file1 = $fopen("output_results.bmp", "wb");
        hexFile = $fopen("output_results.hex", "w");
        txt_file = $fopen("output_results.txt", "w");
        analysis_file = $fopen("accuracy_analysis.txt", "w");
        error_file = $fopen("error_details.txt", "w");
        stats_file = $fopen("statistics.txt", "w");
        
        // Reset sequence
        #100;
        reset = 1;
        #100;
        reset = 0;
        #100;
        
        // Start accelerator
        $display("Starting accelerator processing...");
        en = 1;
        
        // Wait for processing to complete
        wait(done);
        
        $display("Processing completed!");
        
        // Perform accuracy analysis
        perform_accuracy_analysis();
        
        // Print comprehensive statistics
        print_comprehensive_statistics();
        
        // Close output files
        $fclose(file1);
        $fclose(hexFile);
        $fclose(txt_file);
        $fclose(analysis_file);
        $fclose(error_file);
        $fclose(stats_file);
        
        $display("Accuracy verification completed!");
        $stop;
    end
    
    // Capture and save outputs
    always @(posedge clk) begin
        if (valid_out && !all_outputs_saved) begin
            // Store actual value for comparison
            if (receivedData < TOTAL_OUTPUTS) begin
                actual_values[receivedData] = data_out;
                expected_values[receivedData] = expected_outputs[receivedData];
            end
            
            // Write to output files
            $fwrite(file1, "%c", data_out[7:0]);
            $fwrite(hexFile, "%04X\n", data_out);
            $fwrite(txt_file, "%04X\n", data_out);
            
            // Update statistics
            receivedData = receivedData + 1;
            
            // Track channel distribution
            if (data_out[0] !== 1'bx) begin  // Avoid X values
                channel_counts[dut.channel_out_reg] = channel_counts[dut.channel_out_reg] + 1;
                
                // Track non-zero outputs
                if (data_out != 0) begin
                    nonzero_outputs = nonzero_outputs + 1;
                    
                    // Update min/max
                    if (data_out > max_value) max_value = data_out;
                    if (data_out < min_value) min_value = data_out;
                end
            end
            
            // Display progress periodically
            if (receivedData % 10000 == 0 || receivedData == 1) begin
                $display("Output %0d/%0d: %h, non-zero count: %0d", 
                         receivedData, TOTAL_OUTPUTS, data_out, nonzero_outputs);
            end
            
            // Check if we've received all expected outputs
            if (receivedData >= TOTAL_OUTPUTS) begin
                if (!all_outputs_saved) begin
                    $display("All outputs received and saved! Total: %0d", receivedData);
                    all_outputs_saved = 1;
                end
            end
        end
    end
    
    // Task to perform comprehensive accuracy analysis
    task perform_accuracy_analysis;
        integer i;
        integer channel_idx;
        real error_val;
        real abs_error;
        real channel_error_sum;
        
        $display("Performing accuracy analysis...");
        
        // Initialize error tracking
        error_sum = 0.0;
        error_sum_sq = 0.0;
        max_error = 0.0;
        min_error = 0.0;
        
        for (i = 0; i < OUT_CHANNELS; i = i + 1) begin
            channel_error_sum = 0.0;
            channel_errors[i] = 0;
        end
        
        // Compare each output
        for (i = 0; i < TOTAL_OUTPUTS && i < receivedData; i = i + 1) begin
            // Calculate error
            error_val = $signed(actual_values[i]) - $signed(expected_values[i]);
            abs_error = (error_val < 0) ? -error_val : error_val;
            
            // Store error value
            error_values[i] = error_val;
            
            // Update global statistics
            error_sum = error_sum + abs_error;
            error_sum_sq = error_sum_sq + (abs_error * abs_error);
            
            if (abs_error > max_error) max_error = abs_error;
            if (i == 0 || abs_error < min_error) min_error = abs_error;
            
            // Categorize errors
            if (abs_error == 0) begin
                exact_matches = exact_matches + 1;
            end else if (abs_error <= 1) begin
                close_matches = close_matches + 1;
            end else if (abs_error <= 2) begin
                acceptable_matches = acceptable_matches + 1;
            end else if (abs_error > 4) begin
                large_errors = large_errors + 1;
            end
            
            if (abs_error > 0) begin
                total_errors = total_errors + 1;
                
                // Track error position (first 1000)
                if (error_count < 1000) begin
                    error_positions[error_count] = i;
                    error_count = error_count + 1;
                end
                
                // Channel-wise analysis
                channel_idx = i % OUT_CHANNELS;
                channel_errors[channel_idx] = channel_errors[channel_idx] + 1;
                channel_error_sum = channel_error_sum + abs_error;
                
                if (abs_error > channel_max_errors[channel_idx]) begin
                    channel_max_errors[channel_idx] = abs_error;
                end
            end
        end
        
        // Calculate final statistics
        mean_error = error_sum / TOTAL_OUTPUTS;
        error_variance = (error_sum_sq / TOTAL_OUTPUTS) - (mean_error * mean_error);
        
        // Calculate channel-wise mean errors
        for (i = 0; i < OUT_CHANNELS; i = i + 1) begin
            if (channel_errors[i] > 0) begin
                channel_mean_errors[i] = channel_error_sum / channel_counts[i];
            end
        end
        
        // Write detailed analysis to files
        write_analysis_files();
    endtask
    
    // Task to write analysis files
    task write_analysis_files;
        integer i;
        integer error_idx;
        
        // Write main analysis file
        $fwrite(analysis_file, "ACCURACY VERIFICATION ANALYSIS\n");
        $fwrite(analysis_file, "================================\n\n");
        
        $fwrite(analysis_file, "SUMMARY STATISTICS:\n");
        $fwrite(analysis_file, "Total outputs processed: %0d\n", receivedData);
        $fwrite(analysis_file, "Expected outputs: %0d\n", TOTAL_OUTPUTS);
        $fwrite(analysis_file, "Exact matches: %0d (%.2f%%)\n", exact_matches, exact_matches * 100.0 / TOTAL_OUTPUTS);
        $fwrite(analysis_file, "Close matches (≤1 LSB): %0d (%.2f%%)\n", close_matches, close_matches * 100.0 / TOTAL_OUTPUTS);
        $fwrite(analysis_file, "Acceptable matches (≤2 LSB): %0d (%.2f%%)\n", acceptable_matches, acceptable_matches * 100.0 / TOTAL_OUTPUTS);
        $fwrite(analysis_file, "Large errors (>4 LSB): %0d (%.2f%%)\n", large_errors, large_errors * 100.0 / TOTAL_OUTPUTS);
        $fwrite(analysis_file, "Total errors: %0d (%.2f%%)\n", total_errors, total_errors * 100.0 / TOTAL_OUTPUTS);
        
        $fwrite(analysis_file, "\nERROR STATISTICS:\n");
        $fwrite(analysis_file, "Mean absolute error: %.4f LSB\n", mean_error);
        $fwrite(analysis_file, "Error variance: %.4f\n", error_variance);
        $fwrite(analysis_file, "Error standard deviation: %.4f LSB\n", $sqrt(error_variance));
        $fwrite(analysis_file, "Maximum error: %.4f LSB\n", max_error);
        $fwrite(analysis_file, "Minimum error: %.4f LSB\n", min_error);
        
        $fwrite(analysis_file, "\nCHANNEL-WISE ANALYSIS:\n");
        for (i = 0; i < OUT_CHANNELS; i = i + 1) begin
            $fwrite(analysis_file, "Channel %0d: %0d errors (%.2f%%), mean error: %.4f, max error: %.4f\n", 
                   i, channel_errors[i], channel_errors[i] * 100.0 / channel_counts[i], 
                   channel_mean_errors[i], channel_max_errors[i]);
        end
        
        // Write error details file
        $fwrite(error_file, "DETAILED ERROR ANALYSIS\n");
        $fwrite(error_file, "=======================\n\n");
        
        $fwrite(error_file, "First 1000 error positions and values:\n");
        for (i = 0; i < error_count && i < 1000; i = i + 1) begin
            error_idx = error_positions[i];
            $fwrite(error_file, "Position %0d: Expected=%04X, Actual=%04X, Error=%d\n", 
                   error_idx, expected_values[error_idx], actual_values[error_idx], error_values[error_idx]);
        end
        
        // Write statistics file
        $fwrite(stats_file, "COMPREHENSIVE STATISTICS\n");
        $fwrite(stats_file, "========================\n\n");
        
        $fwrite(stats_file, "OUTPUT STATISTICS:\n");
        $fwrite(stats_file, "Total outputs: %0d\n", receivedData);
        $fwrite(stats_file, "Non-zero outputs: %0d (%.2f%%)\n", nonzero_outputs, nonzero_outputs * 100.0 / receivedData);
        $fwrite(stats_file, "Min value: %h\n", min_value);
        $fwrite(stats_file, "Max value: %h\n", max_value);
        
        $fwrite(stats_file, "\nCHANNEL DISTRIBUTION:\n");
        for (i = 0; i < OUT_CHANNELS; i = i + 1) begin
            $fwrite(stats_file, "Channel %0d: %0d outputs\n", i, channel_counts[i]);
        end
        
        $fwrite(stats_file, "\nACCURACY METRICS:\n");
        $fwrite(stats_file, "Overall accuracy: %.4f%%\n", (exact_matches + close_matches) * 100.0 / TOTAL_OUTPUTS);
        $fwrite(stats_file, "Precision: %.4f%%\n", exact_matches * 100.0 / TOTAL_OUTPUTS);
        $fwrite(stats_file, "Error rate: %.4f%%\n", total_errors * 100.0 / TOTAL_OUTPUTS);
    endtask
    
    // Task to print comprehensive statistics
    task print_comprehensive_statistics;
        $display("\n" + "="*60);
        $display("ACCURACY VERIFICATION RESULTS");
        $display("="*60);
        
        $display("OUTPUT SUMMARY:");
        $display("  Total outputs: %0d", receivedData);
        $display("  Non-zero outputs: %0d (%.2f%%)", nonzero_outputs, nonzero_outputs * 100.0 / receivedData);
        $display("  Min value: %h", min_value);
        $display("  Max value: %h", max_value);
        
        $display("\nACCURACY ANALYSIS:");
        $display("  Exact matches: %0d (%.2f%%)", exact_matches, exact_matches * 100.0 / TOTAL_OUTPUTS);
        $display("  Close matches (≤1 LSB): %0d (%.2f%%)", close_matches, close_matches * 100.0 / TOTAL_OUTPUTS);
        $display("  Acceptable matches (≤2 LSB): %0d (%.2f%%)", acceptable_matches, acceptable_matches * 100.0 / TOTAL_OUTPUTS);
        $display("  Large errors (>4 LSB): %0d (%.2f%%)", large_errors, large_errors * 100.0 / TOTAL_OUTPUTS);
        $display("  Total errors: %0d (%.2f%%)", total_errors, total_errors * 100.0 / TOTAL_OUTPUTS);
        
        $display("\nERROR STATISTICS:");
        $display("  Mean absolute error: %.4f LSB", mean_error);
        $display("  Error standard deviation: %.4f LSB", $sqrt(error_variance));
        $display("  Maximum error: %.4f LSB", max_error);
        $display("  Minimum error: %.4f LSB", min_error);
        
        $display("\nOVERALL ASSESSMENT:");
        if (exact_matches * 100.0 / TOTAL_OUTPUTS > 95.0) begin
            $display("  ✓ EXCELLENT: >95%% exact matches");
        end else if (exact_matches * 100.0 / TOTAL_OUTPUTS > 90.0) begin
            $display("  ✓ GOOD: >90%% exact matches");
        end else if (exact_matches * 100.0 / TOTAL_OUTPUTS > 80.0) begin
            $display("  ⚠ ACCEPTABLE: >80%% exact matches");
        end else begin
            $display("  ✗ NEEDS IMPROVEMENT: <80%% exact matches");
        end
        
        if (mean_error < 1.0) begin
            $display("  ✓ LOW ERROR: Mean error < 1 LSB");
        end else if (mean_error < 2.0) begin
            $display("  ✓ MODERATE ERROR: Mean error < 2 LSB");
        end else begin
            $display("  ⚠ HIGH ERROR: Mean error >= 2 LSB");
        end
        
        $display("\nChannel distribution:");
        for (i = 0; i < OUT_CHANNELS; i = i + 1) begin
            $display("  Channel %0d: %0d outputs, %0d errors (%.2f%%)", 
                   i, channel_counts[i], channel_errors[i], 
                   channel_errors[i] * 100.0 / channel_counts[i]);
        end
        
        $display("\n" + "="*60);
        $display("Analysis files generated:");
        $display("  - accuracy_analysis.txt: Main analysis report");
        $display("  - error_details.txt: Detailed error information");
        $display("  - statistics.txt: Comprehensive statistics");
        $display("="*60);
    endtask

endmodule
