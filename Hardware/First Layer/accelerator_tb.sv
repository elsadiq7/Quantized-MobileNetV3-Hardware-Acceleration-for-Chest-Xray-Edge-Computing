`timescale 1ns / 1ps

`define imageSize 224*224
`define imageOUTSize 112*112*16  // 112x112 output with 16 channels

module accelerator_tb();
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
    
    // External memory interface signals for optimized accelerator
    wire [N-1:0] weight_data;
    wire [N-1:0] bn_data;
    wire [$clog2(k*k*IN_CHANNELS*OUT_CHANNELS)-1:0] weight_addr;
    wire [$clog2(2*OUT_CHANNELS)-1:0] bn_addr;
    wire weight_en;
    wire bn_en;
    
    // Internal memories for test data
    reg [N-1:0] conv_weights [0:k*k*IN_CHANNELS*OUT_CHANNELS-1];
    reg [N-1:0] bn_params [0:2*OUT_CHANNELS-1]; // Combined gamma and beta
    
    // Files for output
    integer file1, hexFile, txt_file;
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
    
    // Debug variables
    integer i;
    
    // Initialize statistics
    initial begin
        for (i = 0; i < OUT_CHANNELS; i = i + 1) begin
            channel_counts[i] = 0;
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
        // External memory interface connections
        .weight_data(weight_data),
        .bn_data(bn_data),
        .weight_addr(weight_addr),
        .bn_addr(bn_addr),
        .weight_en(weight_en),
        .bn_en(bn_en),
        // Output interface
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
        
        // Also monitor for other issues
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
        
        // Open output files
        file1 = $fopen("output_results.bmp", "wb");
        hexFile = $fopen("output_results.hex", "w");
        txt_file = $fopen("output_results.txt", "w");
        
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
        
        // Print statistics
        $display("Output statistics:");
        $display("  Total outputs: %0d", receivedData);
        $display("  Non-zero outputs: %0d (%0.2f%%)", nonzero_outputs, 
                 nonzero_outputs * 100.0 / receivedData);
        $display("  Min value: %h", min_value);
        $display("  Max value: %h", max_value);
        
        // Display channel distribution
        $display("Channel distribution:");
        for (i = 0; i < OUT_CHANNELS; i = i + 1) begin
            $display("  Channel %0d: %0d outputs", i, channel_counts[i]);
        end
        
        // Close output files
        $fclose(file1);
        $fclose(hexFile);
        $fclose(txt_file);
        
        $display("Simulation completed successfully!");
        $stop;
    end
    
    // Capture and save outputs
    always @(posedge clk) begin
        if (valid_out && !all_outputs_saved) begin
            // Write to BMP file (raw binary data)
            $fwrite(file1, "%c", data_out[7:0]);
            
            // Write to HEX file (hexadecimal format)
            $fwrite(hexFile, "%04X\n", data_out);
            
            // Write to text file for debugging
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
            if (receivedData % 1000 == 0 || receivedData == 1) begin
                $display("Output %0d/%0d: %h, non-zero count: %0d", 
                         receivedData, TOTAL_OUTPUTS, data_out, nonzero_outputs);
            end
            
            // Check if we've received all expected outputs - avoid infinite loop
            if (receivedData >= TOTAL_OUTPUTS) begin
                if (!all_outputs_saved) begin
                    $display("All outputs received and saved! Total: %0d", receivedData);
                    all_outputs_saved = 1;
                end
            end
        end
    end

    // Memory interface logic - provide data when requested
    assign weight_data = (weight_en && weight_addr < k*k*IN_CHANNELS*OUT_CHANNELS) ? 
                        conv_weights[weight_addr] : 16'h0000;
    assign bn_data = (bn_en && bn_addr < 2*OUT_CHANNELS) ? 
                    bn_params[bn_addr] : 16'h0000;

endmodule