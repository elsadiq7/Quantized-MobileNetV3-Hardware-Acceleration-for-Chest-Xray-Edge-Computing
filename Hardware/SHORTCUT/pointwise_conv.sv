module pointwise_conv #(
    parameter N = 16,           // Data width
    parameter Q = 8,            // Fractional bits
    parameter IN_CHANNELS = 24, // Input channels
    parameter OUT_CHANNELS = 24,// Output channels
    parameter FEATURE_SIZE = 28, // Feature map size
    parameter PARALLELISM = 4   // Process 4 channels in parallel
) (
    input wire clk,
    input wire rst,
    input wire en,

    // Input interface
    input wire [N-1:0] data_in,
    input wire [$clog2(IN_CHANNELS)-1:0] channel_in,
    input wire valid_in,

    // Weight interface - simplified
    input wire [(IN_CHANNELS*OUT_CHANNELS*N)-1:0] weights,

    // Output interface
    output reg [N-1:0] data_out,
    output reg [$clog2(OUT_CHANNELS)-1:0] channel_out,
    output reg valid_out,
    output reg done
);

    // Use block RAM for weight storage
    (* ram_style = "block" *) reg [N-1:0] weight_memory [0:IN_CHANNELS*OUT_CHANNELS-1];

    // State machine for generating all outputs per input
    typedef enum logic [1:0] {
        IDLE,
        PROCESSING,
        GENERATING_OUTPUTS,
        DONE_STATE
    } state_t;

    state_t state;

    // Counters and control signals
    reg [$clog2(OUT_CHANNELS)-1:0] out_ch_count;
    reg [$clog2(FEATURE_SIZE*FEATURE_SIZE)-1:0] pixel_count;
    reg [15:0] idle_cycles; // Counter for detecting end of input stream
    reg [$clog2(FEATURE_SIZE*FEATURE_SIZE*IN_CHANNELS)-1:0] total_input_count;

    // Input storage for current processing
    reg [N-1:0] current_input;
    reg [$clog2(IN_CHANNELS)-1:0] current_input_channel;
    reg input_ready;

    // DSP48-optimized MAC pipeline with proper timing
    reg signed [N-1:0] mult_a;
    reg signed [N-1:0] mult_b;
    wire signed [2*N-1:0] mult_result = mult_a * mult_b;
    reg signed [2*N-1:0] mult_reg;
    reg signed [2*N-1:0] mult_reg2; // Additional pipeline stage

    // Pipeline control signals
    reg valid_pipe1, valid_pipe2, valid_pipe3;
    reg [$clog2(OUT_CHANNELS)-1:0] channel_pipe1, channel_pipe2, channel_pipe3;

    // Quantization - operates on properly pipelined data
    wire signed [N-1:0] quantized_result;
    assign quantized_result = (^mult_reg2[2*N-1:N+Q] == 1'b0 || &mult_reg2[2*N-1:N+Q] == 1'b1) ?
                             mult_reg2[N+Q-1:Q] :
                             {mult_reg2[2*N-1], {N-1{~mult_reg2[2*N-1]}}};

    // Input validation
    wire [N-1:0] validated_data_in = (valid_in) ? data_in : {N{1'b0}};

    // Weight loading - moved to always block for proper synthesis
    reg weights_loaded;
    integer i;

    always @(posedge clk) begin
        if (rst) begin
            state <= IDLE;
            data_out <= 0;
            channel_out <= 0;
            valid_out <= 0;
            done <= 0;
            out_ch_count <= 0;
            pixel_count <= 0;
            mult_a <= 0;
            mult_b <= 0;
            mult_reg <= 0;
            mult_reg2 <= 0;
            valid_pipe1 <= 0;
            valid_pipe2 <= 0;
            valid_pipe3 <= 0;
            channel_pipe1 <= 0;
            channel_pipe2 <= 0;
            channel_pipe3 <= 0;
            weights_loaded <= 0;
            total_input_count <= 0;
            idle_cycles <= 0;
            current_input <= 0;
            current_input_channel <= 0;
            input_ready <= 0;
        end else begin
            // Load weights on first cycle after reset
            if (!weights_loaded) begin
                for (i = 0; i < IN_CHANNELS * OUT_CHANNELS; i = i + 1) begin
                    weight_memory[i] = weights[i*N +: N];
                end
                weights_loaded <= 1;
            end

            // Store input when received
            if (state == PROCESSING && valid_in) begin
                current_input <= validated_data_in;
                current_input_channel <= channel_in;
                input_ready <= 1;
                out_ch_count <= 0; // Start generating outputs from channel 0
                state <= GENERATING_OUTPUTS;
            end

            // Pipeline stage 1: Multiplication setup
            if (state == GENERATING_OUTPUTS && input_ready) begin
                mult_a <= $signed(current_input);
                mult_b <= $signed(weight_memory[current_input_channel * OUT_CHANNELS + out_ch_count]);
                valid_pipe1 <= 1;
                channel_pipe1 <= out_ch_count;
            end else begin
                valid_pipe1 <= 0;
            end

            // Pipeline stage 2: Register multiplication result
            mult_reg <= mult_result;
            valid_pipe2 <= valid_pipe1;
            channel_pipe2 <= channel_pipe1;

            // Pipeline stage 3: Register again for proper timing
            mult_reg2 <= mult_reg;
            valid_pipe3 <= valid_pipe2;
            channel_pipe3 <= channel_pipe2;

            // Pipeline stage 4: Output quantized result
            if (valid_pipe3) begin
                data_out <= quantized_result;
                channel_out <= channel_pipe3;
                valid_out <= 1;
            end else begin
                valid_out <= 0;
            end

            // State machine and counter logic
            case (state)
                IDLE: begin
                    done <= 0;
                    idle_cycles <= 0;
                    if (en && weights_loaded) begin
                        state <= PROCESSING;
                        out_ch_count <= 0;
                        pixel_count <= 0;
                        total_input_count <= 0;
                        input_ready <= 0;
                    end
                end

                PROCESSING: begin
                    if (!valid_in) begin
                        // Increment idle counter when no valid input
                        if (idle_cycles < 16'hFFFF) begin
                            idle_cycles <= idle_cycles + 1;
                        end

                        // Assert done if we've been idle for too long
                        if (idle_cycles >= 5 && total_input_count > 0) begin
                            done <= 1;
                            state <= DONE_STATE;
                        end
                    end else begin
                        idle_cycles <= 0;
                    end
                    // Input handling is done above in the input storage section
                end

                GENERATING_OUTPUTS: begin
                    // Generate outputs for all output channels for current input
                    if (out_ch_count == OUT_CHANNELS-1) begin
                        // Finished generating all outputs for this input
                        out_ch_count <= 0;
                        input_ready <= 0;
                        total_input_count <= total_input_count + 1;
                        pixel_count <= pixel_count + 1;
                        state <= PROCESSING;

                        // Check if we've processed enough inputs
                        if (pixel_count >= FEATURE_SIZE*FEATURE_SIZE-1) begin
                            done <= 1;
                            state <= DONE_STATE;
                        end
                    end else begin
                        out_ch_count <= out_ch_count + 1;
                    end
                end

                DONE_STATE: begin
                    done <= 1;
                    if (!en) begin
                        state <= IDLE;
                    end
                end
            endcase
        end
    end

endmodule