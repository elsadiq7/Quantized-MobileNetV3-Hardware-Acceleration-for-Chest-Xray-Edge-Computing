module pointwise_conv_optimized #(
    parameter N = 16,           // Data width
    parameter Q = 8,            // Fractional bits
    parameter IN_CHANNELS = 40,  // Input channels
    parameter OUT_CHANNELS = 48, // Output channels
    parameter FEATURE_SIZE = 14, // Feature map size
    parameter PARALLELISM = 1    // Reduced to 1 for LUT optimization
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

    // Optimized weight storage using BRAM
    (* ram_style = "block" *) reg [N-1:0] weight_memory [0:IN_CHANNELS*OUT_CHANNELS-1];

    // Simplified state machine
    typedef enum logic [1:0] {
        IDLE,
        PROCESSING,
        ACCUMULATING,
        DONE_STATE
    } state_t;

    state_t state, next_state;

    // Reduced counters and control signals
    reg [$clog2(OUT_CHANNELS)-1:0] current_out_ch;
    reg [$clog2(IN_CHANNELS)-1:0] input_ch_count;
    reg [$clog2(FEATURE_SIZE*FEATURE_SIZE)-1:0] pixel_count;
    reg input_timeout;
    reg [3:0] timeout_counter;

    // Single multiplier instead of parallel array
    reg signed [N-1:0] mult_data;
    reg signed [N-1:0] mult_weight;
    wire signed [2*N-1:0] mult_result;
    wire signed [N-1:0] quantized_result;

    // Single multiplier instantiation
    assign mult_result = mult_data * mult_weight;
    
    // Simplified saturation logic
    assign quantized_result = (mult_result[2*N-1:N-1] == {(N+1){mult_result[N-1]}}) ?
                             mult_result[N+Q-1:Q] :
                             {mult_result[2*N-1], {(N-1){~mult_result[2*N-1]}}};

    // Accumulator array for all output channels (but smaller bit width)
    reg signed [N+4-1:0] accumulators [0:OUT_CHANNELS-1];  // Reduced from N+8 to N+4
    reg accumulator_valid [0:OUT_CHANNELS-1];

    // Output management
    reg [$clog2(OUT_CHANNELS)-1:0] output_ch_count;
    reg output_active;

    // Weight loading control
    reg weights_loaded;
    integer i;

    // Input validation (simplified)
    wire [N-1:0] validated_data_in = valid_in ? data_in : {N{1'b0}};
    wire [$clog2(IN_CHANNELS)-1:0] validated_channel_in = (valid_in && channel_in < IN_CHANNELS) ? channel_in : {$clog2(IN_CHANNELS){1'b0}};
    
    // Main state machine with optimized processing
    always @(posedge clk) begin
        if (rst) begin
            state <= IDLE;
            data_out <= 0;
            channel_out <= 0;
            valid_out <= 0;
            done <= 0;
            current_out_ch <= 0;
            input_ch_count <= 0;
            pixel_count <= 0;
            output_ch_count <= 0;
            weights_loaded <= 0;
            input_timeout <= 0;
            timeout_counter <= 0;
            output_active <= 0;
            // Reset accumulators
            for (i = 0; i < OUT_CHANNELS; i = i + 1) begin
                accumulators[i] <= {(N+4){1'b0}};
                accumulator_valid[i] <= 1'b0;
            end
            mult_data <= 0;
            mult_weight <= 0;
        end else begin
            state <= next_state;

            // Load weights on first enable
            if (!weights_loaded && en) begin
                for (i = 0; i < IN_CHANNELS * OUT_CHANNELS; i = i + 1) begin
                    weight_memory[i] <= weights[i*N +: N];
                end
                weights_loaded <= 1'b1;
                $display("Loaded %0d weights for optimized pointwise convolution", IN_CHANNELS * OUT_CHANNELS);
            end

            // Input timeout detection
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

            // Sequential processing instead of parallel
            if (valid_in && weights_loaded && (state == PROCESSING)) begin
                mult_data <= $signed(validated_data_in);
                mult_weight <= $signed(weight_memory[current_out_ch * IN_CHANNELS + validated_channel_in]);
                
                input_ch_count <= input_ch_count + 1;
                if (input_ch_count < 10) begin
                    $display("Sequential Input[%0d]: Data=0x%04x, InCh=%0d, OutCh=%0d",
                             input_ch_count, validated_data_in, validated_channel_in, current_out_ch);
                end
            end

            // Accumulation (one cycle after multiplication)
            if (state == PROCESSING && $past(valid_in) && weights_loaded) begin
                accumulators[$past(current_out_ch)] <= accumulators[$past(current_out_ch)] + {{4{quantized_result[N-1]}}, quantized_result};
                accumulator_valid[$past(current_out_ch)] <= 1'b1;

                if (input_ch_count < 10) begin
                    $display("Sequential Accumulation: OutCh=%0d, Result=0x%04x",
                             $past(current_out_ch), quantized_result);
                end
            end

            // Output generation in ACCUMULATING state
            if (state == ACCUMULATING) begin
                if (output_ch_count < OUT_CHANNELS && accumulator_valid[output_ch_count]) begin
                    // Apply saturation and output
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

            // Done signal generation
            if (state == ACCUMULATING && next_state == DONE_STATE) begin
                done <= 1'b1;
                $display("Optimized pointwise convolution completed at time %0t", $time);
            end else if (state == IDLE && next_state == PROCESSING) begin
                done <= 1'b0;
            end
        end
    end

    // State transition logic
    always @(*) begin
        next_state = state;
        case (state)
            IDLE: begin
                if (en && weights_loaded) begin
                    next_state = PROCESSING;
                end
            end

            PROCESSING: begin
                // Transition when we have processed enough inputs or timeout
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

    // Counter update logic
    always @(posedge clk) begin
        if (rst) begin
            // Counters reset in main always block
        end else begin
            case (state)
                PROCESSING: begin
                    // Cycle through output channels for each input
                    if (valid_in && weights_loaded) begin
                        if (current_out_ch == OUT_CHANNELS-1) begin
                            current_out_ch <= 0;
                            pixel_count <= pixel_count + 1;
                        end else begin
                            current_out_ch <= current_out_ch + 1;
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
                    current_out_ch <= 0;
                    input_ch_count <= 0;
                    pixel_count <= 0;
                    output_ch_count <= 0;
                end
            endcase
        end
    end

endmodule
