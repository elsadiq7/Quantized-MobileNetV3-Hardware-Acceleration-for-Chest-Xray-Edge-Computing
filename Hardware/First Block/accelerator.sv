module accelerator #(
    parameter N = 16,     // 16-bit precision (8 int, 8 frac)
    parameter Q = 8,      // Number of fractional bits
    parameter n = 224,    // Input image size (224x224)
    parameter k = 3,      // Convolution kernel size (3x3)
    parameter s = 2,      // Stride of the convolution (s×s)
    parameter p = 1,      // Padding (added parameter)
    parameter IN_CHANNELS = 1,       // Number of input channels
    parameter OUT_CHANNELS = 16          // Number of output channels
) (
    input wire clk,  // Clock signal
    input wire rst,  // Reset signal
    input wire en,   // Enable signal
    
    // Image data input interface
    input wire [15:0] pixel,

    // Output interface
    output reg [N-1:0] data_out,
    output reg valid_out,
    output reg done,
    output reg ready_for_data
);

    // Internal signals for connecting different processing stages
    wire [N-1:0] conv_out;  
    wire [4:0] channel_out; 
    wire conv_valid, conv_done;  
    
    // Signal for activation input to convolver
    reg [N-1:0] activation_in;
    
    // Create weights array
    wire [(k*k*IN_CHANNELS*OUT_CHANNELS*N)-1:0] weight;
    
    // Weights from memory - replace with memory interface for synthesis
    reg [N-1:0] weight_mem [0:k*k*IN_CHANNELS*OUT_CHANNELS-1];
    reg [N-1:0] bn_mem [0:2*OUT_CHANNELS-1]; 
    
    // For simulation only - use ROM/memory in synthesis
    `ifndef SYNTHESIS
    integer i;
    initial begin
        // Load convolution weights from memory file
        $readmemb("memory/conv1.mem", weight_mem);
        $display("Loaded convolution weights from memory file");
        
        // Load batch norm parameters from memory file
        $readmemb("memory/bn1.mem", bn_mem);
        $display("Loaded batch norm parameters from memory file");
    end
    `endif
    
    // Assign weights from memory to the weight array
    genvar w;
    generate
        for (w = 0; w < k*k*IN_CHANNELS*OUT_CHANNELS; w = w + 1) begin : weight_gen
            assign weight[w*N +: N] = weight_mem[w];
        end
    endgenerate
    
    // Connection to image handler
    assign activation_in = pixel;

    // Pipeline registers
    reg [N-1:0] conv_out_reg;  
    reg [4:0] channel_out_reg;
    reg conv_valid_reg;
    
    // DEBUG: Add a debug counter to track non-zero values
    reg [31:0] nonzero_count;

    // Batch normalization output signals
    wire [N-1:0] bn_out;
    wire bn_valid;
    
    // State machine
    reg [1:0] state;
    localparam  IDLE = 2'b00,
                CONV = 2'b01,
                FINISH = 2'b11;
                
    // Counter for tracking outputs processed
    reg [31:0] output_counter;
    
    // Expected number of outputs for the layer
    localparam FEATURE_SIZE = n/s;
    localparam expected_outputs = FEATURE_SIZE*FEATURE_SIZE*OUT_CHANNELS;
    
    // Pipeline register logic and debug
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            conv_out_reg <= 0;
            channel_out_reg <= 0;
            conv_valid_reg <= 0;
            output_counter <= 0;
            nonzero_count <= 0;
        end else begin
            conv_out_reg <= conv_out;          
            channel_out_reg <= channel_out;    
            conv_valid_reg <= conv_valid;
            
            // Count valid outputs
            if (valid_out) begin
                output_counter <= output_counter + 1;
                
                // Track diverse outputs
                if (data_out != 0) begin
                    nonzero_count <= nonzero_count + 1;
                end
            end
            
            // Reset counter when entering IDLE state
            if (state == IDLE && en) begin
                output_counter <= 0;
            end
        end
    end
    
    // Control state machine
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= IDLE;
            done <= 0;
        end else begin
            case (state)
                IDLE: begin
                    if (en) state <= CONV;
                    done <= 0;
                end
                CONV: begin
                    if (conv_done && (output_counter >= expected_outputs || !bn_valid)) begin
                        state <= FINISH;
                    end
                end
                FINISH: begin
                    state <= IDLE;
                    done <= 1;
                end
                default: state <= IDLE;
            endcase
        end
    end

    // Instantiate the convolver
    convolver #(
        .N(N),
        .Q(Q),
        .n(n),
        .k(k),
        .s(s),
        .p(p),
        .IN_CHANNELS(IN_CHANNELS),
        .OUT_CHANNELS(OUT_CHANNELS),
        .NUM_MAC(4)
    ) convolver_inst (
        .clk(clk),
        .rst(rst),
        .en(state == CONV),
        .activation_in(activation_in),
        .weight(weight),
        .conv_out(conv_out),
        .channel_out(channel_out),
        .valid_out(conv_valid),
        .done(conv_done)
    );

    // Declare parameter arrays for batch normalization
    wire [N-1:0] gamma_array [0:OUT_CHANNELS-1];
    wire [N-1:0] beta_array [0:OUT_CHANNELS-1];
    
    // Load the weights from memory
    genvar j;
    generate
        for (j = 0; j < OUT_CHANNELS; j = j + 1) begin : bn_params
            // First half of bn_mem contains gamma values, second half contains beta values
            assign gamma_array[j] = bn_mem[j];
            assign beta_array[j] = bn_mem[j + OUT_CHANNELS];
        end
    endgenerate
    
    // Instantiate batch normalization
    batchnorm_top #(
        .WIDTH(N),
        .FRAC(Q),
        .BATCH_SIZE(10),
        .CHANNELS(OUT_CHANNELS)  // Use the OUT_CHANNELS parameter for consistency
    ) bn (
        .clk(clk),
        .rst(rst),
        .en(state == CONV),
        .x_in(conv_out_reg),
        .channel_in(channel_out_reg),
        .valid_in(conv_valid_reg),
        .gamma(gamma_array),
        .beta(beta_array),
        .y_out(bn_out),
        .valid_out(bn_valid),
        .done()
    );

    // Apply h-swish activation function
    wire [N-1:0] act_out;
    HSwish #(.dataWidth(N)) hswish_inst (
        .x(bn_out),
        .y(act_out)
    );
    
    // Output control logic
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            data_out <= 0;
            valid_out <= 0;
            ready_for_data <= 1;
        end else begin
            valid_out <= bn_valid && state == CONV;
            
            if (bn_valid) begin
                data_out <= act_out;
            end
            
            // Signal that we're ready for more input data
            ready_for_data <= (state == IDLE) || (state == CONV && !conv_done);
        end
    end

endmodule
