module pointwise_conv #(
    parameter N = 16,           // Data width
    parameter Q = 8,            // Fractional bits
    parameter IN_CHANNELS = 96, // Input channels from the image
    parameter OUT_CHANNELS = 576, // Output channels from the image
    parameter FEATURE_SIZE = 7, // Feature map size from the image
    parameter WEIGHT_BUFFER_SIZE = 256  // Reduced buffer size for synthesis
) (
    input wire clk,
    input wire rst,
    input wire en,
    
    // Input interface
    input wire signed [N-1:0] data_in,
    input wire [$clog2(IN_CHANNELS)-1:0] channel_in,
    input wire valid_in,
    
    // External weight memory interface (instead of massive internal memory)
    output reg [$clog2(IN_CHANNELS*OUT_CHANNELS)-1:0] weight_addr,
    output reg weight_req,
    input wire signed [N-1:0] weight_data,
    input wire weight_valid,
    
    // Output interface
    output reg signed [N-1:0] data_out,
    output reg [$clog2(OUT_CHANNELS)-1:0] channel_out,
    output reg valid_out
);

    // State machine
    typedef enum logic [2:0] { 
        IDLE, 
        LOAD_WEIGHT, 
        PROCESSING, 
        OUTPUT,
        DONE
    } state_t;
    state_t state, next_state;

    // Small weight buffer for synthesis compatibility
    (* ram_style = "distributed" *) reg signed [N-1:0] weight_buffer [0:WEIGHT_BUFFER_SIZE-1];
    reg weights_ready;
    reg [$clog2(WEIGHT_BUFFER_SIZE)-1:0] weight_buffer_count;

    // Counters
    reg [$clog2(IN_CHANNELS)-1:0] in_ch_count;
    reg [$clog2(OUT_CHANNELS)-1:0] out_ch_count;
    reg [$clog2(FEATURE_SIZE*FEATURE_SIZE)-1:0] pixel_count;

    // Single accumulator for current output channel (reduced from array)
    reg signed [2*N + $clog2(IN_CHANNELS) - 1 : 0] accum;

    // Pipeline registers
    reg signed [N-1:0] data_in_reg;
    reg valid_in_reg;
    reg [$clog2(IN_CHANNELS)-1:0] channel_in_reg;

    // Saturation values
    localparam signed [N-1:0] MAX_VAL = (1 << (N-1)) - 1;
    localparam signed [N-1:0] MIN_VAL = -(1 << (N-1));

    // State transition logic
    always_comb begin
        next_state = state;
        case(state)
            IDLE: begin
                if (en && valid_in) begin
                    next_state = LOAD_WEIGHT;
                end
            end
            LOAD_WEIGHT: begin
                if (weight_valid && weight_buffer_count >= WEIGHT_BUFFER_SIZE-1) begin
                    next_state = PROCESSING;
                end
            end
            PROCESSING: begin
                if (in_ch_count == IN_CHANNELS - 1 && valid_in_reg) begin
                    next_state = OUTPUT;
                end
            end
            OUTPUT: begin
                if (out_ch_count == OUT_CHANNELS - 1) begin
                    if (pixel_count == FEATURE_SIZE*FEATURE_SIZE - 1) begin
                        next_state = DONE;
                    end else begin
                        next_state = PROCESSING;
                    end
                end
            end
            DONE: begin
                if (!en) begin
                    next_state = IDLE;
                end
            end
            default: begin
                next_state = IDLE;
            end
        endcase
    end

    // Weight loading logic
    always_ff @(posedge clk) begin
        if (rst) begin
            weights_ready <= 1'b0;
            weight_buffer_count <= 0;
            weight_req <= 1'b0;
            weight_addr <= 0;
        end else begin
            case (state)
                IDLE: begin
                    if (en && valid_in) begin
                        weight_req <= 1'b1;
                        weight_addr <= 0;
                        weight_buffer_count <= 0;
                        weights_ready <= 1'b0;
                    end
                end
                LOAD_WEIGHT: begin
                    if (weight_valid && weight_buffer_count < WEIGHT_BUFFER_SIZE) begin
                        weight_buffer[weight_buffer_count] <= weight_data;
                        weight_buffer_count <= weight_buffer_count + 1;
                        weight_addr <= weight_addr + 1;
                    end
                    if (weight_buffer_count >= WEIGHT_BUFFER_SIZE-1) begin
                        weights_ready <= 1'b1;
                        weight_req <= 1'b0;
                    end
                end
                default: begin
                    weight_req <= 1'b0;
                end
            endcase
        end
    end

    // Main processing logic
    always_ff @(posedge clk) begin
        if (rst) begin
            state <= IDLE;
            data_out <= 0;
            channel_out <= 0;
            valid_out <= 1'b0;
            in_ch_count <= 0;
            out_ch_count <= 0;
            pixel_count <= 0;
            data_in_reg <= 0;
            valid_in_reg <= 1'b0;
            channel_in_reg <= 0;
            accum <= 0;
        end else begin
            state <= next_state;
            valid_out <= 1'b0;  // Default to invalid

            // Register input data
            if (valid_in) begin
                data_in_reg <= data_in;
                channel_in_reg <= channel_in;
                valid_in_reg <= 1'b1;
            end else begin
                valid_in_reg <= 1'b0;
            end

            case(state)
                IDLE: begin
                    in_ch_count <= 0;
                    out_ch_count <= 0;
                    pixel_count <= 0;
                    accum <= 0;
                end
                
                LOAD_WEIGHT: begin
                    // Wait for weights to load
                end
                
                PROCESSING: begin
                    if (valid_in_reg && weights_ready) begin
                        // Use weight from buffer (simplified addressing)
                        if (weight_buffer_count > 0) begin
                            accum <= accum + (data_in_reg * weight_buffer[in_ch_count % WEIGHT_BUFFER_SIZE]);
                        end
                        in_ch_count <= in_ch_count + 1;
                        
                        if (in_ch_count == IN_CHANNELS - 1) begin
                            in_ch_count <= 0;
                        end
                    end
                end
                
                OUTPUT: begin
                    if (out_ch_count < OUT_CHANNELS) begin
                        // Saturation logic
                        if (accum > (MAX_VAL << Q)) begin
                            data_out <= MAX_VAL;
                        end else if (accum < (MIN_VAL << Q)) begin
                            data_out <= MIN_VAL;
                        end else begin
                            data_out <= accum >>> Q;
                        end

                        channel_out <= out_ch_count;
                        valid_out <= 1'b1;
                        out_ch_count <= out_ch_count + 1;
                        
                        if (out_ch_count == OUT_CHANNELS - 1) begin
                            out_ch_count <= 0;
                            pixel_count <= pixel_count + 1;
                            accum <= 0;
                        end
                    end
                end
                
                DONE: begin
                    valid_out <= 1'b0;
                end
                
                default: begin
                    valid_out <= 1'b0;
                end
            endcase
        end
    end

endmodule
