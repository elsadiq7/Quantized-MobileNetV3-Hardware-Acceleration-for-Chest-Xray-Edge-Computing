// Image handler module to load image data from memory
module image_handler_send (
    input wire clk,
    input wire rst,
    input wire req,
    input wire [15:0] addr,
    output reg [15:0] pixel,
    output reg valid
);
    // Parameters
    localparam IMAGE_SIZE = 224*224; // Exact image size (224x224)
    
    // Memory array for the image - separate this into a ROM for synthesis
    reg [15:0] image_mem [0:IMAGE_SIZE-1]; 
    
    // Track requests
    reg [31:0] request_count;
    
    // For simulation only - in real implementation, this would be a ROM
    `ifndef SYNTHESIS
    // Variables for initialization
    integer i;
    integer idx;
    integer nonzero_count;
    reg image_loaded;
    
    initial begin
        // Initialize memory with zeros
        for (i = 0; i < IMAGE_SIZE; i++)
            image_mem[i] = 16'h0000;
            
        // Load image data from file
        $readmemb("memory/test_image.mem", image_mem);
        
        // Check if image loaded successfully
        image_loaded = 1;
        
        // Count non-zero pixels
        nonzero_count = 0;
        for (i = 0; i < IMAGE_SIZE; i++) begin
            if (image_mem[i] != 16'h0000) begin
                nonzero_count = nonzero_count + 1;
                
                // Print first 10 non-zero values
                if (nonzero_count <= 10) begin
                    $display("Image has non-zero pixel at addr=%0d, value=%h", i, image_mem[i]);
                end
            end
        end
        
        $display("Loaded image data with %0d non-zero pixels out of %0d total", nonzero_count, IMAGE_SIZE);
        
        // Basic verification - check random positions
        $display("Image verification - sampling values:");
        for (i = 0; i < 5; i++) begin
            idx = $urandom_range(0, IMAGE_SIZE-1);
            $display("  Sample pixel[%0d] = %h", idx, image_mem[idx]);
        end
    end
    `endif
    
    // Logic to read data from memory based on address
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            pixel <= 16'h0000;
            valid <= 1'b0;
            request_count <= 0;
        end else begin
            if (req) begin
                request_count <= request_count + 1;
                
                // Check if address is within bounds
                if (addr < IMAGE_SIZE) begin
                    pixel <= image_mem[addr];
                    valid <= 1'b1;
                end else begin
                    // Address out of bounds - output zeros
                    pixel <= 16'h0000;
                    valid <= 1'b0;
                end
            end else begin
                valid <= 1'b0;
            end
        end
    end
endmodule 