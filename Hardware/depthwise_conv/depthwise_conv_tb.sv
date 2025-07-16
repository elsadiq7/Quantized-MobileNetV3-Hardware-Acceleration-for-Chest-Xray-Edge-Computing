`timescale 1ns / 1ps

//==============================================================================
// Comprehensive SystemVerilog Testbench for Depthwise Convolution Module
//==============================================================================
// 
// This testbench provides complete verification for the depthwise_conv module
// including input data loading, weight generation, convolution processing,
// and output verification with file I/O operations.
//
// Data Format:
// - 16-bit signed fixed-point (Q8.8 format: 8 integer bits, 8 fractional bits)
// - Input: 112x112 feature maps with 16 channels
// - Weights: 3x3 kernels for each channel
// - Output: 56x56 feature maps (due to stride=2)
//
// File Organization:
// - input_data.mem: Input feature map data (hex format)
// - weights.mem: Convolution weights (hex format) 
// - output_data.mem: Convolution results (hex format)
//
//==============================================================================

module depthwise_conv_tb;

    // Test parameters (matching Winograd DUT with stride=1)
    parameter N = 16;            // Data width
    parameter Q = 8;             // Fractional bits
    parameter IN_WIDTH = 112;    // Input feature map width
    parameter IN_HEIGHT = 112;   // Input feature map height
    parameter CHANNELS = 16;     // Number of channels
    parameter KERNEL_SIZE = 3;   // Kernel size (3x3)
    parameter STRIDE = 1;        // Stride (Winograd optimized for stride=1)
    parameter PADDING = 1;       // Padding
    parameter PARALLELISM = 1;   // Single channel processing
    
    // Calculated output dimensions
    localparam OUT_WIDTH = (IN_WIDTH + 2*PADDING - KERNEL_SIZE) / STRIDE + 1;  // 56
    localparam OUT_HEIGHT = (IN_HEIGHT + 2*PADDING - KERNEL_SIZE) / STRIDE + 1; // 56
    
    // Clock and reset
    reg clk;
    reg rst;
    reg en;
    
    // DUT interface signals
    reg [N-1:0] data_in;
    reg [$clog2(CHANNELS)-1:0] channel_in;
    reg valid_in;
    reg [(KERNEL_SIZE*KERNEL_SIZE*N)-1:0] weights;  // Optimized for single channel
    
    wire [N-1:0] data_out;
    wire [$clog2(CHANNELS)-1:0] channel_out;
    wire valid_out;
    wire done;
    
    // Test control variables
    reg [N-1:0] input_memory [0:IN_WIDTH*IN_HEIGHT*CHANNELS-1];
    reg [N-1:0] weight_memory [0:KERNEL_SIZE*KERNEL_SIZE*CHANNELS-1];
    reg [N-1:0] output_memory [0:OUT_WIDTH*OUT_HEIGHT*CHANNELS-1];
    
    // Counters and indices
    integer input_idx;
    integer output_idx;
    integer cycle_count;
    integer error_count;
    
    // File handles
    integer input_file, weight_file, output_file;

    // Track current channel group for dynamic weight loading
    integer current_ch_group = 0;
    
    //==========================================================================
    // Clock Generation
    //==========================================================================
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 100MHz clock (10ns period)
    end
    
    //==========================================================================
    // Device Under Test (DUT) Instantiation
    //==========================================================================
    depthwise_conv_winograd #(
        .N(N),
        .Q(Q),
        .IN_WIDTH(IN_WIDTH),
        .IN_HEIGHT(IN_HEIGHT),
        .CHANNELS(CHANNELS),
        .KERNEL_SIZE(KERNEL_SIZE),
        .STRIDE(STRIDE),
        .PADDING(PADDING),
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
    
    //==========================================================================
    // Test Data Generation and Loading Functions
    //==========================================================================
    
    // Function to convert real number to Q8.8 fixed-point format
    function [N-1:0] real_to_fixed(real value);
        real scaled_value;
        begin
            scaled_value = value * (1 << Q);
            if (scaled_value > 32767.0) scaled_value = 32767.0;
            if (scaled_value < -32768.0) scaled_value = -32768.0;
            real_to_fixed = $signed(int'(scaled_value));
        end
    endfunction
    
    // Function to convert Q8.8 fixed-point to real
    function real fixed_to_real([N-1:0] fixed_val);
        begin
            fixed_to_real = $signed(fixed_val) / real'(1 << Q);
        end
    endfunction
    
    // Task to generate test input data
    task generate_input_data();
        integer x, y, ch;
        real pixel_value;
        begin
            $display("Generating input test data...");
            
            for (ch = 0; ch < CHANNELS; ch++) begin
                for (y = 0; y < IN_HEIGHT; y++) begin
                    for (x = 0; x < IN_WIDTH; x++) begin
                        // Generate test pattern: checkerboard + gradient + channel offset
                        pixel_value = 0.5 * ((x + y + ch) % 2) + 
                                     0.3 * (x + y) / (IN_WIDTH + IN_HEIGHT) +
                                     0.2 * ch / CHANNELS;
                        
                        input_memory[ch*IN_WIDTH*IN_HEIGHT + y*IN_WIDTH + x] = 
                            real_to_fixed(pixel_value);
                    end
                end
            end
            
            $display("Input data generation completed.");
        end
    endtask
    
    // Task to generate convolution weights
    task generate_weights();
        integer ch, ky, kx;
        real weight_value;
        begin
            $display("Generating convolution weights...");
            
            for (ch = 0; ch < CHANNELS; ch++) begin
                for (ky = 0; ky < KERNEL_SIZE; ky++) begin
                    for (kx = 0; kx < KERNEL_SIZE; kx++) begin
                        // Generate different weight patterns for each channel
                        case (ch % 4)
                            0: weight_value = (ky == 1 && kx == 1) ? 1.0 : 0.0; // Identity
                            1: weight_value = 0.111; // Blur kernel
                            2: begin // Edge detection
                                if (ky == 1 && kx == 1) weight_value = 8.0/9.0;
                                else weight_value = -1.0/9.0;
                            end
                            3: weight_value = (kx + ky) * 0.1; // Gradient
                        endcase
                        
                        weight_memory[ch*KERNEL_SIZE*KERNEL_SIZE + ky*KERNEL_SIZE + kx] = 
                            real_to_fixed(weight_value);
                    end
                end
            end
            
            $display("Weight generation completed.");
        end
    endtask
    
    // Task to save input data to file
    task save_input_data();
        integer i;
        begin
            input_file = $fopen("input_data.mem", "w");
            if (input_file == 0) begin
                $display("ERROR: Could not open input_data.mem for writing");
                $finish;
            end
            
            $display("Saving input data to input_data.mem...");
            for (i = 0; i < IN_WIDTH*IN_HEIGHT*CHANNELS; i++) begin
                $fwrite(input_file, "%04h\n", input_memory[i]);
            end
            $fclose(input_file);
            $display("Input data saved successfully.");
        end
    endtask
    
    // Task to save weights to file
    task save_weights();
        integer i;
        begin
            weight_file = $fopen("weights.mem", "w");
            if (weight_file == 0) begin
                $display("ERROR: Could not open weights.mem for writing");
                $finish;
            end
            
            $display("Saving weights to weights.mem...");
            for (i = 0; i < KERNEL_SIZE*KERNEL_SIZE*CHANNELS; i++) begin
                $fwrite(weight_file, "%04h\n", weight_memory[i]);
            end
            $fclose(weight_file);
            $display("Weights saved successfully.");
        end
    endtask
    
    // Task to load weights for a specific channel (optimized for single channel processing)
    task load_weights_for_channel(integer channel_num);
        integer ky, kx, weight_idx, mem_idx;
        begin
            $display("Loading weights for channel %0d...", channel_num);

            // Initialize weights to zero
            weights = 0;

            // Load weights for single channel (9 weights for 3x3 kernel)
            for (ky = 0; ky < KERNEL_SIZE; ky++) begin
                for (kx = 0; kx < KERNEL_SIZE; kx++) begin
                    weight_idx = (ky * KERNEL_SIZE + kx) * N;
                    mem_idx = channel_num * KERNEL_SIZE * KERNEL_SIZE + ky * KERNEL_SIZE + kx;
                    weights[weight_idx +: N] = weight_memory[mem_idx];
                end
            end

            $display("Weights loaded for channel %0d.", channel_num);
        end
    endtask

    // Task to load weights into DUT format (optimized for single channel)
    task load_weights_to_dut();
        begin
            load_weights_for_channel(0); // Load first channel initially
        end
    endtask

    // Task to dynamically update weights based on current channel (Winograd)
    always @(posedge clk) begin
        if (!rst && (dut.state == dut.LOAD_WEIGHTS || dut.state == dut.WEIGHT_TRANSFORM)) begin
            // Update weights when channel changes
            if (dut.output_channel != current_ch_group) begin
                current_ch_group = dut.output_channel;
                load_weights_for_channel(current_ch_group);
                $display("Updated weights for channel %0d", current_ch_group);
            end
        end
    end



    //==========================================================================
    // Input Data Feeding Process
    //==========================================================================



    // Task to feed input data to DUT (single run with all channels)
    task feed_input_data();
        integer ch, y, x, data_idx;
        begin
            $display("Starting input data feeding...");
            input_idx = 0;
            valid_in = 0;

            // Wait for weights to be transformed (Winograd)
            wait(dut.weights_transformed);

            // Feed data in pixel-major order (all channels for each pixel)
            for (y = 0; y < IN_HEIGHT; y++) begin
                for (x = 0; x < IN_WIDTH; x++) begin
                    for (ch = 0; ch < CHANNELS; ch++) begin
                        @(posedge clk);
                        data_idx = ch*IN_WIDTH*IN_HEIGHT + y*IN_WIDTH + x;
                        data_in = input_memory[data_idx];
                        channel_in = ch;
                        valid_in = 1;
                        input_idx = input_idx + 1;

                        // Progress indicator
                        if (input_idx % 50000 == 0) begin
                            $display("Fed %0d input samples...", input_idx);
                        end
                    end
                end
            end

            @(posedge clk);
            valid_in = 0;
            $display("Input data feeding completed. Total samples: %0d", input_idx);
        end
    endtask

    //==========================================================================
    // Output Data Capture Process
    //==========================================================================

    // Task to capture output data
    task capture_output_data();
        begin
            $display("Starting output data capture...");
            output_idx = 0;

            while (!done) begin
                @(posedge clk);
                if (valid_out) begin
                    output_memory[output_idx] = data_out;
                    output_idx = output_idx + 1;

                    // Display progress every 1000 samples
                    if (output_idx % 1000 == 0) begin
                        $display("Captured %0d output samples...", output_idx);
                    end
                end
            end

            $display("Output data capture completed. Total samples: %0d", output_idx);
        end
    endtask

    // Task to save output data to file
    task save_output_data();
        integer i;
        begin
            output_file = $fopen("output_data.mem", "w");
            if (output_file == 0) begin
                $display("ERROR: Could not open output_data.mem for writing");
                $finish;
            end

            $display("Saving output data to output_data.mem...");

            // Write header with dimensions and format information
            $fwrite(output_file, "// Depthwise Convolution Output Data\n");
            $fwrite(output_file, "// Format: 16-bit signed fixed-point (Q8.8)\n");
            $fwrite(output_file, "// Dimensions: %0dx%0dx%0d (WxHxC)\n", OUT_WIDTH, OUT_HEIGHT, CHANNELS);
            $fwrite(output_file, "// Total samples: %0d\n", output_idx);
            $fwrite(output_file, "// Data format: 4-digit hexadecimal\n");
            $fwrite(output_file, "//\n");

            for (i = 0; i < output_idx; i++) begin
                $fwrite(output_file, "%04h\n", output_memory[i]);
            end
            $fclose(output_file);
            $display("Output data saved successfully.");
        end
    endtask

    //==========================================================================
    // Verification and Analysis Tasks
    //==========================================================================

    // Task to perform basic output verification
    task verify_output();
        integer i;
        real output_val, expected_range_min, expected_range_max;
        begin
            $display("Performing output verification...");
            error_count = 0;

            expected_range_min = -10.0;  // Expected range for convolution outputs
            expected_range_max = 10.0;

            for (i = 0; i < output_idx; i++) begin
                output_val = fixed_to_real(output_memory[i]);

                // Check for reasonable output range
                if (output_val < expected_range_min || output_val > expected_range_max) begin
                    if (error_count < 10) begin // Limit error reporting
                        $display("WARNING: Output[%0d] = %f is outside expected range [%f, %f]",
                                i, output_val, expected_range_min, expected_range_max);
                    end
                    error_count = error_count + 1;
                end
            end

            if (error_count == 0) begin
                $display("PASS: All outputs are within expected range");
            end else begin
                $display("WARNING: %0d outputs are outside expected range", error_count);
            end
        end
    endtask

    // Task to generate test summary
    task generate_test_summary();
        real avg_output, min_output, max_output;
        integer i;
        begin
            $display("\n" + "="*80);
            $display("DEPTHWISE CONVOLUTION TESTBENCH SUMMARY");
            $display("="*80);
            $display("Test Parameters:");
            $display("  Input dimensions: %0dx%0dx%0d", IN_WIDTH, IN_HEIGHT, CHANNELS);
            $display("  Output dimensions: %0dx%0dx%0d", OUT_WIDTH, OUT_HEIGHT, CHANNELS);
            $display("  Kernel size: %0dx%0d", KERNEL_SIZE, KERNEL_SIZE);
            $display("  Stride: %0d, Padding: %0d", STRIDE, PADDING);
            $display("  Parallelism: %0d channels", PARALLELISM);
            $display("  Data format: Q%0d.%0d fixed-point", N-Q, Q);

            $display("\nTest Results:");
            $display("  Input samples fed: %0d", input_idx);
            $display("  Output samples captured: %0d", output_idx);
            $display("  Expected output samples: %0d", OUT_WIDTH*OUT_HEIGHT*CHANNELS);
            $display("  Total simulation cycles: %0d", cycle_count);

            // Calculate output statistics
            if (output_idx > 0) begin
                avg_output = 0;
                min_output = fixed_to_real(output_memory[0]);
                max_output = fixed_to_real(output_memory[0]);

                for (i = 0; i < output_idx; i++) begin
                    automatic real val = fixed_to_real(output_memory[i]);
                    avg_output = avg_output + val;
                    if (val < min_output) min_output = val;
                    if (val > max_output) max_output = val;
                end
                avg_output = avg_output / output_idx;

                $display("\nOutput Statistics:");
                $display("  Average: %f", avg_output);
                $display("  Minimum: %f", min_output);
                $display("  Maximum: %f", max_output);
            end

            $display("\nFiles Generated:");
            $display("  input_data.mem - Input feature map data");
            $display("  weights.mem - Convolution weights");
            $display("  output_data.mem - Convolution results");

            if (output_idx == OUT_WIDTH*OUT_HEIGHT*CHANNELS && error_count == 0) begin
                $display("\nTEST STATUS: PASSED");
            end else begin
                $display("\nTEST STATUS: FAILED");
            end
            $display("="*80);
        end
    endtask

    //==========================================================================
    // Main Test Execution
    //==========================================================================

    initial begin
        // Initialize signals
        rst = 1;
        en = 0;
        data_in = 0;
        channel_in = 0;
        valid_in = 0;
        weights = 0;
        input_idx = 0;
        output_idx = 0;
        cycle_count = 0;
        error_count = 0;

        $display("Starting Depthwise Convolution Testbench...");
        $display("Simulation time: %0t", $time);

        // Wait for a few clock cycles
        repeat(10) @(posedge clk);

        // Release reset
        rst = 0;
        repeat(5) @(posedge clk);

        // Generate test data
        generate_input_data();
        generate_weights();

        // Save test data to files
        save_input_data();
        save_weights();

        // Load weights into DUT format
        load_weights_to_dut();

        // Start the convolution process
        $display("Starting convolution process...");
        en = 1;

        // Fork parallel processes for input feeding and output capture
        fork
            feed_input_data();
            capture_output_data();
        join

        // Wait for completion
        wait(done);
        $display("Convolution process completed at time %0t", $time);

        // Disable enable signal
        en = 0;
        repeat(10) @(posedge clk);

        // Save and verify results
        save_output_data();
        verify_output();
        generate_test_summary();

        $display("Testbench completed successfully!");
        $finish;
    end

    // Cycle counter
    always @(posedge clk) begin
        if (!rst) cycle_count <= cycle_count + 1;
    end

    // Timeout watchdog
    initial begin
        #50000000; // 50ms timeout
        $display("ERROR: Testbench timeout!");
        $finish;
    end

    // Monitor key signals during simulation (reduced verbosity)
    always @(posedge clk) begin
        if (valid_out && (output_idx % 1000 == 0 || output_idx < 10)) begin
            $display("Time %0t: Output[%0d] = 0x%04h (channel %0d)",
                    $time, output_idx, data_out, channel_out);
        end
    end

endmodule

//==============================================================================
// Additional Memory File Generation Utilities
//==============================================================================

// This module can be used to generate memory files with different test patterns
module memory_file_generator;

    parameter N = 16;
    parameter Q = 8;
    parameter WIDTH = 112;
    parameter HEIGHT = 112;
    parameter CHANNELS = 16;

    // Function to generate Gaussian noise
    function [N-1:0] gaussian_noise(real mean, real stddev);
        real u1, u2, z0;
        real scaled_value;
        begin
            // Box-Muller transform for Gaussian distribution
            u1 = $random / real'(2**31);
            u2 = $random / real'(2**31);
            z0 = $sqrt(-2.0 * $ln(u1)) * $cos(2.0 * 3.14159 * u2);
            scaled_value = (mean + stddev * z0) * (1 << Q);

            if (scaled_value > 32767.0) scaled_value = 32767.0;
            if (scaled_value < -32768.0) scaled_value = -32768.0;
            gaussian_noise = $signed(int'(scaled_value));
        end
    endfunction

    // Task to generate edge detection test image
    task generate_edge_test_image(string filename);
        integer file_handle;
        integer x, y, ch;
        reg [N-1:0] pixel_value;
        begin
            file_handle = $fopen(filename, "w");

            for (ch = 0; ch < CHANNELS; ch++) begin
                for (y = 0; y < HEIGHT; y++) begin
                    for (x = 0; x < WIDTH; x++) begin
                        // Create vertical and horizontal edges
                        if ((x == WIDTH/4) || (x == 3*WIDTH/4) ||
                            (y == HEIGHT/4) || (y == 3*HEIGHT/4)) begin
                            pixel_value = 16'h0100; // 1.0 in Q8.8
                        end else begin
                            pixel_value = 16'h0000; // 0.0 in Q8.8
                        end

                        $fwrite(file_handle, "%04h\n", pixel_value);
                    end
                end
            end

            $fclose(file_handle);
        end
    endtask

endmodule

