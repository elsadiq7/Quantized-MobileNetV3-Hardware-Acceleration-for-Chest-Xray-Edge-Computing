module dsp_resource_manager #(
    parameter WIDTH = 16,
    parameter FRAC = 8,
    parameter NUM_DSP48 = 16,  // SYNTHESIS FIX: Reduced to 16 physical DSP48s
    parameter NUM_VIRTUAL_MACS = 32  // SYNTHESIS FIX: Only 32 virtual MACs
)(
    input wire clk,
    input wire rst,
    input wire en,
    
    // SYNTHESIS FIX: Simplified MAC interface - no massive arrays
    input wire [WIDTH-1:0] mac_a,
    input wire [WIDTH-1:0] mac_b,  
    input wire [WIDTH-1:0] mac_c,
    input wire mac_req,
    input wire [1:0] mac_mode,
    input wire [$clog2(NUM_VIRTUAL_MACS)-1:0] mac_id,
    
    // MAC result interface - simplified
    output reg [WIDTH*2-1:0] mac_result,
    output reg mac_valid,
    output reg mac_ready,
    output reg [$clog2(NUM_VIRTUAL_MACS)-1:0] result_id,
    
    // Resource utilization monitoring
    output reg [$clog2(NUM_DSP48+1)-1:0] dsp48_usage_count,
    output reg [7:0] utilization_percent
);

    // SYNTHESIS FIX: Simplified DSP48 instances
    reg [WIDTH-1:0] dsp_a [0:NUM_DSP48-1];
    reg [WIDTH-1:0] dsp_b [0:NUM_DSP48-1];
    reg [WIDTH*2-1:0] dsp_c [0:NUM_DSP48-1];
    wire [WIDTH*2-1:0] dsp_p [0:NUM_DSP48-1];
    wire dsp_valid [0:NUM_DSP48-1];
    reg dsp_en [0:NUM_DSP48-1];
    
    // SYNTHESIS FIX: Simplified resource allocation
    reg [$clog2(NUM_DSP48)-1:0] current_dsp_id;
    reg [$clog2(NUM_VIRTUAL_MACS)-1:0] current_mac_id;
    reg processing_request;
    reg [2:0] processing_stage;
    
    // SYNTHESIS FIX: Simple round-robin scheduler
    reg [$clog2(NUM_DSP48)-1:0] dsp_pointer;
    
    // SYNTHESIS FIX: Simplified DSP48 instances with basic pipeline
    genvar i;
    generate
        for (i = 0; i < NUM_DSP48; i = i + 1) begin : dsp48_inst
            // Simple 2-stage pipelined DSP48 for timing closure
            dsp48_simple #(
                .WIDTH(WIDTH)
            ) dsp48_mac (
                .clk(clk),
                .rst(rst),
                .en(dsp_en[i]),
                .a(dsp_a[i]),
                .b(dsp_b[i]),
                .c(dsp_c[i]),
                .p(dsp_p[i]),
                .valid(dsp_valid[i])
            );
        end
    endgenerate
    
    // SYNTHESIS FIX: Simplified resource allocation and scheduling logic
    always @(posedge clk) begin
        if (rst) begin
            // Reset all DSP48 instances
            for (int i = 0; i < NUM_DSP48; i++) begin
                dsp_a[i] <= 0;
                dsp_b[i] <= 0;
                dsp_c[i] <= 0;
                dsp_en[i] <= 0;
            end
            
            current_dsp_id <= 0;
            current_mac_id <= 0;
            processing_request <= 0;
            processing_stage <= 0;
            dsp_pointer <= 0;
            dsp48_usage_count <= 0;
            utilization_percent <= 0;
            
            mac_result <= 0;
            mac_valid <= 0;
            mac_ready <= 1;
            result_id <= 0;
            
        end else if (en) begin
            
            // Simple request handling
            if (mac_req && mac_ready && !processing_request) begin
                // Find next available DSP48
                current_dsp_id <= dsp_pointer;
                current_mac_id <= mac_id;
                
                // Set up the DSP48 inputs
                dsp_a[dsp_pointer] <= mac_a;
                dsp_b[dsp_pointer] <= mac_b;
                dsp_c[dsp_pointer] <= {{(WIDTH){1'b0}}, mac_c};
                dsp_en[dsp_pointer] <= 1;
                
                processing_request <= 1;
                processing_stage <= 0;
                mac_ready <= 0;
                
                // Round-robin to next DSP48
                dsp_pointer <= (dsp_pointer + 1) % NUM_DSP48;
            end
            
            // Handle processing stages
            if (processing_request) begin
                processing_stage <= processing_stage + 1;
                
                // Check for completion (after DSP48 pipeline delay)
                if (processing_stage >= 3 && dsp_valid[current_dsp_id]) begin
                    // Forward result
                    mac_result <= dsp_p[current_dsp_id];
                    mac_valid <= 1;
                    result_id <= current_mac_id;
                    
                    // Free the resource
                    dsp_en[current_dsp_id] <= 0;
                    processing_request <= 0;
                    processing_stage <= 0;
                    mac_ready <= 1;
                end
            end else if (mac_valid) begin
                // Clear valid signal after one cycle
                mac_valid <= 0;
            end
            
            // Update utilization statistics
            dsp48_usage_count <= 0;
            for (int i = 0; i < NUM_DSP48; i++) begin
                if (dsp_en[i]) dsp48_usage_count <= dsp48_usage_count + 1;
            end
            utilization_percent <= (dsp48_usage_count * 100) / NUM_DSP48;
        end
    end
    
    // SYNTHESIS FIX: Removed debug displays for synthesis
    
endmodule

// SYNTHESIS FIX: Simplified DSP48 primitive for synthesis
module dsp48_simple #(
    parameter WIDTH = 16
)(
    input wire clk,
    input wire rst,
    input wire en,
    input wire [WIDTH-1:0] a,
    input wire [WIDTH-1:0] b,
    input wire [WIDTH*2-1:0] c,
    output reg [WIDTH*2-1:0] p,
    output reg valid
);

    // Simple 2-stage pipeline for timing closure
    reg [WIDTH-1:0] a_reg, b_reg;
    reg [WIDTH*2-1:0] c_reg;
    reg [WIDTH*2-1:0] mult_result;
    reg en_reg1, en_reg2;
    
    always @(posedge clk) begin
        if (rst) begin
            a_reg <= 0;
            b_reg <= 0;
            c_reg <= 0;
            mult_result <= 0;
            en_reg1 <= 0;
            en_reg2 <= 0;
            p <= 0;
            valid <= 0;
        end else begin
            // Stage 1: Input registration
            a_reg <= a;
            b_reg <= b;
            c_reg <= c;
            en_reg1 <= en;
            
            // Stage 2: Multiplication and accumulation
            mult_result <= a_reg * b_reg;
            en_reg2 <= en_reg1;
            
            // Output stage
            p <= mult_result + c_reg;
            valid <= en_reg2;
        end
    end

endmodule 