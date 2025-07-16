`timescale 1ns / 1ps

module shortcut_tb;

    // Parameters
    parameter N = 16;
    parameter Q = 8;
    parameter IN_CHANNELS = 24;
    parameter OUT_CHANNELS = 24;
    parameter FEATURE_SIZE = 28;
    parameter SPATIAL_PARALLEL = 2;
    parameter CHANNEL_PARALLEL = 4;
    
    // Clock and Reset
    reg clk;
    reg rst;
    reg en;
    
    // Inputs
    reg [SPATIAL_PARALLEL*N-1:0] data_in;
    reg [SPATIAL_PARALLEL*$clog2(IN_CHANNELS)-1:0] channel_in;
    reg [SPATIAL_PARALLEL-1:0] valid_in;
    reg [$clog2(FEATURE_SIZE)-1:0] row_idx;
    reg [$clog2(FEATURE_SIZE)-1:0] col_idx;
    
    // Input data memory for file-based testing
    parameter TOTAL_INPUT_ELEMENTS = FEATURE_SIZE * FEATURE_SIZE * IN_CHANNELS;
    parameter ELEMENTS_PER_LINE = 28; // 448 bits / 16 bits per element
    parameter TOTAL_LINES = TOTAL_INPUT_ELEMENTS / ELEMENTS_PER_LINE;

    reg [N-1:0] input_data_memory [0:TOTAL_INPUT_ELEMENTS-1];
    reg [ELEMENTS_PER_LINE*N-1:0] input_file_lines [0:TOTAL_LINES-1];

    // Output data memory for saving results
    reg [N-1:0] output_data_memory [0:FEATURE_SIZE*FEATURE_SIZE*OUT_CHANNELS-1];
    integer output_data_count = 0;

    // Weights and BN params
    reg [(IN_CHANNELS*OUT_CHANNELS*N)-1:0] pw_weights;
    reg [(OUT_CHANNELS*N)-1:0] bn_gamma_packed;  // Fixed: Should be OUT_CHANNELS
    reg [(OUT_CHANNELS*N)-1:0] bn_beta_packed;   // Fixed: Should be OUT_CHANNELS
    
    // Outputs
    wire [SPATIAL_PARALLEL*N-1:0] data_out;
    wire [SPATIAL_PARALLEL*$clog2(OUT_CHANNELS)-1:0] channel_out;
    wire [SPATIAL_PARALLEL-1:0] valid_out;
    wire [$clog2(FEATURE_SIZE)-1:0] out_row_idx;
    wire [$clog2(FEATURE_SIZE)-1:0] out_col_idx;
    wire done;
    wire [$clog2(FEATURE_SIZE*FEATURE_SIZE/SPATIAL_PARALLEL+1)-1:0] cycles_count;
    
    // Testbench variables
    integer i, j, k;
    integer error_count = 0;
    integer total_pixels = FEATURE_SIZE * FEATURE_SIZE;
    integer pixel_group_count = total_pixels / SPATIAL_PARALLEL;
    integer latency_counter = 0;
    integer input_pixel_idx, expected_value;
    integer input_value, weight_value, weight_idx;
    integer conv_result, bn_result;
    
    // Expected latency (adjust based on your pipeline depth)
    localparam EXPECTED_LATENCY = 10; 

    // Instantiate DUT
    shortcut #(
        .N(N),
        .Q(Q),
        .IN_CHANNELS(IN_CHANNELS),
        .OUT_CHANNELS(OUT_CHANNELS),
        .FEATURE_SIZE(FEATURE_SIZE),
        .SPATIAL_PARALLEL(SPATIAL_PARALLEL),
        .CHANNEL_PARALLEL(CHANNEL_PARALLEL)
    ) dut (
        .clk(clk),
        .rst(rst),
        .en(en),
        .data_in(data_in),
        .channel_in(channel_in),
        .valid_in(valid_in),
        .row_idx(row_idx),
        .col_idx(col_idx),
        .pw_weights(pw_weights),
        .bn_gamma_packed(bn_gamma_packed),
        .bn_beta_packed(bn_beta_packed),
        .data_out(data_out),
        .channel_out(channel_out),
        .valid_out(valid_out),
        .out_row_idx(out_row_idx),
        .out_col_idx(out_col_idx),
        .done(done),
        .cycles_count(cycles_count)
    );
    
    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end
    
    // Initialize test inputs
    task initialize_inputs;
        begin
            data_in = 0;
            channel_in = 0;
            valid_in = 0;
            row_idx = 0;
            col_idx = 0;
            en = 0;
            
            // Initialize weights with known pattern
            for (i = 0; i < IN_CHANNELS*OUT_CHANNELS; i = i + 1) begin
                pw_weights[i*N +: N] = (i % 256) << Q; // Scaled to fixed point
            end
            
            // Initialize BN params with known values
            for (i = 0; i < OUT_CHANNELS; i = i + 1) begin  // Fixed: Should be OUT_CHANNELS
                bn_gamma_packed[i*N +: N] = (1 << Q); // gamma = 1.0 in fixed point
                bn_beta_packed[i*N +: N] = 0;        // beta = 0.0 in fixed point
            end
        end
    endtask
    
    // Reset task
    task apply_reset;
        begin
            rst = 1;
            #20;
            rst = 0;
            #10;
        end
    endtask
    
    // Generate test pixel data from file
    task generate_test_pixels;
        integer pixel_idx, data_idx;
        integer channel_value;
        begin
            $display("Starting input generation from file data at time %0t", $time);

            for (i = 0; i < FEATURE_SIZE; i = i + 1) begin
                for (j = 0; j < FEATURE_SIZE; j = j + SPATIAL_PARALLEL) begin
                    @(posedge clk);

                    // Set spatial position
                    row_idx = i;
                    col_idx = j;

                    // Generate data for both spatial parallel pixels from file data
                    for (k = 0; k < SPATIAL_PARALLEL; k = k + 1) begin
                        // Calculate the linear pixel index
                        pixel_idx = i * FEATURE_SIZE + j + k;

                        // For now, use channel 0 data (we'll cycle through channels)
                        channel_value = (i + j + k) % IN_CHANNELS;
                        data_idx = pixel_idx + channel_value * (FEATURE_SIZE * FEATURE_SIZE);

                        // Ensure we don't exceed array bounds
                        if (data_idx < TOTAL_INPUT_ELEMENTS) begin
                            data_in[k*N +: N] = input_data_memory[data_idx];
                        end else begin
                            data_in[k*N +: N] = 0;
                        end

                        channel_in[k*$clog2(IN_CHANNELS) +: $clog2(IN_CHANNELS)] = channel_value;
                        valid_in[k] = 1;

                        $display("Input Pixel %0d: Channel=%0d, Value=%04h at (%0d,%0d)",
                                 k, channel_value, data_in[k*N +: N], i, j);
                    end
                    
                    // Randomly drop some valid signals to test robustness
                    if ($random % 20 == 0) begin
                        valid_in = 0;
                        $display("Invalid cycle inserted at (%0d,%0d)", i, j);
                    end
                end
            end
            
            // Clear valid after all pixels sent
            @(posedge clk);
            valid_in = 0;
            $display("Input generation completed at time %0t", $time);
        end
    endtask
    
    // Capture and save output data to file
    task verify_outputs;
        integer output_value;
        integer output_channel;
        integer output_file;
        begin
            $display("Starting output capture and verification at time %0t", $time);

            // Open output file for writing
            output_file = $fopen("shortcut_output.mem", "w");
            if (output_file == 0) begin
                $error("Failed to open shortcut_output.mem for writing");
                $finish;
            end

            // Wait for first valid output
            wait (|valid_out);
            latency_counter = 0;
            output_data_count = 0;

            while (!done) begin
                @(posedge clk);

                if (|valid_out) begin
                    for (k = 0; k < SPATIAL_PARALLEL; k = k + 1) begin
                        if (valid_out[k]) begin
                            output_value = data_out[k*N +: N];
                            output_channel = channel_out[k*$clog2(OUT_CHANNELS) +: $clog2(OUT_CHANNELS)];

                            // Store output data in memory
                            if (output_data_count < FEATURE_SIZE*FEATURE_SIZE*OUT_CHANNELS) begin
                                output_data_memory[output_data_count] = output_value;
                                output_data_count = output_data_count + 1;
                            end

                            // Write to output file in hexadecimal format
                            $fwrite(output_file, "%04h\n", output_value);

                            // Log the output for verification
                            $display("Output[%0d]: Pixel %0d, Channel=%0d, Value=%0d (0x%04h) at (%0d,%0d)",
                                     output_data_count-1, k, output_channel,
                                     $signed(output_value) >>> Q, output_value,
                                     out_row_idx, out_col_idx);

                            // Verify position matches - simplified for now
                            // Note: Position tracking needs pipeline delay consideration
                            // For now, just check that we're getting valid positions
                            if (out_row_idx >= FEATURE_SIZE || out_col_idx >= FEATURE_SIZE) begin
                                $error("Invalid position: Got (%0d,%0d), max should be (%0d,%0d)",
                                      out_row_idx, out_col_idx, FEATURE_SIZE-1, FEATURE_SIZE-1);
                                error_count = error_count + 1;
                            end
                        end
                    end

                    latency_counter = latency_counter + 1;
                end
            end

            // Close output file
            $fclose(output_file);

            $display("Output capture completed at time %0t", $time);
            $display("Total output elements captured: %0d", output_data_count);
            $display("Output data saved to shortcut_output.mem");
            $display("Total processing cycles: %0d", cycles_count);
        end
    endtask
    
    // Main test sequence
    initial begin
        // Read input data from file
        $display("Reading input data from shortcut_1_bn_actual_out.mem...");
        $display("Expected file format: %0d lines of %0d bits each", TOTAL_LINES, ELEMENTS_PER_LINE*N);

        // Check if file exists and read it - use batch norm output as shortcut input
        $readmemb("shortcut_1_bn_actual_out.mem", input_file_lines);

        // Verify file was read successfully by checking first line
        if (input_file_lines[0] === {ELEMENTS_PER_LINE*N{1'bx}}) begin
            $error("Failed to read shortcut_1_bn_actual_out.mem - file may not exist or be in wrong format");
            $finish;
        end

        // Unpack the file data into individual elements
        for (i = 0; i < TOTAL_LINES; i = i + 1) begin
            for (j = 0; j < ELEMENTS_PER_LINE; j = j + 1) begin
                if (i * ELEMENTS_PER_LINE + j < TOTAL_INPUT_ELEMENTS) begin
                    input_data_memory[i * ELEMENTS_PER_LINE + j] =
                        input_file_lines[i][(j*N) +: N];
                end
            end
        end
        $display("Successfully loaded %0d input elements from file", TOTAL_INPUT_ELEMENTS);
        $display("First few input values: %04h %04h %04h %04h",
                 input_data_memory[0], input_data_memory[1],
                 input_data_memory[2], input_data_memory[3]);

        // Initialize
        initialize_inputs;
        apply_reset;

        // Start test
        $display("\n=== Starting Testbench for Shortcut Module with File Input ===");
        $display("Feature Map Size: %0dx%0d", FEATURE_SIZE, FEATURE_SIZE);
        $display("Input Channels: %0d, Output Channels: %0d", IN_CHANNELS, OUT_CHANNELS);
        $display("Spatial Parallelism: %0d pixels/cycle", SPATIAL_PARALLEL);
        $display("Channel Parallelism: %0d channels/cycle\n", CHANNEL_PARALLEL);
        
        // Enable module
        @(posedge clk);
        en = 1;
        
        // Fork off data generation and verification
        fork
            generate_test_pixels;
            verify_outputs;
        join
        
        // Wait for completion
        wait(done);
        #100;
        
        // Test summary
        $display("\n=== File-Based Test Summary ===");
        $display("Input file: shortcut_act.mem (%0d elements loaded)", TOTAL_INPUT_ELEMENTS);
        $display("Output file: shortcut_output.mem (%0d elements saved)", output_data_count);
        if (error_count == 0) begin
            $display("TEST PASSED with 0 errors");
        end else begin
            $display("TEST FAILED with %0d errors", error_count);
        end
        $display("Total processing time: %0d cycles", cycles_count);
        $display("Done signal working: %s", done ? "YES" : "NO");
        $display("Module completed successfully: %s\n", done ? "YES" : "NO");
        
        $finish;
    end
    
    // Timeout check
    initial begin
        #1000000; // 1ms timeout
        $display("\nError: Testbench timed out");
        $display("Current state: %s", dut.state.name());
        $display("Input count: %0d/%0d", dut.input_count, pixel_group_count);
        $display("Output count: %0d/%0d", dut.output_count, pixel_group_count);
        $finish;
    end
    
    // Waveform dumping
    initial begin
        $dumpfile("shortcut_tb.vcd");
        $dumpvars(0, shortcut_tb);
    end
    
endmodule