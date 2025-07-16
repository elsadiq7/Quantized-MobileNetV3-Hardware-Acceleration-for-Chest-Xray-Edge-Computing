// Enhanced testbench for serial AdaptiveAvgPool2d_1x1 with PASS/FAIL validation and DEBUG
module tb_AdaptiveAvgPool2d_1x1;
    logic clk, rst;
    logic [15:0] in_data;
    logic [15:0] out_data;
    logic out_valid, in_valid;

    // Test parameters
    localparam DATA_WIDTH = 16;
    localparam IN_HEIGHT = 2;
    localparam IN_WIDTH = 2;
    localparam CHANNELS = 2;
    localparam TOTAL = IN_HEIGHT * IN_WIDTH * CHANNELS;

    // Test tracking
    int test_count = 0;
    int pass_count = 0;
    int fail_count = 0;
    int output_count = 0;

    AdaptiveAvgPool2d_1x1 #(
        .DATA_WIDTH(DATA_WIDTH), .IN_HEIGHT(IN_HEIGHT), .IN_WIDTH(IN_WIDTH), .CHANNELS(CHANNELS)
    ) uut (
        .clk(clk), .rst(rst), .in_data(in_data), .in_valid(in_valid), .out_data(out_data), .out_valid(out_valid)
    );

    initial clk = 0;
    always #5 clk = ~clk;

    // Add debug monitoring
    always @(posedge clk) begin
        if (in_valid) begin
            $display("🔵 DEBUG: Input[%0d] = %0d", output_count, in_data);
        end
        if (out_valid) begin
            $display("🟢 DEBUG: Output[%0d] = %0d", output_count, out_data);
            output_count++;
        end
    end

    // Task to check test result
    task check_result(input [15:0] expected, input [15:0] actual, input string test_name);
        test_count++;
        if (expected == actual) begin
            $display("[TEST %0d] ✅ PASS: %s - Expected: %0d, Got: %0d", test_count, test_name, expected, actual);
            pass_count++;
        end else begin
            $display("[TEST %0d] ❌ FAIL: %s - Expected: %0d, Got: %0d", test_count, test_name, expected, actual);
            fail_count++;
        end
    endtask

    task feed_and_check(input [15:0] vals [0:TOTAL-1], input [15:0] expected [0:CHANNELS-1], input string msg);
        int i, c, got, exp, found;
        automatic int ch_idx = 0;
        automatic int timeout_cycles = 0;
        
        $display("\n🧪 Testing: %s", msg);
        $display("📊 Configuration: %0dx%0d pixels per channel, %0d channels, total %0d inputs", 
                 IN_HEIGHT, IN_WIDTH, CHANNELS, TOTAL);
        
        rst = 1; in_data = 0; in_valid = 0; output_count = 0; 
        @(negedge clk); 
        rst = 0;
        @(negedge clk);
        
        $display("📤 Sending %0d input values:", TOTAL);
        for (i = 0; i < TOTAL; i++) begin
            in_data = vals[i]; 
            in_valid = 1;
            $display("   Input[%0d] = %0d (Ch=%0d)", i, vals[i], i/(IN_HEIGHT*IN_WIDTH));
            @(negedge clk);
        end
        in_valid = 0;
        $display("✅ All inputs sent. Waiting for outputs...");
        
        // Wait for outputs for all channels with timeout
        ch_idx = 0;
        timeout_cycles = 0;
        while (ch_idx < CHANNELS && timeout_cycles < 50) begin
            @(posedge clk);
            timeout_cycles++;
            if (out_valid) begin
                got = out_data;
                exp = expected[ch_idx];
                $display("📥 Received output[%0d] = %0d (expected %0d)", ch_idx, got, exp);
                check_result(exp, got, $sformatf("%s Channel %0d", msg, ch_idx));
                ch_idx++;
                timeout_cycles = 0; // Reset timeout on successful output
            end
        end
        
        if (ch_idx < CHANNELS) begin
            $display("⚠️  TIMEOUT: Only received %0d/%0d outputs after %0d cycles", ch_idx, CHANNELS, timeout_cycles);
        end else begin
            $display("✅ All %0d outputs received successfully", CHANNELS);
        end
    endtask

    // Task to display final summary
    task display_summary();
        string separator;
        separator = "==================================================";
        $display("\n%s", separator);
        $display("ADAPTIVE AVERAGE POOL TEST SUMMARY");
        $display("%s", separator);
        $display("Total Tests: %0d", test_count);
        $display("Passed:      %0d", pass_count);  
        $display("Failed:      %0d", fail_count);
        $display("Success Rate: %.1f%%", (real'(pass_count) / real'(test_count)) * 100.0);
        
        if (fail_count == 0) begin
            $display("🎉 ALL TESTS PASSED!");
        end else begin
            $display("⚠️  Some tests failed.");
        end
        $display("%s", separator);
    endtask

    initial begin
        // Test arrays - declare first
        logic [15:0] test_vals [0:TOTAL-1];
        logic [15:0] test_exp [0:CHANNELS-1];
        int i;
        
        $display("🚀 Starting Enhanced AdaptiveAvgPool2d Tests");
        $display("Configuration: %0dx%0d input, %0d channels", IN_HEIGHT, IN_WIDTH, CHANNELS);

        // Simple test first: All same values
        $display("\n=== TEST 1: All Same Values ===");
        for (i = 0; i < TOTAL; i++) test_vals[i] = 100;
        for (i = 0; i < CHANNELS; i++) test_exp[i] = 100;
        feed_and_check(test_vals, test_exp, "All same values (100)");

        // All zeros test
        $display("\n=== TEST 2: All Zeros ===");
        for (i = 0; i < TOTAL; i++) test_vals[i] = 0;
        for (i = 0; i < CHANNELS; i++) test_exp[i] = 0;
        feed_and_check(test_vals, test_exp, "All zeros");

        // Different per channel test (simple)
        $display("\n=== TEST 3: Different Per Channel ===");
        test_vals[0] = 1; test_vals[1] = 2; test_vals[2] = 3; test_vals[3] = 4;  // Ch0: avg = 2.5
        test_vals[4] = 10; test_vals[5] = 20; test_vals[6] = 30; test_vals[7] = 40; // Ch1: avg = 25
        test_exp[0] = (1+2+3+4)/4; test_exp[1] = (10+20+30+40)/4;
        feed_and_check(test_vals, test_exp, "Different per channel");

        display_summary();
        $finish;
    end
endmodule 