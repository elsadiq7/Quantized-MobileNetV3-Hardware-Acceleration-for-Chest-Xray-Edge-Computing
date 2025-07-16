// Simple test to verify the optimized module works with the original testbench interface
`timescale 1ns / 1ps

module pointwise_conv_optimized_test();

    // Test parameters
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
    
    // Interface signals
    reg [N-1:0] data_in;
    reg [$clog2(IN_CHANNELS)-1:0] channel_in;
    reg valid_in;
    reg [(IN_CHANNELS*OUT_CHANNELS*N)-1:0] weights;
    
    wire [N-1:0] data_out;
    wire [$clog2(OUT_CHANNELS)-1:0] channel_out;
    wire valid_out;
    wire done;
    
    // Test data
    reg [N-1:0] input_memory [0:1023];
    reg [N-1:0] weight_memory [0:IN_CHANNELS*OUT_CHANNELS-1];
    
    integer input_count;
    integer output_count;
    integer i;
    integer output_file;
    
    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end
    
    // Optimized module instantiation
    pointwise_conv_optimized_v2 #(
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
    
    // Load test data
    initial begin
        // Initialize
        for (i = 0; i < 1024; i = i + 1) begin
            input_memory[i] = 16'h0000;
        end
        
        for (i = 0; i < IN_CHANNELS*OUT_CHANNELS; i = i + 1) begin
            weight_memory[i] = 16'h0000;
        end
        
        // Load data
        $display("Loading test data for optimized module test...");
        $readmemh("input_data.mem", input_memory);
        $readmemh("weights.mem", weight_memory);
        
        // Pack weights
        for (i = 0; i < IN_CHANNELS*OUT_CHANNELS; i = i + 1) begin
            weights[i*N +: N] = weight_memory[i];
        end
        
        $display("Test data loaded successfully");
    end
    
    // Main test
    initial begin
        rst = 1;
        en = 0;
        data_in = 0;
        channel_in = 0;
        valid_in = 0;
        input_count = 0;
        output_count = 0;
        
        output_file = $fopen("conv_optimized_test_out.mem", "w");
        
        $display("=== Optimized Module Drop-in Replacement Test ===");
        
        // Reset
        #100;
        rst = 0;
        #50;
        
        // Enable
        en = 1;
        #20;
        
        // Input stimulus
        fork
            input_stimulus();
            output_monitor();
            timeout_monitor();
        join_any
        
        // Wait for completion
        wait(done == 1);
        #100;
        
        $fclose(output_file);
        
        $display("=== Test Results ===");
        $display("Total inputs sent: %0d", input_count);
        $display("Total outputs received: %0d", output_count);
        $display("Test completed successfully");
        $display("Output saved to: conv_optimized_test_out.mem");
        
        $finish;
    end
    
    // Input stimulus
    task input_stimulus();
        integer ch, sample_idx;
        begin
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
        end
    endtask
    
    // Output monitor
    task output_monitor();
        begin
            while (output_count < OUT_CHANNELS) begin
                @(posedge clk);
                if (valid_out) begin
                    output_count = output_count + 1;
                    $fwrite(output_file, "%04x\n", data_out);
                    $display("Output[%0d]: Channel=%0d, Data=0x%04x", 
                             output_count, channel_out, data_out);
                end
            end
        end
    endtask
    
    // Timeout monitor
    task timeout_monitor();
        begin
            #100000; // 100us timeout
            $display("ERROR: Test timeout");
            $finish;
        end
    endtask

endmodule
