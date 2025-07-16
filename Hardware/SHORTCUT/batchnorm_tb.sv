`timescale 1ns / 1ps

module batchnorm_tb;

    // Parameters matching the batchnorm module
    parameter WIDTH = 16;
    parameter FRAC = 8;
    parameter CHANNELS = 48;
    
    // Clock and reset
    reg clk;
    reg rst;
    reg en;
    
    // Input interface
    reg [WIDTH-1:0] x_in;
    reg [$clog2(CHANNELS)-1:0] channel_in;
    reg valid_in;
    
    // Batch normalization parameters
    reg [(CHANNELS*WIDTH)-1:0] gamma_packed;
    reg [(CHANNELS*WIDTH)-1:0] beta_packed;
    
    // Output interface
    wire [WIDTH-1:0] y_out;
    wire [$clog2(CHANNELS)-1:0] channel_out;
    wire valid_out;
    
    // Test variables
    reg [WIDTH-1:0] input_memory [0:32255]; // Large enough for input data
    reg [WIDTH-1:0] expected_memory [0:32255]; // Expected output data
    reg [WIDTH-1:0] actual_memory [0:32255]; // Store actual outputs
    integer input_count;
    integer output_count;
    integer expected_count;
    integer error_count;
    integer i, j;
    
    // File handling
    integer input_file, expected_file;
    reg [1023:0] input_line, expected_line; // Large enough for long binary strings
    integer input_elements_in_line, expected_elements_in_line;
    integer line_count;
    
    // Instantiate the DUT
    batchnorm #(
        .WIDTH(WIDTH),
        .FRAC(FRAC),
        .CHANNELS(CHANNELS)
    ) dut (
        .clk(clk),
        .rst(rst),
        .en(en),
        .x_in(x_in),
        .channel_in(channel_in),
        .valid_in(valid_in),
        .gamma_packed(gamma_packed),
        .beta_packed(beta_packed),
        .y_out(y_out),
        .channel_out(channel_out),
        .valid_out(valid_out)
    );
    
    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 100MHz clock
    end
    
    // Load input data from memory file
    task load_input_data;
        integer file_handle, status;
        reg [1023:0] line_buffer;
        integer char_pos, elements_per_line;
        reg [15:0] temp_element;
        integer bit_idx;
        begin
            file_handle = $fopen("shortcut_1_bn_in.mem", "r");
            if (file_handle == 0) begin
                $display("ERROR: Could not open shortcut_1_bn_in.mem");
                $finish;
            end

            input_count = 0;

            // Read first line to determine format
            if ($fgets(line_buffer, file_handle)) begin
                // Count characters in line (each line has multiple 16-bit values)
                char_pos = 0;
                while (char_pos < 1024 && line_buffer[char_pos*8 +: 8] != 8'h0A && line_buffer[char_pos*8 +: 8] != 8'h00) begin
                    char_pos = char_pos + 1;
                end
                elements_per_line = char_pos / 16; // Each element is 16 bits
                $display("Input file format: %0d characters per line, %0d elements per line", char_pos, elements_per_line);

                // Parse elements from first line
                for (i = 0; i < elements_per_line && input_count < 32256; i = i + 1) begin
                    for (bit_idx = 0; bit_idx < 16; bit_idx = bit_idx + 1) begin
                        if (line_buffer[(i*16 + bit_idx)*8 +: 8] == 8'h31) begin // '1'
                            temp_element[15-bit_idx] = 1'b1;
                        end else begin // '0'
                            temp_element[15-bit_idx] = 1'b0;
                        end
                    end
                    input_memory[input_count] = temp_element;
                    input_count = input_count + 1;
                end
            end

            $fclose(file_handle);
            $display("Loaded %0d input elements from shortcut_1_bn_in.mem", input_count);
        end
    endtask
    
    // Load expected output data
    task load_expected_data;
        integer file_handle;
        reg [1023:0] line_buffer;
        integer char_pos, elements_per_line;
        reg [15:0] temp_element;
        integer bit_idx;
        begin
            file_handle = $fopen("shortcut_1_bn_actual_out.mem", "r");
            if (file_handle == 0) begin
                $display("ERROR: Could not open shortcut_1_bn_actual_out.mem");
                $finish;
            end

            expected_count = 0;

            // Read first line to determine format
            if ($fgets(line_buffer, file_handle)) begin
                // Count characters in line
                char_pos = 0;
                while (char_pos < 1024 && line_buffer[char_pos*8 +: 8] != 8'h0A && line_buffer[char_pos*8 +: 8] != 8'h00) begin
                    char_pos = char_pos + 1;
                end
                elements_per_line = char_pos / 16; // Each element is 16 bits
                $display("Expected file format: %0d characters per line, %0d elements per line", char_pos, elements_per_line);

                // Parse elements from first line
                for (i = 0; i < elements_per_line && expected_count < 32256; i = i + 1) begin
                    for (bit_idx = 0; bit_idx < 16; bit_idx = bit_idx + 1) begin
                        if (line_buffer[(i*16 + bit_idx)*8 +: 8] == 8'h31) begin // '1'
                            temp_element[15-bit_idx] = 1'b1;
                        end else begin // '0'
                            temp_element[15-bit_idx] = 1'b0;
                        end
                    end
                    expected_memory[expected_count] = temp_element;
                    expected_count = expected_count + 1;
                end
            end

            $fclose(file_handle);
            $display("Loaded %0d expected elements from shortcut_1_bn_actual_out.mem", expected_count);
        end
    endtask
    
    // Initialize batch normalization parameters
    initial begin
        // Initialize gamma (scale) to 1.0 and beta (bias) to 0.0
        gamma_packed = {CHANNELS{16'h0100}}; // 1.0 in Q8.8 format
        beta_packed = {CHANNELS{16'h0000}};  // 0.0
        $display("Initialized BN parameters: gamma=0x0100 (1.0), beta=0x0000 (0.0)");
    end
    
    // Test stimulus
    initial begin
        // Initialize signals
        rst = 1;
        en = 0;
        x_in = 0;
        channel_in = 0;
        valid_in = 0;
        output_count = 0;
        error_count = 0;
        
        // Load test data using custom parser
        load_input_data();
        load_expected_data();
        
        // Reset sequence
        #20;
        rst = 0;
        #10;
        en = 1;
        
        $display("Starting batch normalization test...");
        $display("Input elements to process: %0d", input_count);
        $display("Expected output elements: %0d", expected_count);
        
        // Wait for parameter loading
        #100;
        
        // Feed input data
        for (i = 0; i < input_count; i = i + 1) begin
            @(posedge clk);
            x_in = input_memory[i];
            channel_in = i % CHANNELS; // Cycle through channels
            valid_in = 1;
            
            if (i < 10 || i >= input_count - 10) begin
                $display("Input[%0d]: Data=0x%04x, Channel=%0d", i, x_in, channel_in);
            end
            
            @(posedge clk);
            valid_in = 0;
            
            // Add some spacing between inputs
            repeat(1) @(posedge clk);
        end
        
        $display("Input feeding completed. Waiting for processing...");
        
        // Wait for all outputs
        while (output_count < input_count) begin
            @(posedge clk);
        end
        
        #100; // Additional wait
        
        $display("Processing completed!");
        $display("Total outputs captured: %0d", output_count);
        $display("Expected outputs: %0d", expected_count);
        
        // Compare results
        if (output_count >= expected_count) begin
            $display("Output count sufficient ✓");
        end else begin
            $display("ERROR: Insufficient outputs! Got %0d, expected %0d", output_count, expected_count);
            error_count = error_count + 1;
        end
        
        // Compare actual vs expected values
        for (i = 0; i < output_count && i < expected_count; i = i + 1) begin
            if (actual_memory[i] !== expected_memory[i]) begin
                if (error_count < 10) begin
                    $display("ERROR: Output[%0d] mismatch! Got 0x%04x, expected 0x%04x", 
                             i, actual_memory[i], expected_memory[i]);
                end
                error_count = error_count + 1;
            end
        end
        
        // Test summary
        $display("\n=== Batch Normalization Test Summary ===");
        $display("Input elements processed: %0d", input_count);
        $display("Output elements generated: %0d", output_count);
        $display("Expected elements: %0d", expected_count);
        $display("Errors found: %0d", error_count);
        
        if (error_count == 0) begin
            $display("TEST PASSED ✓");
        end else begin
            $display("TEST FAILED ✗");
        end
        
        #100;
        $finish;
    end
    
    // Capture outputs
    always @(posedge clk) begin
        if (valid_out && !rst) begin
            actual_memory[output_count] = y_out;
            if (output_count < 10 || output_count >= input_count - 10) begin
                $display("Output[%0d]: Data=0x%04x, Channel=%0d", 
                         output_count, y_out, channel_out);
            end
            output_count = output_count + 1;
        end
    end
    
    // Timeout protection
    initial begin
        #200000; // 200us timeout
        $display("ERROR: Test timeout!");
        $finish;
    end

endmodule
