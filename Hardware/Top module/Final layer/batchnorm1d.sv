// Synthesis-friendly version of batchnorm1d
module batchnorm1d #(
    parameter WIDTH = 16,
    parameter FRAC = 8,
    parameter FEATURES = 1280
) (
    input wire clk,
    input wire rst,
    input wire en,
    
    input wire signed [WIDTH-1:0] data_in [0:FEATURES-1],
    input wire valid_in,
    
    input wire signed [WIDTH-1:0] gamma [0:FEATURES-1],
    input wire signed [WIDTH-1:0] beta [0:FEATURES-1],
    
    output reg signed [WIDTH-1:0] data_out [0:FEATURES-1],
    output reg valid_out
);

    typedef enum logic [1:0] { IDLE, PROCESSING, DONE } state_t;
    state_t state;

    reg [$clog2(FEATURES):0] feature_count;
    reg signed [WIDTH-1:0] data_in_buf [0:FEATURES-1];

    // Wires for intermediate calculations
    wire signed [2*WIDTH-1:0] mult_res = data_in_buf[feature_count] * gamma[feature_count];
    wire signed [WIDTH-1:0] scaled_res = mult_res >>> FRAC;

    always @(posedge clk) begin
        if (rst) begin
            valid_out <= 1'b0;
            feature_count <= 0;
            state <= IDLE;
            for(int j=0; j<FEATURES; j++) begin
                data_out[j] <= 0;
            end
        end else if (en) begin
            // State transitions
            case(state)
                IDLE:
                    if (valid_in) begin
                        state <= PROCESSING;
                    end
                PROCESSING:
                    if (feature_count == FEATURES - 1) begin
                        state <= DONE;
                    end
                DONE:
                    state <= IDLE;
                default:
                    state <= IDLE; // Safety default
            endcase

            // Latch inputs at the beginning of the operation
            if (valid_in && state == IDLE) begin
                data_in_buf <= data_in;
                feature_count <= 0;
            end

            // Sequential processing logic
            if (state == PROCESSING) begin
                data_out[feature_count] <= scaled_res + beta[feature_count];
                feature_count <= feature_count + 1;
            end

            // Handle output valid signal
            if (state == DONE) begin
                valid_out <= 1'b1;
            end else begin
                valid_out <= 1'b0;
            end
        end
    end

endmodule
