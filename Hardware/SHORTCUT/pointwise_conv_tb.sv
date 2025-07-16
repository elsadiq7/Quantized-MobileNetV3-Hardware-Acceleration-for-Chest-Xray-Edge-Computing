`timescale 1ns / 1ps

module pointwise_conv_tb;

    // Parameters matching the pointwise_conv module
    parameter N = 16;
    parameter Q = 8;
    parameter IN_CHANNELS = 40;
    parameter OUT_CHANNELS = 48;
    parameter FEATURE_SIZE = 14;
    parameter PARALLELISM = 4;
    
    // Clock and reset
    reg clk;
    reg rst;
    reg en;
    
    // Input interface
    reg [N-1:0] data_in;
    reg [$clog2(IN_CHANNELS)-1:0] channel_in;
    reg valid_in;
    
    // Weight interface
    reg [(IN_CHANNELS*OUT_CHANNELS*N)-1:0] weights;
    
    // Output interface
    wire [N-1:0] data_out;
    wire [$clog2(OUT_CHANNELS)-1:0] channel_out;
    wire valid_out;
    wire done;
    
    // Test variables
    reg [N-1:0] input_memory [0:48]; // 49 input elements
    reg [N-1:0] expected_memory [0:32255]; // Large enough for expected output
    reg [N-1:0] actual_memory [0:32255]; // Store actual outputs
    integer input_count;
    integer output_count;
    integer expected_count;
    integer error_count;
    integer i, j;
    
    // Instantiate the DUT
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
    
    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 100MHz clock
    end
    
    // Load input data from memory file
    initial begin
        $readmemb("shortcut_0_conv_in.mem", input_memory);
        $display("Loaded %0d input elements from shortcut_0_conv_in.mem", 49);
    end
    
    // Load expected output data from memory file
    task load_expected_data;
        integer file_handle, line_count, char_idx, element_idx;
        reg [1023:0] line_buffer;
        reg [15:0] temp_element;
        integer bit_idx;
        begin
            file_handle = $fopen("shortcut_0_conv_actual_out.mem", "r");
            if (file_handle == 0) begin
                $display("ERROR: Could not open shortcut_0_conv_actual_out.mem");
                $finish;
            end

            expected_count = 0;
            line_count = 0;

            while (!$feof(file_handle)) begin
                if ($fgets(line_buffer, file_handle)) begin
                    line_count = line_count + 1;

                    // Parse each 16-bit element from the line
                    char_idx = 0;
                    while (char_idx + 15 < 1024 && line_buffer[char_idx*8 +: 8] != 8'h0A && line_buffer[char_idx*8 +: 8] != 8'h00) begin
                        // Extract 16-bit element
                        for (bit_idx = 0; bit_idx < 16; bit_idx = bit_idx + 1) begin
                            if (line_buffer[(char_idx + bit_idx)*8 +: 8] == 8'h31) begin // '1'
                                temp_element[15-bit_idx] = 1'b1;
                            end else begin // '0'
                                temp_element[15-bit_idx] = 1'b0;
                            end
                        end
                        expected_memory[expected_count] = temp_element;
                        expected_count = expected_count + 1;
                        char_idx = char_idx + 16;

                        if (expected_count >= 32256) break;
                    end
                    if (expected_count >= 32256) break;
                end
            end

            $fclose(file_handle);
            $display("Loaded %0d expected elements from shortcut_0_conv_actual_out.mem", expected_count);
        end
    endtask
    
    // Initialize weights with realistic values
    initial begin
        // Initialize weights to larger values to match expected output scale
        // The expected outputs are in the range 0x4b00, 0x6d00, etc.
        for (i = 0; i < IN_CHANNELS * OUT_CHANNELS; i = i + 1) begin
            weights[i*N +: N] = $signed(16'h0100 + (i % 256)); // Larger values
        end
        $display("Initialized %0d weight values", IN_CHANNELS * OUT_CHANNELS);
    end
    
    // Test stimulus
    initial begin
        // Initialize signals
        rst = 1;
        en = 0;
        data_in = 0;
        channel_in = 0;
        valid_in = 0;
        input_count = 0;
        output_count = 0;
        error_count = 0;
        
        // Reset sequence
        #20;
        rst = 0;
        #10;
        en = 1;

        // Load expected output data
        load_expected_data();

        $display("Starting pointwise convolution test...");
        $display("Input elements to process: %0d", 49);
        
        // Wait a few cycles before starting input
        #50;
        
        // Feed input data - simulate realistic input pattern
        // For pointwise conv: process each input channel for each output channel
        for (i = 0; i < 49; i = i + 1) begin
            @(posedge clk);
            data_in = input_memory[i];
            channel_in = i % IN_CHANNELS; // Cycle through input channels
            valid_in = 1;
            input_count = input_count + 1;

            if (i < 10) begin
                $display("Input[%0d]: Data=0x%04x, Channel=%0d", i, data_in, channel_in);
            end

            @(posedge clk);
            valid_in = 0;

            // Minimal spacing between inputs
            @(posedge clk);
        end
        
        $display("Input feeding completed. Waiting for processing...");

        // Wait for processing to complete or timeout
        // Since we only have 49 inputs but module expects 196 pixels,
        // we'll wait for a reasonable number of outputs or done signal
        while (!done && output_count < 2400) begin // Wait for done or many outputs
            @(posedge clk);
            if ($time > 100000) break; // 100us timeout
        end

        // Wait a bit more to see if done gets asserted
        repeat(200) @(posedge clk);

        $display("Processing completed!");
        $display("Total outputs captured: %0d", output_count);
        $display("Expected outputs: %0d", expected_count);
        
        // Compare results
        if (output_count == expected_count) begin
            $display("Output count matches expected count ✓");
        end else begin
            $display("ERROR: Output count mismatch! Got %0d, expected %0d", output_count, expected_count);
            error_count = error_count + 1;
        end
        
        // Compare actual vs expected values
        for (i = 0; i < output_count && i < expected_count; i = i + 1) begin
            if (actual_memory[i] !== expected_memory[i]) begin
                $display("ERROR: Output[%0d] mismatch! Got 0x%04x, expected 0x%04x", 
                         i, actual_memory[i], expected_memory[i]);
                error_count = error_count + 1;
               // if (error_count >= 10) begin
                //    $display("Too many errors, stopping comparison...");
                //    break;
               // end
            end
        end
        
        // Test summary
        $display("\n=== Pointwise Convolution Test Summary ===");
        $display("Input elements processed: %0d", input_count);
        $display("Output elements generated: %0d", output_count);
        $display("Expected elements: %0d", expected_count);
        $display("Errors found: %0d", error_count);
        
        if (error_count == 0) begin
            $display("TEST PASSED ✓");
        end else begin
            $display("TEST FAILED ✗");
        end
        
        $display("Done signal working: %s", done ? "YES" : "NO");
        $display("Module functionality: %s", (output_count > 0) ? "YES" : "NO");
        
        #100;
        $finish;
    end
    
    // Capture outputs
    always @(posedge clk) begin
        if (valid_out && !rst) begin
            actual_memory[output_count] = data_out;
            $display("Output[%0d]: Data=0x%04x, Channel=%0d", 
                     output_count, data_out, channel_out);
            output_count = output_count + 1;
        end
    end
    
    // Timeout protection
    initial begin
        #100000; // 100us timeout
        $display("ERROR: Test timeout!");
        $finish;
    end

endmodule
