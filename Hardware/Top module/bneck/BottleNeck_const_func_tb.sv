// Simple test to validate pipeline flush fix
`timescale 1ns/1ps
module BottleNeck_const_func_tb;
    
    // Parameters
    parameter N = 16;
    parameter Q = 8;
    parameter IN_CHANNELS = 16;
    parameter OUT_CHANNELS = 16;
    parameter EXPAND_CHANNELS = 16;
    parameter FEATURE_SIZE = 112;
    parameter KERNEL_SIZE = 3;
    parameter STRIDE = 1;
    parameter PADDING = 1;
    
    // Signals
    reg clk, rst, en;
    reg [N-1:0] data_in;
    reg [$clog2(IN_CHANNELS)-1:0] channel_in;  // Fixed: Use correct width for input
    reg valid_in;
    wire [N-1:0] data_out;
    wire [$clog2(OUT_CHANNELS)-1:0] channel_out;  // Fixed: Use correct width for output
    wire valid_out;
    wire done;
    
    // Test variables
    integer input_count = 0;
    integer output_count = 0;
    integer cycle_count = 0;
    
    // Instantiate the module under test
    BottleNeck_const_func #(
        .N(N),
        .Q(Q),
        .IN_CHANNELS(IN_CHANNELS),
        .OUT_CHANNELS(OUT_CHANNELS),
        .EXPAND_CHANNELS(EXPAND_CHANNELS),
        .FEATURE_SIZE(FEATURE_SIZE),
        .KERNEL_SIZE(KERNEL_SIZE),
        .STRIDE(STRIDE),
        .PADDING(PADDING)
    ) dut (
        .clk(clk),
        .rst(rst),
        .en(en),
        .data_in(data_in),
        .channel_in(channel_in),
        .valid_in(valid_in),
        .data_out(data_out),
        .channel_out(channel_out),
        .valid_out(valid_out),
        .done(done)
    );
    
    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end
    
    // Cycle counter
    always @(posedge clk) begin
        if (rst) cycle_count <= 0;
        else cycle_count <= cycle_count + 1;
    end
    
    // Output monitoring
    always @(posedge clk) begin
        if (valid_out) begin
            output_count = output_count + 1;
            if (output_count <= 10 || output_count > 138) begin
                $display("OUTPUT[%0d]: data=0x%04x, channel=%0d, cycle=%0d",
                         output_count, data_out, channel_out, cycle_count);
            end
        end
    end
    
    // Done signal monitoring
    always @(posedge clk) begin
        if (done) begin
            $display("*** DONE SIGNAL ASSERTED *** at cycle %0d", cycle_count);
            $display("Final results: %0d inputs, %0d outputs (%.1f%% efficiency)", 
                     input_count, output_count, (output_count * 100.0) / input_count);
            #100;
            $finish;
        end
    end
    
    // Main test
    initial begin
        $display("=== SIMPLE PIPELINE FLUSH TEST ===");
        
        // Initialize
        rst = 1;
        en = 0;
        data_in = 0;
        channel_in = 0;
        valid_in = 0;
        
        // Reset sequence
        #100;
        rst = 0;
        #50;
        en = 1;
        
        // Wait for initialization
        #1000;
        
        // Feed test inputs
        $display("Feeding 148 test inputs...");
        repeat(148) begin
            @(posedge clk);
            data_in = 16'h0800 + input_count;
            channel_in = input_count % IN_CHANNELS;
            valid_in = 1;
            input_count = input_count + 1;
            if (input_count <= 10 || input_count > 138) begin
                $display("INPUT[%0d]: data=0x%04x, channel=%0d, cycle=%0d",
                         input_count, data_in, channel_in, cycle_count);
            end
        end
        
        // Stop feeding inputs
        @(posedge clk);
        valid_in = 0;
        $display("Input feeding complete: %0d inputs at cycle %0d", input_count, cycle_count);

        // Wait for pipeline to flush
        wait(done || cycle_count > 5000);
        
        if (!done) begin
            $display("ERROR: Test timeout - done signal not asserted");
            $display("Final state: %0d inputs, %0d outputs", input_count, output_count);
        end
        
        $finish;
    end
    
endmodule
