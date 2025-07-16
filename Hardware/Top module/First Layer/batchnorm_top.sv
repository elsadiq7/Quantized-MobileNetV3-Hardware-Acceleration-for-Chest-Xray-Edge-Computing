module batchnorm_top #(
    parameter WIDTH = 16,     
    parameter FRAC = 8,     
    parameter BATCH_SIZE = 10, 
    parameter CHANNELS = 16    
) (
    input wire clk,                   
    input wire rst,             
    input wire en,                      
    input wire [WIDTH-1:0] x_in,        
    input wire [4:0] channel_in,        
    input wire valid_in,                 
    input wire [WIDTH-1:0] gamma [0:CHANNELS-1],
    input wire [WIDTH-1:0] beta [0:CHANNELS-1],
    output wire [WIDTH-1:0] y_out,     
    output wire valid_out,               
    output wire done                    
);

    // Accumulator signals
    wire [WIDTH-1:0] sum_out;       
    wire [WIDTH-1:0] sum_sq_out;    
    wire acc_valid;                 
    wire acc_done;                
    
    // Computed batch statistics - optimized for block RAM inference
    (* ram_style = "block" *) reg [WIDTH-1:0] mean [0:CHANNELS-1];     
    (* ram_style = "block" *) reg [WIDTH-1:0] variance [0:CHANNELS-1]; 
    
    // Channel signals for the processing pipeline
    wire [4:0] channel_reg1;       
    reg valid_reg1;                
    
    // Bounds checking for synthesis safety
    wire [$clog2(CHANNELS)-1:0] safe_channel_in;
    wire [$clog2(CHANNELS)-1:0] safe_channel_reg1;
    
    assign safe_channel_in = (channel_in < CHANNELS) ? channel_in[$clog2(CHANNELS)-1:0] : 0;
    assign safe_channel_reg1 = (channel_reg1 < CHANNELS) ? channel_reg1[$clog2(CHANNELS)-1:0] : 0;
    
    // Initialize arrays for synthesis
    generate
        genvar i;
        for (i = 0; i < CHANNELS; i = i + 1) begin : init_arrays
            initial begin
                mean[i] = 0;
                variance[i] = 0;
            end
        end
    endgenerate
    
    // Instantiate accumulator to compute sums for batches
    batchnorm_accumulator #(
        .WIDTH(WIDTH),
        .BATCH_SIZE(BATCH_SIZE),
        .CHANNELS(CHANNELS)
    ) acc (
        .clk(clk),
        .rst(rst),
        .en(en),
        .x_in(x_in),
        .channel_in(channel_in),
        .valid_in(valid_in),
        .sum_out(sum_out),
        .sum_sq_out(sum_sq_out),
        .channel_out(channel_reg1),  
        .valid_out(acc_valid),
        .done(acc_done)
    );
    
    // Calculate mean and variance for each channel - optimized for timing
    always @(posedge clk) begin
        if (rst) begin
            // Reset using generate block for better synthesis
            valid_reg1 <= 1'b0;
        end else if (acc_valid) begin
            // Safe indexing with bounds checking
            if (channel_reg1 < CHANNELS) begin
                // Optimized division for power-of-2 batch sizes
                mean[safe_channel_reg1] <= sum_out >> $clog2(BATCH_SIZE);
                variance[safe_channel_reg1] <= sum_sq_out >> $clog2(BATCH_SIZE);
            end
            
            valid_reg1 <= 1'b1;
        end else begin
            valid_reg1 <= 1'b0;
        end
    end
    
    // Reset arrays using generate block for better synthesis
    generate
        for (i = 0; i < CHANNELS; i = i + 1) begin : reset_arrays
            always @(posedge clk) begin
                if (rst) begin
                    mean[i] <= 0;
                    variance[i] <= 0;
                end
            end
        end
    endgenerate
    
    // Instantiate the normalizer to apply batch normalization
    batchnorm_normalizer #(
        .WIDTH(WIDTH),
        .FRAC(FRAC)
    ) normalizer (
        .clk(clk),
        .rst(rst),
        .enable(valid_in),
        .x_in(x_in),
        .mean(mean[safe_channel_in]), 
        .variance(variance[safe_channel_in]),  
        .gamma(gamma[safe_channel_in]),  
        .beta(beta[safe_channel_in]),
        .y_out(y_out),
        .valid_out(valid_out)
    );
    
    assign done = acc_done;

endmodule