// Simple testbench for serial BatchNorm_param
module tb_BatchNorm_param;
    logic clk, rst;
    logic signed [15:0] in_data, mean, variance, gamma, beta;
    logic signed [15:0] out_data;
    logic out_valid;
    logic in_valid;

    BatchNorm_param #(.DATA_WIDTH(16)) uut (
        .clk(clk), .rst(rst), .in_data(in_data), .in_valid(in_valid), 
        .mean(mean), .variance(variance), .gamma(gamma), .beta(beta), 
        .out_data(out_data), .out_valid(out_valid)
    );

    initial clk = 0;
    always #5 clk = ~clk;

    initial begin
        $display("Starting BatchNorm Tests");
        
        rst = 1;
        in_data = 0; mean = 0; variance = 1; gamma = 1; beta = 0; in_valid = 0;
        #20;
        rst = 0;
        #10;

        // Test 1: Simple pass-through
        $display("Test 1: Simple pass-through");
        mean = 0; variance = 1; gamma = 1; beta = 0;
        in_valid = 1;
        in_data = 100;
        @(negedge clk);
        in_valid = 0;
        repeat (10) @(negedge clk);

        // Test 2: Mean subtraction
        $display("Test 2: Mean subtraction");
        mean = 5; variance = 1; gamma = 1; beta = 0;
        in_valid = 1;
        in_data = 15;
        @(negedge clk);
        in_valid = 0;
        repeat (10) @(negedge clk);

        // Test 3: Zero input
        $display("Test 3: Zero input");
        mean = 0; variance = 1; gamma = 1; beta = 0;
        in_valid = 1;
        in_data = 0;
        @(negedge clk);
        in_valid = 0;
        repeat (10) @(negedge clk);

        $display("BatchNorm test completed");
        $finish;
    end

    always @(posedge clk) begin
        if (out_valid) $display("BatchNorm Output: %0d", out_data);
    end
endmodule 