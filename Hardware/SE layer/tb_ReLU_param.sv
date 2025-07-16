// Simple testbench for serial ReLU_param
module tb_ReLU_param;
    logic clk, rst;
    logic signed [15:0] in_data;
    logic [15:0] out_data;
    logic out_valid;
    logic in_valid;

    ReLU_param #(.DATA_WIDTH(16)) uut (
        .clk(clk), .rst(rst), .in_data(in_data), .in_valid(in_valid), .out_data(out_data), .out_valid(out_valid)
    );

    initial clk = 0;
    always #5 clk = ~clk;

    initial begin
        rst = 1;
        in_data = 0; in_valid = 0;
        #20;
        rst = 0;
        
        $display("Testing ReLU with various inputs");
        
        // Feed test values
        in_valid = 1;
        in_data = -5; @(negedge clk);
        in_data = 0; @(negedge clk);
        in_data = 7; @(negedge clk);
        in_data = -2; @(negedge clk);
        in_valid = 0;
        
        // Wait for output
        repeat (10) @(negedge clk);
        $display("ReLU test completed");
        $finish;
    end

    always @(posedge clk) begin
        if (out_valid) $display("ReLU Input: %0d -> Output: %0d", $past(in_data), out_data);
    end
endmodule 