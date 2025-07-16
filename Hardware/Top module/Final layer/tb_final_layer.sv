`timescale 1ns / 1ps

module tb_final_layer;

    // Parameters - Updated to match the reduced design  
    localparam WIDTH = 16;
    localparam FRAC = 8;
    localparam IN_CHANNELS = 16;      // Reduced from 96
    localparam MID_CHANNELS = 32;     // Reduced from 576
    localparam LINEAR_FEATURES_IN = 32;   // Reduced from 576
    localparam LINEAR_FEATURES_MID = 64;  // Reduced from 1280
    localparam NUM_CLASSES = 15;
    localparam FEATURE_SIZE = 7;

    // Testbench signals
    reg clk;
    reg rst;
    reg en;
    reg signed [WIDTH-1:0] data_in;
    reg [$clog2(IN_CHANNELS)-1:0] channel_in;
    reg valid_in;

    // Weight memory interface - FIXED: Using new interface instead of massive arrays
    wire [$clog2(IN_CHANNELS*MID_CHANNELS + MID_CHANNELS*2 + LINEAR_FEATURES_MID*LINEAR_FEATURES_IN + LINEAR_FEATURES_MID*3 + NUM_CLASSES*LINEAR_FEATURES_MID + NUM_CLASSES)-1:0] weight_addr;
    wire weight_req;
    reg [WIDTH-1:0] weight_data;
    reg weight_valid;
    wire [3:0] weight_type;

    wire signed [WIDTH-1:0] data_out [0:NUM_CLASSES-1];
    wire valid_out;

    // Instantiate the DUT
    final_layer_top #(
        .WIDTH(WIDTH),
        .FRAC(FRAC),
        .IN_CHANNELS(IN_CHANNELS),
        .MID_CHANNELS(MID_CHANNELS),
        .LINEAR_FEATURES_IN(LINEAR_FEATURES_IN),
        .LINEAR_FEATURES_MID(LINEAR_FEATURES_MID),
        .NUM_CLASSES(NUM_CLASSES),
        .FEATURE_SIZE(FEATURE_SIZE)
    ) dut (
        .clk(clk),
        .rst(rst),
        .en(en),
        .data_in(data_in),
        .channel_in(channel_in),
        .valid_in(valid_in),
        // New weight memory interface
        .weight_addr(weight_addr),
        .weight_req(weight_req),
        .weight_data(weight_data),
        .weight_valid(weight_valid),
        .weight_type(weight_type),
        .data_out(data_out),
        .valid_out(valid_out)
    );

    // Clock generation
    always #5 clk = ~clk;

    // Simple weight response mechanism for testing
    always @(posedge clk) begin
        if (rst) begin
            weight_data <= 0;
            weight_valid <= 0;
        end else begin
            if (weight_req) begin
                // Provide simple test weights based on type
                case (weight_type)
                    4'd1: weight_data <= 16'h0100; // BN1 gamma = 1.0
                    4'd2: weight_data <= 16'h0000; // BN1 beta = 0.0
                    4'd4: weight_data <= 16'h0040; // Linear1 bias = 0.25
                    4'd5: weight_data <= 16'h0100; // BN2 gamma = 1.0
                    4'd6: weight_data <= 16'h0000; // BN2 beta = 0.0
                    4'd8: weight_data <= 16'h0040; // Linear2 bias = 0.25
                    default: weight_data <= 16'h0010; // Default small weight
                endcase
                weight_valid <= 1;
            end else begin
                weight_valid <= 0;
            end
        end
    end

    // Main test sequence
    initial begin
        // Dump waves
        $dumpfile("tb_final_layer.vcd");
        $dumpvars(0, tb_final_layer);

        // 1. Initialize and reset
        clk = 0;
        rst = 1;
        en = 0;
        data_in = 0;
        channel_in = 0;
        valid_in = 0;

        // Initialize weight memory interface signals
        weight_data = 0;
        weight_valid = 0;
        
        #20;
        rst = 0;
        #10;
        en = 1;

        // Wait for all modules to initialize
        repeat(1000) @(posedge clk);

        // 2. Feed one full 7x7 feature map
        for (int pixel = 0; pixel < FEATURE_SIZE * FEATURE_SIZE; pixel++) begin
            for (int channel = 0; channel < IN_CHANNELS; channel++) begin
                @(posedge clk);
                valid_in = 1'b1;
                data_in = ((pixel + channel + 1) << FRAC) / 64; 
                channel_in = channel;
            end
            @(posedge clk);
            valid_in = 1'b0;
            channel_in = 0;
            data_in = 0;
            
            repeat(100) @(posedge clk); // Shorter delay for smaller network
        end

        // 3. Wait for the final output to be valid with timeout
        repeat(50000) begin // Smaller timeout for smaller network
            @(posedge clk);
            if (valid_out) begin
                $display("[%0t] Final output is valid.", $time);
                
                // Print the output values
                for (int i = 0; i < NUM_CLASSES; i++) begin
                    $display("Output[%0d]: %d", i, data_out[i]);
                end

                $display("[%0t] Simulation completed successfully.", $time);
                $finish;
            end
        end
        
        // If we reach here, timeout occurred
        $display("[%0t] ERROR: Simulation timeout - valid_out never asserted", $time);
        $finish;
        
        $finish;
    end

endmodule