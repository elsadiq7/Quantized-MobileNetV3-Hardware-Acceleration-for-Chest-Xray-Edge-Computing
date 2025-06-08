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
    
    // Computed batch statistics
    reg [WIDTH-1:0] mean [0:CHANNELS-1];     
    reg [WIDTH-1:0] variance [0:CHANNELS-1]; 
    
    // Channel signals for the processing pipeline
    wire [4:0] channel_reg1;       
    reg valid_reg1;                
    
    // Prevent uninitialized values in simulation for arrays only
    `ifndef SYNTHESIS
    initial begin
        for (int i = 0; i < CHANNELS; i++) begin
            mean[i] = 0;
            variance[i] = 0;
        end
        valid_reg1 = 0;
        // Removed channel_reg1 initialization as it's now a wire
    end
    `endif
    
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
    
    // Calculate mean and variance for each channel
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            for (int i = 0; i < CHANNELS; i++) begin
                mean[i] <= 0;
                variance[i] <= 0;
            end
            valid_reg1 <= 0;
        end else if (acc_valid) begin

            if (channel_reg1 < CHANNELS) begin
                mean[channel_reg1] <= sum_out / BATCH_SIZE;
                variance[channel_reg1] <= (sum_sq_out / BATCH_SIZE);
            end
            
            valid_reg1 <= 1;
        end else begin
            valid_reg1 <= 0;
        end
    end
    
    // Instantiate the normalizer to apply batch normalization
    batchnorm_normalizer #(
        .WIDTH(WIDTH),
        .FRAC(FRAC)
    ) normalizer (
        .clk(clk),
        .rst(rst),
        .enable(valid_in),
        .x_in(x_in),
        .mean(mean[channel_in < CHANNELS ? channel_in : 0]), 
        .variance(variance[channel_in < CHANNELS ? channel_in : 0]),  
        .gamma(gamma[channel_in < CHANNELS ? channel_in : 0]),  
        .beta(beta[channel_in < CHANNELS ? channel_in : 0]),
        .y_out(y_out),
        .valid_out(valid_out)
    );
    
    assign done = acc_done;

endmodule