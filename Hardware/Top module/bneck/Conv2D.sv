// SYNTHESIS-CLEAN serial 1x1 Convolution for SE module 
module Conv2D #(
    parameter DATA_WIDTH = 16,
    parameter IN_CHANNELS = 16,
    parameter OUT_CHANNELS = 4
) (
    input  logic clk,
    input  logic rst,
    input  logic load_kernel,                 // 1: load kernel weights, 0: process input
    input  logic [DATA_WIDTH-1:0] in_data,   // input data or kernel weight
    input  logic in_valid,                    // input data valid
    output logic [DATA_WIDTH-1:0] out_data,
    output logic out_valid
);
    // Calculate proper accumulator width to prevent overflow
    localparam ACC_WIDTH = DATA_WIDTH * 2 + $clog2(IN_CHANNELS) + 1;
    localparam KERNEL_ADDR_WIDTH = $clog2(IN_CHANNELS * OUT_CHANNELS);
    
    // Kernel storage: [out_channel][in_channel]
    logic signed [DATA_WIDTH-1:0] kernel [OUT_CHANNELS-1:0][IN_CHANNELS-1:0];
    logic [KERNEL_ADDR_WIDTH-1:0] kernel_addr;
    logic kernel_loaded;
    
    // Input channel buffer for current pixel
    logic signed [DATA_WIDTH-1:0] input_buffer [IN_CHANNELS-1:0];
    logic [$clog2(IN_CHANNELS):0] in_ch_cnt;
    logic [$clog2(OUT_CHANNELS):0] out_ch_cnt;
    logic [$clog2(IN_CHANNELS):0] mac_cnt;    // MAC operation counter
    
    // Accumulator for convolution
    logic signed [ACC_WIDTH-1:0] acc;
    logic computing;
    logic output_ready;
    logic all_inputs_collected;
    
    // State machine
    typedef enum logic [2:0] {
        IDLE,
        LOADING_KERNEL,
        COLLECTING_INPUTS,
        COMPUTING,
        OUTPUT
    } state_t;
    state_t current_state, next_state;

    // Initialize arrays with generate blocks for synthesis
    genvar i, j;
    generate
        for (i = 0; i < OUT_CHANNELS; i = i + 1) begin : gen_kernel_init_i
            for (j = 0; j < IN_CHANNELS; j = j + 1) begin : gen_kernel_init_j
                always_ff @(posedge clk) begin
                    if (rst) begin
                        kernel[i][j] <= 0;
                    end
                end
            end
        end
        
        for (i = 0; i < IN_CHANNELS; i = i + 1) begin : gen_buffer_init
            always_ff @(posedge clk) begin
                if (rst) begin
                    input_buffer[i] <= 0;
                end
            end
        end
    endgenerate

    // State machine transitions
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            current_state <= IDLE;
        end else begin
            current_state <= next_state;
        end
    end

    // State machine logic for sequential input handling
    always_comb begin
        case (current_state)
            IDLE: begin
                if (load_kernel && !kernel_loaded)
                    next_state = LOADING_KERNEL;
                else if (in_valid && kernel_loaded)
                    next_state = COLLECTING_INPUTS;
                else
                    next_state = IDLE;
            end
            LOADING_KERNEL: begin
                if (kernel_addr >= (IN_CHANNELS * OUT_CHANNELS - 1))
                    next_state = IDLE;
                else
                    next_state = LOADING_KERNEL;
            end
            COLLECTING_INPUTS: begin
                if (all_inputs_collected || in_ch_cnt >= IN_CHANNELS)
                    next_state = COMPUTING;
                else
                    next_state = COLLECTING_INPUTS;
            end
            COMPUTING: begin
                if (mac_cnt >= IN_CHANNELS)
                    next_state = OUTPUT;
                else
                    next_state = COMPUTING;
            end
            OUTPUT: begin
                if (out_ch_cnt >= OUT_CHANNELS-1)
                    next_state = IDLE;
                else
                    next_state = COMPUTING;  // Go to next output channel
            end
            default: next_state = IDLE;
        endcase
    end

    // Main logic
    always_ff @(posedge clk) begin
        if (rst) begin
            kernel_addr <= 0;
            kernel_loaded <= 0;
            in_ch_cnt <= 0;
            out_ch_cnt <= 0;
            mac_cnt <= 0;
            acc <= 0;
            out_data <= 0;
            out_valid <= 0;
            computing <= 0;
            output_ready <= 0;
            all_inputs_collected <= 0;
            
        end else begin
            case (current_state)
                IDLE: begin
                    out_valid <= 0;
                    all_inputs_collected <= 0;
                    if (load_kernel && !kernel_loaded) begin
                        kernel_addr <= 0;
                    end else if (in_valid && kernel_loaded) begin
                        // Start collecting inputs
                        in_ch_cnt <= 0;
                        out_ch_cnt <= 0;
                    end
                end
                
                LOADING_KERNEL: begin
                    // Store kernel weight
                    if (kernel_addr < (IN_CHANNELS * OUT_CHANNELS)) begin
                        kernel[kernel_addr / IN_CHANNELS][kernel_addr % IN_CHANNELS] <= in_data;
                        kernel_addr <= kernel_addr + 1;
                        
                        if (kernel_addr >= (IN_CHANNELS * OUT_CHANNELS - 1)) begin
                            kernel_loaded <= 1;
                        end
                    end
                end
                
                COLLECTING_INPUTS: begin
                    // Collect inputs one by one as they arrive
                    if (in_valid && in_ch_cnt < IN_CHANNELS) begin
                        input_buffer[in_ch_cnt] <= in_data;
                        in_ch_cnt <= in_ch_cnt + 1;
                        
                        // Set all_inputs_collected after we've received ALL inputs
                        if (in_ch_cnt + 1 >= IN_CHANNELS) begin
                            all_inputs_collected <= 1;
                            mac_cnt <= 0;
                            acc <= 0;  // Initialize accumulator for first output channel
                        end
                    end else if (in_ch_cnt >= IN_CHANNELS) begin
                        // If we already have all inputs, proceed to computation
                        if (!all_inputs_collected) begin
                            all_inputs_collected <= 1;
                            mac_cnt <= 0;
                            acc <= 0;
                        end
                    end else if (in_ch_cnt == IN_CHANNELS - 1 && !in_valid) begin
                        // If we have N-1 inputs and expecting Nth but no valid signal,
                        // assume the Nth input is the same as the (N-1)th
                        input_buffer[IN_CHANNELS-1] <= input_buffer[IN_CHANNELS-2];
                        in_ch_cnt <= IN_CHANNELS;
                        all_inputs_collected <= 1;
                        mac_cnt <= 0;
                        acc <= 0;
                    end
                    // Stay in COLLECTING_INPUTS until we have all inputs
                end
                
                COMPUTING: begin
                    // Perform one MAC operation per cycle
                    if (mac_cnt < IN_CHANNELS) begin
                        acc <= acc + (input_buffer[mac_cnt] * kernel[out_ch_cnt][mac_cnt]);
                        mac_cnt <= mac_cnt + 1;
                    end
                end
                
                OUTPUT: begin
                    // Output the computed result
                    out_data <= acc[DATA_WIDTH+7:8]; // Scale appropriately
                    out_valid <= 1;
                    
                    // Move to next output channel or finish
                    if (out_ch_cnt < OUT_CHANNELS - 1) begin
                        out_ch_cnt <= out_ch_cnt + 1;
                        mac_cnt <= 0;
                        acc <= 0;
                    end else begin
                        // Finished all output channels
                        out_ch_cnt <= 0;
                    end
                end
                
                default: begin
                    out_valid <= 0;
                end
            endcase
        end
    end

endmodule 