module BottleNeck_const_func #(
    parameter N = 16,               // Data width
    parameter Q = 8,                // Fractional bits
    parameter IN_CHANNELS = 16,     // Input channels 
    parameter EXPAND_CHANNELS = 64, // Expanded channels (expansion ratio = 4)
    parameter OUT_CHANNELS = 16,    // Output channels
    parameter FEATURE_SIZE = 112,   // Feature map size
    parameter KERNEL_SIZE = 3,      // Depthwise kernel size
    parameter STRIDE = 1,           // Stride for depthwise conv
    parameter PADDING = 1,          // Padding for depthwise conv
    parameter BATCH_SIZE = 10,      // Batch size for BatchNorm
    parameter PIPELINE_DEPTH = 2,   // Pipeline depth for FPGA optimization
    parameter DATA_PARALLELISM = 4, // Data parallelism for processing
    // FPGA Resource-Optimized Parallelization
    parameter SPATIAL_PARALLEL = 2,   // 2-pixel spatial parallelism (resource optimized)
    parameter CHANNEL_PARALLEL = 4,   // 4-channel parallel processing per pixel
    parameter PW_PARALLEL = 2,        // Pointwise parallel processing
    parameter DW_PARALLEL = 2,        // Depthwise parallel processing
    parameter BN_PARALLEL = 2,        // BatchNorm parallel processing
    parameter USE_DSP_OPT = 1,        // Enable DSP48 optimizations
    parameter USE_BRAM_OPT = 1        // Enable BRAM optimizations
) (
    input wire clk,
    input wire rst,
    input wire en,
    
    // Input interface - optimized for 2-pixel spatial parallelism
    input wire [SPATIAL_PARALLEL*N-1:0] data_in,                         // 2 pixels per cycle
    input wire [SPATIAL_PARALLEL*$clog2(IN_CHANNELS)-1:0] channel_in,    // Channel info for each pixel
    input wire [SPATIAL_PARALLEL-1:0] valid_in,                          // Valid signal per pixel
    input wire [$clog2(FEATURE_SIZE)-1:0] row_idx,                       // Current row index
    input wire [$clog2(FEATURE_SIZE)-1:0] col_idx,                       // Current column index
    
    // Weight interfaces - properly sized for each layer
    input wire [(IN_CHANNELS*EXPAND_CHANNELS*N)-1:0] pw1_weights,        // Pointwise 1 weights
    input wire [(KERNEL_SIZE*KERNEL_SIZE*EXPAND_CHANNELS*N)-1:0] dw_weights, // Depthwise weights
    input wire [(EXPAND_CHANNELS*OUT_CHANNELS*N)-1:0] pw2_weights,       // Pointwise 2 weights
    
    // Batch normalization parameters - packed arrays for FPGA efficiency
    input wire [(EXPAND_CHANNELS*N)-1:0] bn1_gamma_packed,  // BN1 scale
    input wire [(EXPAND_CHANNELS*N)-1:0] bn1_beta_packed,   // BN1 bias
    input wire [(EXPAND_CHANNELS*N)-1:0] bn2_gamma_packed,  // BN2 scale
    input wire [(EXPAND_CHANNELS*N)-1:0] bn2_beta_packed,   // BN2 bias
    input wire [(OUT_CHANNELS*N)-1:0] bn3_gamma_packed,     // BN3 scale
    input wire [(OUT_CHANNELS*N)-1:0] bn3_beta_packed,      // BN3 bias
    
    // Output interface - optimized for 2-pixel spatial parallelism
    output wire [SPATIAL_PARALLEL*N-1:0] data_out,                       // 2 pixels output
    output wire [SPATIAL_PARALLEL*$clog2(OUT_CHANNELS)-1:0] channel_out, // Channel info for output
    output wire [SPATIAL_PARALLEL-1:0] valid_out,                        // Valid signal per output
    output wire [$clog2(FEATURE_SIZE)-1:0] out_row_idx,                  // Output row index
    output wire [$clog2(FEATURE_SIZE)-1:0] out_col_idx,                  // Output column index
    output wire done,
    // Performance monitoring for analysis
    output wire [$clog2(FEATURE_SIZE*FEATURE_SIZE/SPATIAL_PARALLEL+1)-1:0] cycles_count
);

    // Pipeline inter-module connections - optimized for 2-pixel spatial parallelism
    // Pointwise Conv 1 -> BatchNorm 1 (2 spatial pixels)
    wire [SPATIAL_PARALLEL*N-1:0] pw1_data_out;
    wire [SPATIAL_PARALLEL*$clog2(EXPAND_CHANNELS)-1:0] pw1_channel_out;
    wire [SPATIAL_PARALLEL-1:0] pw1_valid_out;
    wire [$clog2(FEATURE_SIZE)-1:0] pw1_row_out, pw1_col_out;
    wire pw1_done;
    
    // BatchNorm 1 -> ReLU 1 (2 spatial pixels)
    wire [SPATIAL_PARALLEL*N-1:0] bn1_data_out;
    wire [SPATIAL_PARALLEL*$clog2(EXPAND_CHANNELS)-1:0] bn1_channel_out;
    wire [SPATIAL_PARALLEL-1:0] bn1_valid_out;
    wire [$clog2(FEATURE_SIZE)-1:0] bn1_row_out, bn1_col_out;
    
    // ReLU 1 -> Depthwise Conv (2 spatial pixels)
    wire [SPATIAL_PARALLEL*N-1:0] relu1_data_out;
    wire [SPATIAL_PARALLEL*$clog2(EXPAND_CHANNELS)-1:0] relu1_channel_out;
    wire [SPATIAL_PARALLEL-1:0] relu1_valid_out;
    wire [$clog2(FEATURE_SIZE)-1:0] relu1_row_out, relu1_col_out;
    
    // Depthwise Conv -> BatchNorm 2 (2 spatial pixels)
    wire [SPATIAL_PARALLEL*N-1:0] dw_data_out;
    wire [SPATIAL_PARALLEL*$clog2(EXPAND_CHANNELS)-1:0] dw_channel_out;
    wire [SPATIAL_PARALLEL-1:0] dw_valid_out;
    wire [$clog2(FEATURE_SIZE)-1:0] dw_row_out, dw_col_out;
    wire dw_done;
    
    // BatchNorm 2 -> ReLU 2 (2 spatial pixels)
    wire [SPATIAL_PARALLEL*N-1:0] bn2_data_out;
    wire [SPATIAL_PARALLEL*$clog2(EXPAND_CHANNELS)-1:0] bn2_channel_out;
    wire [SPATIAL_PARALLEL-1:0] bn2_valid_out;
    wire [$clog2(FEATURE_SIZE)-1:0] bn2_row_out, bn2_col_out;
    
    // ReLU 2 -> Pointwise Conv 2 (2 spatial pixels)
    wire [SPATIAL_PARALLEL*N-1:0] relu2_data_out;
    wire [SPATIAL_PARALLEL*$clog2(EXPAND_CHANNELS)-1:0] relu2_channel_out;
    wire [SPATIAL_PARALLEL-1:0] relu2_valid_out;
    wire [$clog2(FEATURE_SIZE)-1:0] relu2_row_out, relu2_col_out;
    
    // Pointwise Conv 2 -> BatchNorm 3 (2 spatial pixels)
    wire [SPATIAL_PARALLEL*N-1:0] pw2_data_out;
    wire [SPATIAL_PARALLEL*$clog2(OUT_CHANNELS)-1:0] pw2_channel_out;
    wire [SPATIAL_PARALLEL-1:0] pw2_valid_out;
    wire [$clog2(FEATURE_SIZE)-1:0] pw2_row_out, pw2_col_out;
    wire pw2_done;
    
    // BatchNorm 3 -> Output (2 spatial pixels)
    wire [SPATIAL_PARALLEL*N-1:0] bn3_data_out;
    wire [SPATIAL_PARALLEL*$clog2(OUT_CHANNELS)-1:0] bn3_channel_out;
    wire [SPATIAL_PARALLEL-1:0] bn3_valid_out;
    wire [$clog2(FEATURE_SIZE)-1:0] bn3_row_out, bn3_col_out;
    
    // Enhanced state machine for better synthesis
    typedef enum logic [2:0] {
        IDLE,
        PROCESSING,
        COMPLETING,
        DONE_STATE,
        ERROR_STATE
    } state_t;
    
    state_t state, next_state;
    
    // Optimized control counters for spatial parallelism
    reg [$clog2(FEATURE_SIZE*FEATURE_SIZE/SPATIAL_PARALLEL + 1)-1:0] input_count;
    reg [$clog2(FEATURE_SIZE*FEATURE_SIZE/SPATIAL_PARALLEL + 1)-1:0] output_count;
    reg [$clog2(FEATURE_SIZE*FEATURE_SIZE/SPATIAL_PARALLEL + 1)-1:0] cycle_counter;
    reg input_finished;
    reg module_enable;
    reg processing_valid;
    
    // Calculate total pixel groups for 2-pixel spatial parallelism
    localparam TOTAL_PIXEL_GROUPS = FEATURE_SIZE * FEATURE_SIZE / SPATIAL_PARALLEL;
    
    // Enhanced state machine control
    always @(posedge clk) begin
        if (rst) begin
            state <= IDLE;
        end else begin
            state <= next_state;
        end
    end
    
    // Next state logic - improved for better synthesis
    always @(*) begin
        case (state)
            IDLE: begin
                if (en)
                    next_state = PROCESSING;
                else
                    next_state = IDLE;
            end
            
            PROCESSING: begin
                if (output_count >= TOTAL_PIXEL_GROUPS)
                    next_state = COMPLETING;
                else
                    next_state = PROCESSING;
            end
            
            COMPLETING: begin
                // Allow pipeline to flush
                next_state = DONE_STATE;
            end
            
            DONE_STATE: begin
                if (!en)
                    next_state = IDLE;
                else
                    next_state = DONE_STATE;
            end
            
            ERROR_STATE: begin
                next_state = IDLE;  // Reset on error
            end
            
            default: next_state = IDLE;
        endcase
    end
    
    // Main control logic
    always @(posedge clk) begin
        if (rst) begin
            input_count <= {$clog2(FEATURE_SIZE*FEATURE_SIZE/SPATIAL_PARALLEL + 1){1'b0}};
            output_count <= {$clog2(FEATURE_SIZE*FEATURE_SIZE/SPATIAL_PARALLEL + 1){1'b0}};
            cycle_counter <= {$clog2(FEATURE_SIZE*FEATURE_SIZE/SPATIAL_PARALLEL + 1){1'b0}};
            input_finished <= 1'b0;
            module_enable <= 1'b0;
            processing_valid <= 1'b0;
        end else begin
            case (state)
                IDLE: begin
                    if (en) begin
                        input_count <= {$clog2(FEATURE_SIZE*FEATURE_SIZE/SPATIAL_PARALLEL + 1){1'b0}};
                        output_count <= {$clog2(FEATURE_SIZE*FEATURE_SIZE/SPATIAL_PARALLEL + 1){1'b0}};
                        cycle_counter <= {$clog2(FEATURE_SIZE*FEATURE_SIZE/SPATIAL_PARALLEL + 1){1'b0}};
                        input_finished <= 1'b0;
                        module_enable <= 1'b1;
                        processing_valid <= 1'b1;
                    end
                end
                
                PROCESSING: begin
                    // Increment cycle counter for performance monitoring
                    cycle_counter <= cycle_counter + 1'b1;

                    // Count input pixel groups (2 pixels processed per cycle)
                    if (!input_finished && (|valid_in)) begin
                        input_count <= input_count + 1'b1;
                        if ((input_count + 1'b1) >= TOTAL_PIXEL_GROUPS) begin
                            input_finished <= 1'b1;
                        end
                    end
                    
                    // Count output pixel groups and check for completion
                    if (|valid_out) begin
                        output_count <= output_count + 1'b1;
                    end
                end
                
                COMPLETING: begin
                    // Pipeline flush - maintain enable but don't accept new inputs
                    processing_valid <= 1'b0;
                end
                
                DONE_STATE: begin
                    // Disable modules when done
                    module_enable <= 1'b0;
                    processing_valid <= 1'b0;
                end
                
                ERROR_STATE: begin
                    // Reset all counters on error
                    module_enable <= 1'b0;
                    processing_valid <= 1'b0;
                end
            endcase
        end
    end
    
    // Performance monitoring assignment
    assign cycles_count = cycle_counter;
    assign out_row_idx = bn3_row_out;
    assign out_col_idx = bn3_col_out;

    // MODULE INSTANTIATIONS - OPTIMIZED FOR 2-PIXEL SPATIAL PARALLELISM
    
    // 1. Pointwise Convolution 1 (Expansion: 16->64 channels) - 2 spatial pixels
    genvar pw1_i;
    generate
        for (pw1_i = 0; pw1_i < SPATIAL_PARALLEL; pw1_i = pw1_i + 1) begin : gen_pw_conv1
            pointwise_conv #(
                .N(N),
                .Q(Q),
                .IN_CHANNELS(IN_CHANNELS),
                .OUT_CHANNELS(EXPAND_CHANNELS),
                .FEATURE_SIZE(FEATURE_SIZE),
                .PARALLELISM(CHANNEL_PARALLEL)
            ) pw_conv1_inst (
                .clk(clk),
                .rst(rst),
                .en(module_enable && processing_valid),
                .data_in(data_in[pw1_i*N +: N]),
                .channel_in(channel_in[pw1_i*$clog2(IN_CHANNELS) +: $clog2(IN_CHANNELS)]),
                .valid_in(valid_in[pw1_i] && processing_valid),
                .weights(pw1_weights),
                .data_out(pw1_data_out[pw1_i*N +: N]),
                .channel_out(pw1_channel_out[pw1_i*$clog2(EXPAND_CHANNELS) +: $clog2(EXPAND_CHANNELS)]),
                .valid_out(pw1_valid_out[pw1_i]),
                .done()  // Individual done signals not used in this design
            );
        end
    endgenerate
    
    // Position tracking for spatial parallelism
    assign pw1_row_out = row_idx;
    assign pw1_col_out = col_idx;
    
    // Aggregate done signal from all parallel pointwise conv1 units
    wire [SPATIAL_PARALLEL-1:0] pw1_done_signals;
    genvar pw1_done_i;
    generate
        for (pw1_done_i = 0; pw1_done_i < SPATIAL_PARALLEL; pw1_done_i = pw1_done_i + 1) begin : gen_pw1_done
            assign pw1_done_signals[pw1_done_i] = gen_pw_conv1[pw1_done_i].pw_conv1_inst.done;
        end
    endgenerate
    assign pw1_done = &pw1_done_signals | (state == DONE_STATE);
    
    // 2. BatchNorm 1 - 2 SPATIAL PIXELS
    genvar bn1_i;
    generate
        for (bn1_i = 0; bn1_i < SPATIAL_PARALLEL; bn1_i = bn1_i + 1) begin : gen_bn1
            batchnorm #(
                .WIDTH(N),
                .FRAC(Q),
                .CHANNELS(EXPAND_CHANNELS)
            ) bn1_inst (
                .clk(clk),
                .rst(rst),
                .en(module_enable),
                .x_in(pw1_data_out[bn1_i*N +: N]),
                .channel_in(pw1_channel_out[bn1_i*$clog2(EXPAND_CHANNELS) +: $clog2(EXPAND_CHANNELS)]),
                .valid_in(pw1_valid_out[bn1_i]),
                .gamma_packed(bn1_gamma_packed),
                .beta_packed(bn1_beta_packed),
                .y_out(bn1_data_out[bn1_i*N +: N]),
                .channel_out(bn1_channel_out[bn1_i*$clog2(EXPAND_CHANNELS) +: $clog2(EXPAND_CHANNELS)]),
                .valid_out(bn1_valid_out[bn1_i])
            );
        end
    endgenerate
    
    // Position tracking
    assign bn1_row_out = pw1_row_out;
    assign bn1_col_out = pw1_col_out;
    
    // 3. ReLU 1 - 2 SPATIAL PIXELS
    genvar relu1_i;
    generate
        for (relu1_i = 0; relu1_i < SPATIAL_PARALLEL; relu1_i = relu1_i + 1) begin : gen_relu1
            Relu #(
                .N(N),
                .CHANNELS(EXPAND_CHANNELS)
            ) relu1_inst (
                .clk(clk),
                .rst(rst),
                .data_in(bn1_data_out[relu1_i*N +: N]),
                .channel_in(bn1_channel_out[relu1_i*$clog2(EXPAND_CHANNELS) +: $clog2(EXPAND_CHANNELS)]),
                .valid_in(bn1_valid_out[relu1_i]),
                .data_out(relu1_data_out[relu1_i*N +: N]),
                .channel_out(relu1_channel_out[relu1_i*$clog2(EXPAND_CHANNELS) +: $clog2(EXPAND_CHANNELS)]),
                .valid_out(relu1_valid_out[relu1_i])
            );
        end
    endgenerate
    
    // Position tracking
    assign relu1_row_out = bn1_row_out;
    assign relu1_col_out = bn1_col_out;
    
    // 4. Depthwise Convolution (3x3 separable conv) - 2 SPATIAL PIXELS
    genvar dw_i;
    generate
        for (dw_i = 0; dw_i < SPATIAL_PARALLEL; dw_i = dw_i + 1) begin : gen_dw_conv
            depthwise_conv #(
                .N(N),
                .Q(Q),
                .IN_WIDTH(FEATURE_SIZE),
                .IN_HEIGHT(FEATURE_SIZE),
                .CHANNELS(EXPAND_CHANNELS),
                .KERNEL_SIZE(KERNEL_SIZE),
                .STRIDE(STRIDE),
                .PADDING(PADDING),
                .PARALLELISM(CHANNEL_PARALLEL)
            ) dw_conv_inst (
                .clk(clk),
                .rst(rst),
                .en(module_enable),
                .data_in(relu1_data_out[dw_i*N +: N]),
                .channel_in(relu1_channel_out[dw_i*$clog2(EXPAND_CHANNELS) +: $clog2(EXPAND_CHANNELS)]),
                .valid_in(relu1_valid_out[dw_i]),
                .weights(dw_weights),
                .data_out(dw_data_out[dw_i*N +: N]),
                .channel_out(dw_channel_out[dw_i*$clog2(EXPAND_CHANNELS) +: $clog2(EXPAND_CHANNELS)]),
                .valid_out(dw_valid_out[dw_i]),
                .done()
            );
        end
    endgenerate
    
    // Position tracking for spatial parallelism
    assign dw_row_out = relu1_row_out;
    assign dw_col_out = relu1_col_out;
    
    // Combine done signals from all spatial depthwise conv units
    wire [SPATIAL_PARALLEL-1:0] dw_done_signals;
    genvar dw_done_i;
    generate
        for (dw_done_i = 0; dw_done_i < SPATIAL_PARALLEL; dw_done_i = dw_done_i + 1) begin : gen_dw_done
            assign dw_done_signals[dw_done_i] = gen_dw_conv[dw_done_i].dw_conv_inst.done;
        end
    endgenerate
    assign dw_done = &dw_done_signals | (state == DONE_STATE);
    
    // 5. BatchNorm 2 - 2 SPATIAL PIXELS
    genvar bn2_i;
    generate
        for (bn2_i = 0; bn2_i < SPATIAL_PARALLEL; bn2_i = bn2_i + 1) begin : gen_bn2
            batchnorm #(
                .WIDTH(N),
                .FRAC(Q),
                .CHANNELS(EXPAND_CHANNELS)
            ) bn2_inst (
                .clk(clk),
                .rst(rst),
                .en(module_enable),
                .x_in(dw_data_out[bn2_i*N +: N]),
                .channel_in(dw_channel_out[bn2_i*$clog2(EXPAND_CHANNELS) +: $clog2(EXPAND_CHANNELS)]),
                .valid_in(dw_valid_out[bn2_i]),
                .gamma_packed(bn2_gamma_packed),
                .beta_packed(bn2_beta_packed),
                .y_out(bn2_data_out[bn2_i*N +: N]),
                .channel_out(bn2_channel_out[bn2_i*$clog2(EXPAND_CHANNELS) +: $clog2(EXPAND_CHANNELS)]),
                .valid_out(bn2_valid_out[bn2_i])
            );
        end
    endgenerate
    
    // 6. ReLU 2 - 2 SPATIAL PIXELS
    genvar relu2_i;
    generate
        for (relu2_i = 0; relu2_i < SPATIAL_PARALLEL; relu2_i = relu2_i + 1) begin : gen_relu2
            Relu #(
                .N(N),
                .CHANNELS(EXPAND_CHANNELS)
            ) relu2_inst (
                .clk(clk),
                .rst(rst),
                .data_in(bn2_data_out[relu2_i*N +: N]),
                .channel_in(bn2_channel_out[relu2_i*$clog2(EXPAND_CHANNELS) +: $clog2(EXPAND_CHANNELS)]),
                .valid_in(bn2_valid_out[relu2_i]),
                .data_out(relu2_data_out[relu2_i*N +: N]),
                .channel_out(relu2_channel_out[relu2_i*$clog2(EXPAND_CHANNELS) +: $clog2(EXPAND_CHANNELS)]),
                .valid_out(relu2_valid_out[relu2_i])
            );
        end
    endgenerate
    
    // 7. Pointwise Convolution 2 (Projection: 64->16 channels) - 2 SPATIAL PIXELS
    genvar pw2_i;
    generate
        for (pw2_i = 0; pw2_i < SPATIAL_PARALLEL; pw2_i = pw2_i + 1) begin : gen_pw_conv2
            pointwise_conv #(
                .N(N),
                .Q(Q),
                .IN_CHANNELS(EXPAND_CHANNELS),
                .OUT_CHANNELS(OUT_CHANNELS),
                .FEATURE_SIZE(FEATURE_SIZE),
                .PARALLELISM(CHANNEL_PARALLEL)
            ) pw_conv2_inst (
                .clk(clk),
                .rst(rst),
                .en(module_enable),
                .data_in(relu2_data_out[pw2_i*N +: N]),
                .channel_in(relu2_channel_out[pw2_i*$clog2(EXPAND_CHANNELS) +: $clog2(EXPAND_CHANNELS)]),
                .valid_in(relu2_valid_out[pw2_i]),
                .weights(pw2_weights),
                .data_out(pw2_data_out[pw2_i*N +: N]),
                .channel_out(pw2_channel_out[pw2_i*$clog2(OUT_CHANNELS) +: $clog2(OUT_CHANNELS)]),
                .valid_out(pw2_valid_out[pw2_i]),
                .done()
            );
        end
    endgenerate
    
    // Combine done signals from all spatial pointwise conv2 units
    wire [SPATIAL_PARALLEL-1:0] pw2_done_signals;
    genvar pw2_done_i;
    generate
        for (pw2_done_i = 0; pw2_done_i < SPATIAL_PARALLEL; pw2_done_i = pw2_done_i + 1) begin : gen_pw2_done
            assign pw2_done_signals[pw2_done_i] = gen_pw_conv2[pw2_done_i].pw_conv2_inst.done;
        end
    endgenerate
    assign pw2_done = &pw2_done_signals | (state == DONE_STATE);
    
    // 8. BatchNorm 3 (Final Output Normalization) - 2 SPATIAL PIXELS
    genvar bn3_i;
    generate
        for (bn3_i = 0; bn3_i < SPATIAL_PARALLEL; bn3_i = bn3_i + 1) begin : gen_bn3
            batchnorm #(
                .WIDTH(N),
                .FRAC(Q),
                .CHANNELS(OUT_CHANNELS)
            ) bn3_inst (
                .clk(clk),
                .rst(rst),
                .en(module_enable),
                .x_in(pw2_data_out[bn3_i*N +: N]),
                .channel_in(pw2_channel_out[bn3_i*$clog2(OUT_CHANNELS) +: $clog2(OUT_CHANNELS)]),
                .valid_in(pw2_valid_out[bn3_i]),
                .gamma_packed(bn3_gamma_packed),
                .beta_packed(bn3_beta_packed),
                .y_out(bn3_data_out[bn3_i*N +: N]),
                .channel_out(bn3_channel_out[bn3_i*$clog2(OUT_CHANNELS) +: $clog2(OUT_CHANNELS)]),
                .valid_out(bn3_valid_out[bn3_i])
            );
        end
    endgenerate
    
    // Position tracking assignments for pipeline coordination
    assign bn2_row_out = dw_row_out;
    assign bn2_col_out = dw_col_out;
    assign relu2_row_out = bn2_row_out;
    assign relu2_col_out = bn2_col_out;
    assign pw2_row_out = relu2_row_out;
    assign pw2_col_out = relu2_col_out;
    assign bn3_row_out = pw2_row_out;
    assign bn3_col_out = pw2_col_out;
    
    // Final output assignments - 2 spatial pixels optimized
    assign data_out = bn3_data_out;
    assign channel_out = bn3_channel_out;
    assign valid_out = bn3_valid_out;
    
    // Enhanced done signal with proper state coordination
    assign done = (state == DONE_STATE) && pw1_done && dw_done && pw2_done;

endmodule 