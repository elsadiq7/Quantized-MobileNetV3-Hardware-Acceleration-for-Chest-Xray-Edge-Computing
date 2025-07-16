module pointwise_conv_optimized_v2 #(
    parameter N = 16,           // Data width
    parameter Q = 8,            // Fractional bits
    parameter IN_CHANNELS = 40,  // Input channels
    parameter OUT_CHANNELS = 48, // Output channels
    parameter FEATURE_SIZE = 14, // Feature map size
    parameter PARALLELISM = 4    // Keep same parameter for compatibility (but use sequentially)
) (
    input wire clk,
    input wire rst,
    input wire en,
    
    // Input interface - identical to original
    input wire [N-1:0] data_in,
    input wire [$clog2(IN_CHANNELS)-1:0] channel_in,
    input wire valid_in,
    
    // Weight interface - identical to original
    input wire [(IN_CHANNELS*OUT_CHANNELS*N)-1:0] weights,
    
    // Output interface - identical to original
    output reg [N-1:0] data_out,
    output reg [$clog2(OUT_CHANNELS)-1:0] channel_out,
    output reg valid_out,
    output reg done
);

    // Block RAM for weight storage - same as original
    (* ram_style = "block" *) reg [N-1:0] weight_memory [0:IN_CHANNELS*OUT_CHANNELS-1];

    // State machine - identical to original
    typedef enum logic [1:0] {
        IDLE,
        PROCESSING,
        ACCUMULATING,
        DONE_STATE
    } state_t;

    state_t state, next_state;

    // Sequential processing parameters
    localparam PARALLEL_GROUPS = (OUT_CHANNELS + PARALLELISM - 1) / PARALLELISM;

    // Counters - similar to original but adapted for sequential processing
    reg [$clog2(PARALLEL_GROUPS)-1:0] group_count;
    reg [$clog2(IN_CHANNELS)-1:0] input_ch_count;
    reg [$clog2(FEATURE_SIZE*FEATURE_SIZE)-1:0] pixel_count;
    reg input_timeout;
    reg [3:0] timeout_counter;

    // Sequential processing pipeline - replaces parallel pipeline
    reg signed [N-1:0] stage1_data;
    reg [$clog2(IN_CHANNELS)-1:0] stage1_in_ch;
    reg [$clog2(PARALLEL_GROUPS)-1:0] stage1_group;
    reg stage1_valid;
    
    // Sequential processing state for cycling through output channels
    reg [1:0] seq_state;  // 0-3 for processing 4 channels sequentially
    reg [$clog2(OUT_CHANNELS)-1:0] current_out_ch;

    // Single multiplier - replaces 4 parallel multipliers (75% reduction)
    wire signed [2*N-1:0] mult_result;
    wire signed [N-1:0] quantized_result;
    reg signed [N-1:0] current_weight;

    // Single multiplier instantiation
    assign mult_result = stage1_data * current_weight;
    
    // Optimized saturation logic - identical to original but single instance
    assign quantized_result = (mult_result[2*N-1:N] == {(N){mult_result[N-1]}}) ?
                             mult_result[N+Q-1:Q] :
                             {mult_result[2*N-1], {(N-1){~mult_result[2*N-1]}}};

    // Accumulation buffers - reduced bit width from N+8 to N+4
    reg signed [N+4-1:0] accumulators [0:OUT_CHANNELS-1];
    reg accumulator_valid [0:OUT_CHANNELS-1];

    // Output management - identical to original
    reg [$clog2(OUT_CHANNELS)-1:0] output_ch_count;
    reg output_active;

    // Weight loading control - identical to original
    reg weights_loaded;
    integer i, j;

    // Input validation - identical to original
    wire [N-1:0] validated_data_in = (valid_in) ? data_in : {N{1'b0}};
    wire [$clog2(IN_CHANNELS)-1:0] validated_channel_in = (valid_in && channel_in < IN_CHANNELS) ? channel_in : {$clog2(IN_CHANNELS){1'b0}};
    
    // Main state machine with sequential processing
    always @(posedge clk) begin
        if (rst) begin
            state <= IDLE;
            data_out <= 0;
            channel_out <= 0;
            valid_out <= 0;
            done <= 0;
            group_count <= 0;
            input_ch_count <= 0;
            pixel_count <= 0;
            output_ch_count <= 0;
            weights_loaded <= 0;
            input_timeout <= 0;
            timeout_counter <= 0;
            output_active <= 0;
            seq_state <= 0;
            current_out_ch <= 0;

            // Reset pipeline stages
            stage1_data <= 0;
            stage1_in_ch <= 0;
            stage1_group <= 0;
            stage1_valid <= 0;
            current_weight <= 0;

            // Reset accumulators
            for (i = 0; i < OUT_CHANNELS; i = i + 1) begin
                accumulators[i] <= {(N+4){1'b0}};
                accumulator_valid[i] <= 1'b0;
            end
        end else begin
            state <= next_state;

            // Load weights on first enable - identical to original
            if (!weights_loaded && en) begin
                for (i = 0; i < IN_CHANNELS * OUT_CHANNELS; i = i + 1) begin
                    weight_memory[i] <= weights[i*N +: N];
                end
                weights_loaded <= 1'b1;
                $display("Loaded %0d weights for optimized pointwise convolution", IN_CHANNELS * OUT_CHANNELS);
            end

            // Input timeout detection - identical to original
            if (state == PROCESSING) begin
                if (valid_in) begin
                    timeout_counter <= 0;
                    input_timeout <= 0;
                end else begin
                    if (timeout_counter < 15) begin
                        timeout_counter <= timeout_counter + 1;
                    end else begin
                        input_timeout <= 1'b1;
                    end
                end
            end

            // Sequential processing pipeline - processes one output channel per cycle
            if (valid_in && weights_loaded && (state == PROCESSING)) begin
                // Calculate current output channel based on group and sequential state
                current_out_ch <= group_count * PARALLELISM + seq_state;
                
                // Pipeline Stage 1: Sequential weight fetch
                stage1_data <= $signed(validated_data_in);
                stage1_in_ch <= validated_channel_in;
                stage1_group <= group_count;
                stage1_valid <= 1'b1;

                // Load weight for current output channel
                if ((group_count * PARALLELISM + seq_state) < OUT_CHANNELS) begin
                    current_weight <= $signed(weight_memory[(group_count * PARALLELISM + seq_state) * IN_CHANNELS + validated_channel_in]);
                end else begin
                    current_weight <= {N{1'b0}};
                end

                // Advance sequential state
                if (seq_state == PARALLELISM-1) begin
                    seq_state <= 0;
                    input_ch_count <= input_ch_count + 1;
                    if (input_ch_count < 10) begin
                        $display("Sequential Input[%0d]: Data=0x%04x, InCh=%0d, Group=%0d",
                                 input_ch_count, validated_data_in, validated_channel_in, group_count);
                    end
                end else begin
                    seq_state <= seq_state + 1;
                end
            end else begin
                stage1_valid <= 1'b0;
            end

            // Pipeline Stage 2: Sequential accumulation
            if (stage1_valid) begin
                // Accumulate result for current output channel
                if (current_out_ch < OUT_CHANNELS) begin
                    accumulators[current_out_ch] <= accumulators[current_out_ch] + {{4{quantized_result[N-1]}}, quantized_result};
                    accumulator_valid[current_out_ch] <= 1'b1;
                end

                if (input_ch_count < 10) begin
                    $display("Sequential Accumulation: OutCh=%0d processed", current_out_ch);
                end
            end

            // Output generation - identical to original logic
            if (state == ACCUMULATING) begin
                if (output_ch_count < OUT_CHANNELS && accumulator_valid[output_ch_count]) begin
                    // Apply saturation and output - adapted for N+4 bit width
                    if (accumulators[output_ch_count][N+4-1:N-1] == {5{accumulators[output_ch_count][N-1]}}) begin
                        // No overflow
                        data_out <= accumulators[output_ch_count][N-1:0];
                    end else begin
                        // Saturate
                        data_out <= accumulators[output_ch_count][N+4-1] ?
                                   {1'b1, {(N-1){1'b0}}} : {1'b0, {(N-1){1'b1}}};
                    end

                    channel_out <= output_ch_count;
                    valid_out <= 1'b1;
                    output_active <= 1'b1;

                    $display("Sequential Output[%0d]: Data=0x%04x, Channel=%0d, Accumulator=0x%05x",
                             output_ch_count, data_out, output_ch_count, accumulators[output_ch_count]);

                    // Reset accumulator for next pixel
                    accumulators[output_ch_count] <= {(N+4){1'b0}};
                    accumulator_valid[output_ch_count] <= 1'b0;
                end else begin
                    valid_out <= 1'b0;
                    output_active <= 1'b0;
                end
            end else begin
                valid_out <= 1'b0;
                output_active <= 1'b0;
            end

            // Done signal generation - identical to original
            if (state == ACCUMULATING && next_state == DONE_STATE) begin
                done <= 1'b1;
                $display("Optimized pointwise convolution completed at time %0t", $time);
            end else if (state == IDLE && next_state == PROCESSING) begin
                done <= 1'b0;
            end
        end
    end

    // State transition logic - identical to original
    always @(*) begin
        next_state = state;
        case (state)
            IDLE: begin
                if (en && weights_loaded) begin
                    next_state = PROCESSING;
                end
            end

            PROCESSING: begin
                // Transition to accumulating when we have processed enough inputs
                // or when input timeout occurs
                if (input_timeout || (input_ch_count >= 49)) begin
                    next_state = ACCUMULATING;
                end
            end

            ACCUMULATING: begin
                // Stay in accumulating until all output channels are processed
                if (output_ch_count >= OUT_CHANNELS-1) begin
                    next_state = DONE_STATE;
                end
            end

            DONE_STATE: begin
                // Stay in done state
                next_state = DONE_STATE;
            end
        endcase
    end

    // Counter update logic - adapted for sequential processing
    always @(posedge clk) begin
        if (rst) begin
            // Counters reset in main always block
        end else begin
            case (state)
                PROCESSING: begin
                    // Cycle through parallel groups for each complete set of 4 sequential operations
                    if (valid_in && weights_loaded && seq_state == PARALLELISM-1) begin
                        if (group_count == PARALLEL_GROUPS-1) begin
                            group_count <= 0;
                            pixel_count <= pixel_count + 1;
                        end else begin
                            group_count <= group_count + 1;
                        end
                    end
                end

                ACCUMULATING: begin
                    // Cycle through output channels for output generation
                    if (accumulator_valid[output_ch_count]) begin
                        if (output_ch_count == OUT_CHANNELS-1) begin
                            output_ch_count <= 0;
                        end else begin
                            output_ch_count <= output_ch_count + 1;
                        end
                    end
                end

                IDLE: begin
                    group_count <= 0;
                    input_ch_count <= 0;
                    pixel_count <= 0;
                    output_ch_count <= 0;
                    seq_state <= 0;
                end
            endcase
        end
    end

endmodule
