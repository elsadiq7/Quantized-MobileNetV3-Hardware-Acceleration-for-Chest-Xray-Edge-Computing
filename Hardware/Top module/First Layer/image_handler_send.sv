// Image handler module to load image data from memory - Simplified for simulation
module image_handler_send (
    input wire clk,
    input wire rst,
    output reg [15:0] pixel,
    output reg valid
);
    // Parameters
    localparam IMAGE_SIZE = 224*224; // Exact image size (224x224)
    
    // Memory array for the image
    reg [15:0] image_mem [0:IMAGE_SIZE-1]; 
    
    // Address counter for sequential access
    reg [17:0] addr_count;
    reg data_loaded;
    
    // Load image data at simulation start
    initial begin
        // Try to load test image, if fails, create simple test pattern
        if ($fopen("memory/test_image.mem", "r") != 0) begin
            $readmemb("memory/test_image.mem", image_mem);
        end else begin
            // Create simple test pattern if file doesn't exist
            for (integer i = 0; i < IMAGE_SIZE; i = i + 1) begin
                image_mem[i] = 16'h1000 + (i[7:0]); // Simple pattern
            end
        end
        data_loaded = 1'b1;
        
        // Check if image is all zeros and create test pattern if so
        if (image_mem[0] == 16'h0000 && image_mem[100] == 16'h0000 && image_mem[1000] == 16'h0000) begin
            $display("Warning: Test image appears to be all zeros, creating simple test pattern...");
            for (integer i = 0; i < IMAGE_SIZE; i = i + 1) begin
                image_mem[i] = 16'h1000 + (i[7:0]); // Simple gradient pattern
            end
        end
    end
    
    // Sequential pixel output logic
    always @(posedge clk) begin
        if (rst) begin
            pixel <= 16'h0000;
            valid <= 1'b0;
            addr_count <= 0;
        end else if (data_loaded) begin
            // Always output current pixel
            if (addr_count < IMAGE_SIZE) begin
                pixel <= image_mem[addr_count];
                valid <= 1'b1;
                addr_count <= addr_count + 1'b1;
            end else begin
                // Keep outputting last pixel but mark invalid
                pixel <= 16'h0000;
                valid <= 1'b0;
            end
        end else begin
            pixel <= 16'h0000;
            valid <= 1'b0;
        end
    end
    
endmodule 