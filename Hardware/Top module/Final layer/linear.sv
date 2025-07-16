// SYNTHESIS FIX: Greatly reduced linear layer size for FPGA synthesis
module linear #(
    parameter WIDTH = 16,
    parameter FRAC = 8,
    parameter IN_FEATURES = 96,  // SYNTHESIS FIX: Reduced from 576 to 96
    parameter OUT_FEATURES = 32  // SYNTHESIS FIX: Reduced from 1280 to 32
) (
    input wire clk,
    input wire rst,
    input wire en,
    
    // SYNTHESIS FIX: Streaming interface instead of massive arrays
    input wire signed [WIDTH-1:0] data_in,
    input wire [$clog2(IN_FEATURES)-1:0] input_addr,
    input wire valid_in,
    
    // SYNTHESIS FIX: Weight loading interface
    input wire signed [WIDTH-1:0] weight_data,
    input wire [$clog2(OUT_FEATURES*IN_FEATURES)-1:0] weight_addr,
    input wire weight_load_en,
    
    input wire signed [WIDTH-1:0] bias_data,
    input wire [$clog2(OUT_FEATURES)-1:0] bias_addr,
    input wire bias_load_en,
    
    output reg signed [WIDTH-1:0] data_out,
    output reg [$clog2(OUT_FEATURES)-1:0] output_addr,
    output reg valid_out
);

    // SYNTHESIS FIX: Simplified state machine and processing
    typedef enum logic [1:0] { IDLE, LOAD_INPUT, PROCESSING, OUTPUT } state_t;
    state_t state;

    // SYNTHESIS FIX: Much smaller memory arrays for synthesis
    (* ram_style = "block" *) reg signed [WIDTH-1:0] input_buffer [0:IN_FEATURES-1];
    (* ram_style = "block" *) reg signed [WIDTH-1:0] weight_memory [0:OUT_FEATURES*IN_FEATURES-1];
    (* ram_style = "distributed" *) reg signed [WIDTH-1:0] bias_memory [0:OUT_FEATURES-1];
    
    reg signed [2*WIDTH+8:0] accum;
    reg [$clog2(IN_FEATURES):0] in_f_count;
    reg [$clog2(OUT_FEATURES):0] out_f_count;
    reg [$clog2(IN_FEATURES):0] input_count;
    reg weights_loaded, biases_loaded;

    localparam signed [WIDTH-1:0] MAX_VAL = (1 << (WIDTH-1)) - 1;
    localparam signed [WIDTH-1:0] MIN_VAL = -(1 << (WIDTH-1));

    // SYNTHESIS FIX: Weight and bias loading
    always @(posedge clk) begin
        if (rst) begin
            weights_loaded <= 0;
            biases_loaded <= 0;
        end else begin
            if (weight_load_en && weight_addr < OUT_FEATURES*IN_FEATURES) begin
                weight_memory[weight_addr] <= weight_data;
                if (weight_addr == OUT_FEATURES*IN_FEATURES - 1) begin
                    weights_loaded <= 1;
                end
            end
            
            if (bias_load_en && bias_addr < OUT_FEATURES) begin
                bias_memory[bias_addr] <= bias_data;
                if (bias_addr == OUT_FEATURES - 1) begin
                    biases_loaded <= 1;
                end
            end
        end
    end

    // SYNTHESIS FIX: Simplified main processing logic
    always @(posedge clk) begin
        if (rst) begin
            state <= IDLE;
            valid_out <= 1'b0;
            in_f_count <= 0;
            out_f_count <= 0;
            input_count <= 0;
            accum <= 0;
            data_out <= 0;
            output_addr <= 0;
        end else if (en && weights_loaded && biases_loaded) begin
            case (state)
                IDLE: begin
                    if (valid_in) begin
                        state <= LOAD_INPUT;
                        input_count <= 0;
                    end
                end
                
                LOAD_INPUT: begin
                    if (valid_in) begin
                        input_buffer[input_addr] <= data_in;
                        input_count <= input_count + 1;
                        if (input_count >= IN_FEATURES - 1) begin
                            state <= PROCESSING;
                            out_f_count <= 0;
                            in_f_count <= 0;
                            accum <= bias_memory[0] << FRAC;
                        end
                    end
                end
                
                PROCESSING: begin
                    // MAC operation
                    accum <= accum + (input_buffer[in_f_count] * weight_memory[out_f_count * IN_FEATURES + in_f_count]);

                    if (in_f_count == IN_FEATURES - 1) begin
                        // Finished one output feature
                        state <= OUTPUT;
                        in_f_count <= 0;
                    end else begin
                        in_f_count <= in_f_count + 1;
                    end
                end
                
                OUTPUT: begin
                    // Output saturated result
                    if (accum > (MAX_VAL << FRAC)) begin
                        data_out <= MAX_VAL;
                    end else if (accum < (MIN_VAL << FRAC)) begin
                        data_out <= MIN_VAL;
                    end else begin
                        data_out <= accum >>> FRAC;
                    end
                    
                    output_addr <= out_f_count;
                    valid_out <= 1'b1;
                    
                    if (out_f_count == OUT_FEATURES - 1) begin
                        state <= IDLE;
                        out_f_count <= 0;
                    end else begin
                        out_f_count <= out_f_count + 1;
                        accum <= bias_memory[out_f_count + 1] << FRAC;
                        state <= PROCESSING;
                    end
                end
            endcase
        end else begin
            valid_out <= 1'b0;
        end
    end

endmodule
