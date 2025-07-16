module final_layer_top #(
    parameter WIDTH = 16,
    parameter FRAC = 8,
    parameter IN_CHANNELS = 96,     // Keep to match BottleNeck output 
    parameter MID_CHANNELS = 64,    // OPTIMIZED: Reduced from 576 to 64
    parameter LINEAR_FEATURES_IN = 64,   // OPTIMIZED: Reduced from 576 to 64
    parameter LINEAR_FEATURES_MID = 128, // OPTIMIZED: Reduced from 1280 to 128
    parameter NUM_CLASSES = 15,
    parameter FEATURE_SIZE = 7
) (
    input wire clk,
    input wire rst,
    input wire en,

    // Input to the first pointwise convolution
    input wire signed [WIDTH-1:0] data_in,
    input wire [$clog2(IN_CHANNELS)-1:0] channel_in,
    input wire valid_in,

    // Weight Memory Interface - FIXED: No more massive I/O arrays
    output reg [$clog2(IN_CHANNELS*MID_CHANNELS + MID_CHANNELS*2 + LINEAR_FEATURES_MID*LINEAR_FEATURES_IN + LINEAR_FEATURES_MID*3 + NUM_CLASSES*LINEAR_FEATURES_MID + NUM_CLASSES)-1:0] weight_addr,
    output reg weight_req,
    input wire signed [WIDTH-1:0] weight_data,
    input wire weight_valid,
    output reg [3:0] weight_type, // 0=pw_conv, 1=bn1_gamma, 2=bn1_beta, 3=linear1_w, 4=linear1_b, 5=bn2_gamma, 6=bn2_beta, 7=linear2_w, 8=linear2_b

    // Final output of the network
    output reg signed [WIDTH-1:0] data_out [0:NUM_CLASSES-1],
    output reg valid_out
);

    // Weight Memory Type Constants
    localparam WEIGHT_PW_CONV = 4'd0;
    localparam WEIGHT_BN1_GAMMA = 4'd1;
    localparam WEIGHT_BN1_BETA = 4'd2;
    localparam WEIGHT_LINEAR1_W = 4'd3;
    localparam WEIGHT_LINEAR1_B = 4'd4;
    localparam WEIGHT_BN2_GAMMA = 4'd5;
    localparam WEIGHT_BN2_BETA = 4'd6;
    localparam WEIGHT_LINEAR2_W = 4'd7;
    localparam WEIGHT_LINEAR2_B = 4'd8;

    // Internal weight storage - OPTIMIZED for reduced sizes
    (* ram_style = "block" *) reg signed [WIDTH-1:0] pw_conv_weights [0:IN_CHANNELS*MID_CHANNELS-1];  // 96*64 = 6144 (was 55296)
    (* ram_style = "distributed" *) reg signed [WIDTH-1:0] bn1_gamma [0:MID_CHANNELS-1];        // 64 (was 576)
    (* ram_style = "distributed" *) reg signed [WIDTH-1:0] bn1_beta [0:MID_CHANNELS-1];         // 64 (was 576) 
    (* ram_style = "distributed" *) reg signed [WIDTH-1:0] linear1_biases [0:LINEAR_FEATURES_MID-1]; // 128 (was 1280)
    (* ram_style = "distributed" *) reg signed [WIDTH-1:0] bn2_gamma [0:LINEAR_FEATURES_MID-1];      // 128 (was 1280)
    (* ram_style = "distributed" *) reg signed [WIDTH-1:0] bn2_beta [0:LINEAR_FEATURES_MID-1];       // 128 (was 1280)
    (* ram_style = "distributed" *) reg signed [WIDTH-1:0] linear2_biases [0:NUM_CLASSES-1];        // 15

    // Weight loading state machine
    typedef enum logic [3:0] {
        WEIGHT_IDLE,
        LOAD_PW_CONV,
        LOAD_BN1_GAMMA,
        LOAD_BN1_BETA,
        LOAD_LINEAR1_BIAS,
        LOAD_BN2_GAMMA,
        LOAD_BN2_BETA,
        LOAD_LINEAR2_BIAS,
        WEIGHTS_READY,
        PROCESSING
    } weight_state_t;
    
    weight_state_t weight_state;
    reg [$clog2(IN_CHANNELS*MID_CHANNELS+1)-1:0] weight_load_counter;
    reg weights_loaded;

    // Weight loading logic
    always @(posedge clk) begin
        if (rst) begin
            weight_state <= WEIGHT_IDLE;
            weight_load_counter <= 0;
            weight_req <= 1'b0;
            weights_loaded <= 1'b0;
            weight_addr <= 0;
            weight_type <= 0;
        end else begin
            case (weight_state)
                WEIGHT_IDLE: begin
                    if (en && !weights_loaded) begin
                        weight_state <= LOAD_PW_CONV;
                        weight_load_counter <= 0;
                        weight_req <= 1'b1;
                        weight_type <= WEIGHT_PW_CONV;
                        weight_addr <= 0;
                    end
                end
                
                LOAD_PW_CONV: begin
                    if (weight_valid && weight_load_counter < IN_CHANNELS*MID_CHANNELS) begin
                        pw_conv_weights[weight_load_counter] <= weight_data;
                        weight_load_counter <= weight_load_counter + 1;
                        weight_addr <= weight_addr + 1;
                    end
                    if (weight_load_counter >= IN_CHANNELS*MID_CHANNELS-1) begin
                        weight_state <= LOAD_BN1_GAMMA;
                        weight_load_counter <= 0;
                        weight_type <= WEIGHT_BN1_GAMMA;
                        weight_addr <= 0;
                    end
                end
                
                LOAD_BN1_GAMMA: begin
                    if (weight_valid && weight_load_counter < MID_CHANNELS) begin
                        bn1_gamma[weight_load_counter] <= weight_data;
                        weight_load_counter <= weight_load_counter + 1;
                        weight_addr <= weight_addr + 1;
                    end
                    if (weight_load_counter >= MID_CHANNELS-1) begin
                        weight_state <= LOAD_BN1_BETA;
                        weight_load_counter <= 0;
                        weight_type <= WEIGHT_BN1_BETA;
                        weight_addr <= 0;
                    end
                end
                
                LOAD_BN1_BETA: begin
                    if (weight_valid && weight_load_counter < MID_CHANNELS) begin
                        bn1_beta[weight_load_counter] <= weight_data;
                        weight_load_counter <= weight_load_counter + 1;
                        weight_addr <= weight_addr + 1;
                    end
                    if (weight_load_counter >= MID_CHANNELS-1) begin
                        weight_state <= LOAD_LINEAR1_BIAS;
                        weight_load_counter <= 0;
                        weight_type <= WEIGHT_LINEAR1_B;
                        weight_addr <= 0;
                    end
                end
                
                LOAD_LINEAR1_BIAS: begin
                    if (weight_valid && weight_load_counter < LINEAR_FEATURES_MID) begin
                        linear1_biases[weight_load_counter] <= weight_data;
                        weight_load_counter <= weight_load_counter + 1;
                        weight_addr <= weight_addr + 1;
                    end
                    if (weight_load_counter >= LINEAR_FEATURES_MID-1) begin
                        weight_state <= LOAD_BN2_GAMMA;
                        weight_load_counter <= 0;
                        weight_type <= WEIGHT_BN2_GAMMA;
                        weight_addr <= 0;
                    end
                end
                
                LOAD_BN2_GAMMA: begin
                    if (weight_valid && weight_load_counter < LINEAR_FEATURES_MID) begin
                        bn2_gamma[weight_load_counter] <= weight_data;
                        weight_load_counter <= weight_load_counter + 1;
                        weight_addr <= weight_addr + 1;
                    end
                    if (weight_load_counter >= LINEAR_FEATURES_MID-1) begin
                        weight_state <= LOAD_BN2_BETA;
                        weight_load_counter <= 0;
                        weight_type <= WEIGHT_BN2_BETA;
                        weight_addr <= 0;
                    end
                end
                
                LOAD_BN2_BETA: begin
                    if (weight_valid && weight_load_counter < LINEAR_FEATURES_MID) begin
                        bn2_beta[weight_load_counter] <= weight_data;
                        weight_load_counter <= weight_load_counter + 1;
                        weight_addr <= weight_addr + 1;
                    end
                    if (weight_load_counter >= LINEAR_FEATURES_MID-1) begin
                        weight_state <= LOAD_LINEAR2_BIAS;
                        weight_load_counter <= 0;
                        weight_type <= WEIGHT_LINEAR2_B;
                        weight_addr <= 0;
                    end
                end
                
                LOAD_LINEAR2_BIAS: begin
                    if (weight_valid && weight_load_counter < NUM_CLASSES) begin
                        linear2_biases[weight_load_counter] <= weight_data;
                        weight_load_counter <= weight_load_counter + 1;
                        weight_addr <= weight_addr + 1;
                    end
                    if (weight_load_counter >= NUM_CLASSES-1) begin
                        weight_state <= WEIGHTS_READY;
                        weight_req <= 1'b0;
                        weights_loaded <= 1'b1;
                    end
                end
                
                WEIGHTS_READY: begin
                    if (valid_in) begin
                        weight_state <= PROCESSING;
                    end
                end
                
                PROCESSING: begin
                    // Stay in processing state during normal operation
                    // Large weights (linear1_weights, linear2_weights) accessed via external memory
                end
                
                default: weight_state <= WEIGHT_IDLE;
            endcase
        end
    end

    // Wires for connecting the modules
    wire signed [WIDTH-1:0] pw_conv_out_data;
    wire [$clog2(MID_CHANNELS)-1:0] pw_conv_out_channel;
    wire pw_conv_out_valid;

    wire signed [WIDTH-1:0] bn1_out_data;
    wire [$clog2(MID_CHANNELS)-1:0] bn1_out_channel;
    wire bn1_out_valid;

    wire signed [WIDTH-1:0] hswish1_out_data;
    wire hswish1_out_valid;

    // Pipeline registers to synchronize channel with hswish1 output
    reg [$clog2(MID_CHANNELS)-1:0] hswish1_out_channel;
    reg [$clog2(MID_CHANNELS)-1:0] bn1_channel_pipe [0:3]; // 4-stage pipeline to match hswish latency

    wire signed [WIDTH-1:0] linear1_out_data [0:LINEAR_FEATURES_MID-1];
    wire linear1_out_valid;

    wire signed [WIDTH-1:0] bn2_out_data [0:LINEAR_FEATURES_MID-1];
    wire bn2_out_valid;

    // Registers to hold the collected features for linear1
    reg signed [WIDTH-1:0] linear1_input_reg [0:LINEAR_FEATURES_IN-1];
    reg linear1_input_valid_reg;

    // Internal buffer for collecting features - simplified approach
    reg signed [WIDTH-1:0] linear1_collect_buffer [0:LINEAR_FEATURES_IN-1];
    reg [$clog2(LINEAR_FEATURES_IN+1):0] linear1_collect_count;
    reg linear1_collecting_active;

    // Pack weights for sub-modules
    wire [(IN_CHANNELS*MID_CHANNELS*WIDTH)-1:0] pw_conv_weights_packed;
    wire [(MID_CHANNELS*WIDTH)-1:0] bn1_gamma_packed;
    wire [(MID_CHANNELS*WIDTH)-1:0] bn1_beta_packed;
    
    genvar i;
    generate
        for (i = 0; i < IN_CHANNELS*MID_CHANNELS; i = i + 1) begin : pack_pw_weights
            assign pw_conv_weights_packed[i*WIDTH +: WIDTH] = pw_conv_weights[i];
        end
        for (i = 0; i < MID_CHANNELS; i = i + 1) begin : pack_bn1_params
            assign bn1_gamma_packed[i*WIDTH +: WIDTH] = bn1_gamma[i];
            assign bn1_beta_packed[i*WIDTH +: WIDTH] = bn1_beta[i];
        end
    endgenerate

    // Instantiate the modules

    pointwise_conv #(
        .N(WIDTH),
        .Q(FRAC),
        .IN_CHANNELS(IN_CHANNELS),
        .OUT_CHANNELS(MID_CHANNELS),
        .FEATURE_SIZE(FEATURE_SIZE)
    ) pw_conv_inst (
        .clk(clk),
        .rst(rst),
        .en(en && weights_loaded),
        .data_in(data_in),
        .channel_in(channel_in),
        .valid_in(valid_in),
        // Updated interface for external weight memory
        .weight_addr(/* connect to weight memory manager */),
        .weight_req(/* connect to weight memory manager */),
        .weight_data(/* connect from weight memory manager */),
        .weight_valid(/* connect from weight memory manager */),
        .data_out(pw_conv_out_data),
        .channel_out(pw_conv_out_channel),
        .valid_out(pw_conv_out_valid)
    );

    batchnorm #(
        .WIDTH(WIDTH),
        .FRAC(FRAC),
        .CHANNELS(MID_CHANNELS)
    ) bn1_inst (
        .clk(clk),
        .rst(rst),
        .en(en && weights_loaded),
        .x_in(pw_conv_out_data),
        .channel_in(pw_conv_out_channel),
        .valid_in(pw_conv_out_valid),
        .gamma_packed(bn1_gamma_packed),
        .beta_packed(bn1_beta_packed),
        .y_out(bn1_out_data),
        .channel_out(bn1_out_channel),
        .valid_out(bn1_out_valid)
    );

    hswish #(
        .WIDTH(WIDTH),
        .FRAC(FRAC)
    ) hswish1_inst (
        .clk(clk),
        .rst(rst),
        .en(en && weights_loaded),
        .data_in(bn1_out_data),
        .valid_in(bn1_out_valid),
        .data_out(hswish1_out_data),
        .valid_out(hswish1_out_valid)
    );

    // --- FSM for collecting hswish1 output for linear1 ---
    typedef enum logic [1:0] {COLLECT_IDLE, COLLECTING, COLLECT_DONE} collect_state_t;
    collect_state_t collect_state;

    always @(posedge clk) begin
        if (rst) begin
            linear1_collect_count <= 0;
            linear1_input_valid_reg <= 1'b0;
            collect_state <= COLLECT_IDLE;
            for (int j = 0; j < LINEAR_FEATURES_IN; j++) begin
                linear1_input_reg[j] <= 0;
            end
        end else if (en && weights_loaded) begin
            case (collect_state)
                COLLECT_IDLE: begin
                    // If the first valid data arrives from hswish1, start collecting
                    if (hswish1_out_valid) begin
                        linear1_input_reg[0] <= hswish1_out_data;
                        linear1_collect_count <= 1;
                        collect_state <= COLLECTING;
                    end
                end

                COLLECTING: begin
                    // Continue collecting data as it becomes available
                    if (hswish1_out_valid) begin
                        linear1_input_reg[linear1_collect_count] <= hswish1_out_data;
                        linear1_collect_count <= linear1_collect_count + 1;
                        // If all features are collected, move to the DONE state
                        if (linear1_collect_count == LINEAR_FEATURES_IN - 1) begin
                            collect_state <= COLLECT_DONE;
                            linear1_input_valid_reg <= 1'b1; // Assert valid for the linear layer
                        end
                    end
                end

                COLLECT_DONE: begin
                    // Keep valid high until linear layer finishes processing
                    if (linear1_out_valid) begin
                        linear1_input_valid_reg <= 1'b0;
                        linear1_collect_count <= 0;
                        collect_state <= COLLECT_IDLE;
                    end else begin
                        linear1_input_valid_reg <= 1'b1;
                    end
                end
                
                default: collect_state <= COLLECT_IDLE;
            endcase
        end
    end

    linear_external_weights #(
        .WIDTH(WIDTH),
        .FRAC(FRAC),
        .IN_FEATURES(LINEAR_FEATURES_IN),
        .OUT_FEATURES(LINEAR_FEATURES_MID)
    ) linear1_inst (
        .clk(clk),
        .rst(rst),
        .en(en && weights_loaded),
        .feature_in(linear1_input_reg),
        .valid_in(linear1_input_valid_reg),
        .bias_data(linear1_biases),
        .weight_req(/* connect to external weight manager */),
        .weight_addr(/* connect to external weight manager */),
        .weight_data(/* connect from external weight manager */),
        .weight_valid(/* connect from external weight manager */),
        .data_out(linear1_out_data),
        .valid_out(linear1_out_valid)
    );

    batchnorm1d #(
        .WIDTH(WIDTH),
        .FRAC(FRAC),
        .FEATURES(LINEAR_FEATURES_MID)
    ) bn2_inst (
        .clk(clk),
        .rst(rst),
        .en(en && weights_loaded),
        .data_in(linear1_out_data),
        .valid_in(linear1_out_valid),
        .gamma(bn2_gamma),
        .beta(bn2_beta),
        .data_out(bn2_out_data),
        .valid_out(bn2_out_valid)
    );

    // --- Sequential h-swish layer 2 ---
    wire signed [WIDTH-1:0] hswish2_out_data_single;
    wire hswish2_out_valid_single;

    // Register bank to hold the output from the sequential hswish module
    reg signed [WIDTH-1:0] hswish2_out_data [0:LINEAR_FEATURES_MID-1];
    reg hswish2_out_valid;

    // Control logic for streaming data through the sequential hswish module
    reg hswish2_streaming_active;
    reg [$clog2(LINEAR_FEATURES_MID):0] hswish2_read_count;
    reg [$clog2(LINEAR_FEATURES_MID):0] hswish2_write_count;

    // Safe indexing wire to prevent out-of-bounds access
    wire [$clog2(LINEAR_FEATURES_MID)-1:0] safe_read_index = (hswish2_read_count < LINEAR_FEATURES_MID) ? hswish2_read_count : 0;

    // Instantiate a single hswish module for the second activation layer
    hswish #(
        .WIDTH(WIDTH),
        .FRAC(FRAC)
    ) hswish2_inst (
        .clk(clk),
        .rst(rst),
        .en(en && weights_loaded),
        .data_in(bn2_out_data[safe_read_index]), // Feed data from the counter with safe indexing
        .valid_in(hswish2_streaming_active && (hswish2_read_count < LINEAR_FEATURES_MID)), // Assert valid only when streaming
        .data_out(hswish2_out_data_single),
        .valid_out(hswish2_out_valid_single)
    );

    // FSM/control logic for the sequential hswish2 layer
    always @(posedge clk) begin
        if (rst) begin
            hswish2_streaming_active <= 1'b0;
            hswish2_read_count <= 0;
            hswish2_write_count <= 0;
            hswish2_out_valid <= 1'b0;
            for (int j = 0; j < LINEAR_FEATURES_MID; j++) begin
                hswish2_out_data[j] <= 0;
            end
        end else if (en && weights_loaded) begin
            // Reset valid only when linear2 has consumed the data
            if (hswish2_out_valid && valid_out) begin
                hswish2_out_valid <= 1'b0;
            end

            // If not currently active, check for valid input from the previous layer to start
            if (!hswish2_streaming_active && bn2_out_valid) begin
                hswish2_streaming_active <= 1'b1;
                hswish2_read_count <= 0;
                hswish2_write_count <= 0;
            end

            // If the module is active, manage the data streaming
            if (hswish2_streaming_active) begin
                // Increment read counter to feed all features into the hswish module
                if (hswish2_read_count < LINEAR_FEATURES_MID) begin
                    hswish2_read_count <= hswish2_read_count + 1;
                end

                // When the pipelined hswish module produces a valid output, store it
                if (hswish2_out_valid_single && (hswish2_write_count < LINEAR_FEATURES_MID)) begin
                    hswish2_out_data[hswish2_write_count] <= hswish2_out_data_single;
                    hswish2_write_count <= hswish2_write_count + 1;

                    // When all features have been processed and collected, signal completion
                    if (hswish2_write_count == LINEAR_FEATURES_MID - 1) begin
                        hswish2_out_valid <= 1'b1;
                        hswish2_streaming_active <= 1'b0; // Deactivate streaming
                    end
                end
            end
        end
    end

    linear_external_weights #(
        .WIDTH(WIDTH),
        .FRAC(FRAC),
        .IN_FEATURES(LINEAR_FEATURES_MID),
        .OUT_FEATURES(NUM_CLASSES)
    ) linear2_inst (
        .clk(clk),
        .rst(rst),
        .en(en && weights_loaded),
        .feature_in(hswish2_out_data),
        .valid_in(hswish2_out_valid),
        .bias_data(linear2_biases),
        .weight_req(/* connect to external weight manager */),
        .weight_addr(/* connect to external weight manager */),
        .weight_data(/* connect from external weight manager */),
        .weight_valid(/* connect from external weight manager */),
        .data_out(data_out),
        .valid_out(valid_out)
    );

endmodule
