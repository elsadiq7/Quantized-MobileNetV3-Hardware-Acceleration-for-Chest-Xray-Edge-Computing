// Enhanced testbench for serial Conv2D_param with expected output check and DEBUG
module tb_Conv2D_param;
    logic clk, rst;
    logic [15:0] in_data;
    logic load_kernel, in_valid;
    logic [15:0] out_data;
    logic out_valid;

    // Test with small configuration: 2 input channels, 1 output channel
    localparam IN_CHANNELS = 2;
    localparam OUT_CHANNELS = 1;

    int input_count = 0;
    int output_count = 0;

    Conv2D #(
        .DATA_WIDTH(16),
        .IN_CHANNELS(IN_CHANNELS),
        .OUT_CHANNELS(OUT_CHANNELS)
    ) uut (
        .clk(clk), .rst(rst), .load_kernel(load_kernel), .in_data(in_data), .in_valid(in_valid), .out_data(out_data), .out_valid(out_valid)
    );

    initial clk = 0;
    always #5 clk = ~clk;

    // Add debug monitoring
    always @(posedge clk) begin
        if (load_kernel) begin
            $display("🔧 DEBUG: Loading kernel weight[%0d] = %0d", input_count, in_data);
            input_count++;
        end else if (in_valid) begin
            $display("🔵 DEBUG: Input[%0d] = %0d", input_count, in_data);
            input_count++;
        end
        
        if (out_valid) begin
            $display("🟢 DEBUG: Output[%0d] = %0d", output_count, out_data);
            output_count++;
        end
    end

    initial begin
        int timeout;
        int expected;
        
        rst = 1; in_data = 0; load_kernel = 0; in_valid = 0; input_count = 0; output_count = 0;
        #20; rst = 0;
        
        $display("🚀 Testing Enhanced Conv2D: %0d input channels -> %0d output channels", IN_CHANNELS, OUT_CHANNELS);
        $display("📊 Expected kernel weights: %0d", IN_CHANNELS * OUT_CHANNELS);
        $display("📊 Expected inputs per pixel: %0d", IN_CHANNELS);
        
        // Load kernel weights: IN_CHANNELS * OUT_CHANNELS = 2 weights
        $display("\n🔧 Phase 1: Loading kernel weights...");
        load_kernel = 1; in_valid = 0; input_count = 0;
        in_data = 2; @(negedge clk);  // weight[0][0] = 2
        $display("   ✓ Loaded weight[0][0] = 2");
        in_data = 3; @(negedge clk);  // weight[0][1] = 3  
        $display("   ✓ Loaded weight[0][1] = 3");
        load_kernel = 0;
        $display("✅ Kernel loading complete");
        
        #20; // Wait for kernel to be loaded
        
        // Feed input data: IN_CHANNELS values per pixel
        $display("\n📤 Phase 2: Feeding input data...");
        $display("Expected output: weight[0][0]*input[0] + weight[0][1]*input[1] = 2*5 + 3*7 = %0d", 2*5+3*7);
        
        // Trigger the state transition to COLLECTING_INPUTS
        load_kernel = 0; input_count = 0;
        in_valid = 1;
        in_data = 5;
        
        // Wait several cycles for the module to transition to COLLECTING_INPUTS and process the first input
        repeat (3) @(negedge clk);
        $display("   ✓ Sent input[0] = 5");
        
        // Send second input  
        in_data = 7;
        @(negedge clk);
        $display("   ✓ Sent input[1] = 7");
        
        in_valid = 0;
        $display("✅ All inputs sent");
        
        // Wait for computation and output with timeout
        $display("\n📥 Phase 3: Waiting for output...");
        timeout = 0;
        while (!out_valid && timeout < 50) begin
            @(negedge clk);
            timeout++;
        end
        
        if (timeout >= 50) begin
            $display("❌ TIMEOUT: No output received after %0d cycles", timeout);
        end else begin
            $display("✅ Output received after %0d cycles", timeout);
        end
        
        // Wait a bit more to see if additional outputs come
        repeat (10) @(negedge clk);
        
        $display("\n📊 Final Results:");
        $display("   Total outputs received: %0d", output_count);
        $display("   Expected outputs: %0d", OUT_CHANNELS);
        
        if (output_count == OUT_CHANNELS) begin
            $display("🎉 SUCCESS: Conv2D test completed successfully!");
        end else begin
            $display("❌ FAILURE: Expected %0d outputs, got %0d", OUT_CHANNELS, output_count);
        end
        
        $finish;
    end

    always @(posedge clk) begin
        if (out_valid) begin
            automatic int expected = 2*5+3*7;
            if (out_data == expected) begin
                $display("✅ PASS: Output = %0d (Expected: %0d)", out_data, expected);
            end else begin
                $display("❌ FAIL: Output = %0d (Expected: %0d)", out_data, expected);
            end
        end
    end
endmodule 