module external_memory_controller #(
    parameter WIDTH = 16,
    parameter FRAC = 8,
    parameter DDR_DATA_WIDTH = 512,
    parameter DDR_ADDR_WIDTH = 32,
    parameter CACHE_SIZE = 1024,       // Reduced from 8192
    parameter BURST_LENGTH = 8
)(
    input wire clk,
    input wire rst,
    input wire en,
    
    // AXI4 Interface to DDR4
    output reg [DDR_ADDR_WIDTH-1:0] m_axi_araddr,
    output reg [7:0] m_axi_arlen,
    output reg [2:0] m_axi_arsize,
    output reg [1:0] m_axi_arburst,
    output reg m_axi_arvalid,
    input wire m_axi_arready,
    
    input wire [DDR_DATA_WIDTH-1:0] m_axi_rdata,
    input wire [1:0] m_axi_rresp,
    input wire m_axi_rlast,
    input wire m_axi_rvalid,
    output reg m_axi_rready,
    
    output reg [DDR_ADDR_WIDTH-1:0] m_axi_awaddr,
    output reg [7:0] m_axi_awlen,
    output reg [2:0] m_axi_awsize,
    output reg [1:0] m_axi_awburst,
    output reg m_axi_awvalid,
    input wire m_axi_awready,
    
    output reg [DDR_DATA_WIDTH-1:0] m_axi_wdata,
    output reg [(DDR_DATA_WIDTH/8)-1:0] m_axi_wstrb,
    output reg m_axi_wlast,
    output reg m_axi_wvalid,
    input wire m_axi_wready,
    
    input wire [1:0] m_axi_bresp,
    input wire m_axi_bvalid,
    output reg m_axi_bready,
    
    // Weight access interface
    input wire [31:0] weight_addr,
    input wire [3:0] weight_type,
    output reg [WIDTH-1:0] weight_data,
    input wire weight_req,
    output reg weight_valid,
    
    // Cache control
    input wire cache_flush,
    output reg cache_ready
);

    // DDR4 Memory Map
    localparam DDR_BASE_ADDR = 32'h4000_0000;
    localparam FINAL_PW_WEIGHTS_OFFSET = 32'h0000_0000;
    localparam FINAL_LINEAR1_WEIGHTS_OFFSET = 32'h0010_0000;
    localparam FINAL_LINEAR2_WEIGHTS_OFFSET = 32'h0C00_0000;
    
    // SYNTHESIS FIX: Properly inferred block RAM with explicit attributes
    (* ram_style = "block" *) reg [WIDTH-1:0] weight_cache_reg [0:CACHE_SIZE-1];
    (* ram_style = "distributed" *) reg [31:0] cache_tags_reg [0:CACHE_SIZE/BURST_LENGTH-1];
    (* ram_style = "distributed" *) reg cache_valid_reg [0:CACHE_SIZE/BURST_LENGTH-1];
    
    // Cache management registers
    reg [$clog2(CACHE_SIZE)-1:0] cache_write_ptr;
    
    // State machine for DDR4 access
    typedef enum logic [2:0] {
        IDLE,
        CHECK_CACHE,
        CACHE_HIT,
        CACHE_MISS_READ_ADDR,
        CACHE_MISS_READ_DATA,
        CACHE_UPDATE,
        WEIGHT_READY
    } ddr_state_t;
    
    ddr_state_t state, next_state;
    
    // Request buffer
    reg [31:0] req_addr_reg;
    reg [3:0] req_type_reg;
    reg [$clog2(BURST_LENGTH)-1:0] burst_counter;
    
    // SYNTHESIS FIX: Simple address calculation function
    function [31:0] calc_ddr_addr(input [3:0] wtype, input [31:0] addr);
        case (wtype)
            4'h2: calc_ddr_addr = DDR_BASE_ADDR + FINAL_PW_WEIGHTS_OFFSET + (addr << 1);
            4'h5: calc_ddr_addr = DDR_BASE_ADDR + FINAL_LINEAR1_WEIGHTS_OFFSET + (addr << 1);
            4'h9: calc_ddr_addr = DDR_BASE_ADDR + FINAL_LINEAR2_WEIGHTS_OFFSET + (addr << 1);
            default: calc_ddr_addr = DDR_BASE_ADDR;
        endcase
    endfunction
    
    // SYNTHESIS FIX: Simplified cache lookup with wires
    wire [$clog2(CACHE_SIZE/BURST_LENGTH)-1:0] cache_line_ptr;
    wire [$clog2(CACHE_SIZE)-1:0] cache_idx;
    wire [31:0] current_cache_tag;
    wire cache_hit;
    
    assign cache_line_ptr = (req_addr_reg >> 4) % (CACHE_SIZE/BURST_LENGTH);
    assign cache_idx = cache_line_ptr * BURST_LENGTH + ((req_addr_reg >> 1) & (BURST_LENGTH-1));
    assign current_cache_tag = req_addr_reg & 32'hFFFF_FFF0;
    assign cache_hit = cache_valid_reg[cache_line_ptr] && (cache_tags_reg[cache_line_ptr] == current_cache_tag);
    
    // State machine
    always @(posedge clk) begin
        if (rst) begin
            state <= IDLE;
        end else begin
            state <= next_state;
        end
    end
    
    // Next state logic
    always @(*) begin
        case (state)
            IDLE: begin
                if (weight_req && en)
                    next_state = CHECK_CACHE;
                else
                    next_state = IDLE;
            end
            
            CHECK_CACHE: begin
                if (cache_hit)
                    next_state = CACHE_HIT;
                else
                    next_state = CACHE_MISS_READ_ADDR;
            end
            
            CACHE_HIT: begin
                next_state = WEIGHT_READY;
            end
            
            CACHE_MISS_READ_ADDR: begin
                if (m_axi_arready)
                    next_state = CACHE_MISS_READ_DATA;
                else
                    next_state = CACHE_MISS_READ_ADDR;
            end
            
            CACHE_MISS_READ_DATA: begin
                if (m_axi_rvalid && m_axi_rlast)
                    next_state = CACHE_UPDATE;
                else
                    next_state = CACHE_MISS_READ_DATA;
            end
            
            CACHE_UPDATE: begin
                next_state = WEIGHT_READY;
            end
            
            WEIGHT_READY: begin
                next_state = IDLE;
            end
            
            default: next_state = IDLE;
        endcase
    end
    
    // SYNTHESIS FIX: Initialization counter for proper reset
    reg [$clog2(CACHE_SIZE/BURST_LENGTH)-1:0] init_counter;
    reg init_done;
    
    // Control logic
    always @(posedge clk) begin
        if (rst) begin
            // Reset all outputs
            m_axi_arvalid <= 0;
            m_axi_rready <= 0;
            m_axi_awvalid <= 0;
            m_axi_wvalid <= 0;
            m_axi_bready <= 0;
            
            weight_data <= 0;
            weight_valid <= 0;
            cache_ready <= 0;
            
            // SYNTHESIS FIX: Proper initialization sequence
            init_counter <= 0;
            init_done <= 0;
            
            burst_counter <= 0;
            cache_write_ptr <= 0;
            
        end else if (!init_done) begin
            // Initialize cache valid bits sequentially
            cache_valid_reg[init_counter] <= 0;
            if (init_counter < CACHE_SIZE/BURST_LENGTH - 1) begin
                init_counter <= init_counter + 1;
            end else begin
                init_done <= 1;
                cache_ready <= 1;
            end
            
        end else begin
            case (state)
                IDLE: begin
                    weight_valid <= 0;
                    m_axi_arvalid <= 0;
                    m_axi_rready <= 0;
                    
                    if (weight_req && en) begin
                        req_addr_reg <= weight_addr;
                        req_type_reg <= weight_type;
                    end
                end
                
                CHECK_CACHE: begin
                    // Cache lookup performed in combinational logic
                end
                
                CACHE_HIT: begin
                    // Data available in cache
                    weight_data <= weight_cache_reg[cache_idx];
                    weight_valid <= 1;
                end
                
                CACHE_MISS_READ_ADDR: begin
                    // Issue read request to DDR4
                    m_axi_araddr <= calc_ddr_addr(req_type_reg, req_addr_reg);
                    m_axi_arlen <= BURST_LENGTH - 1;
                    m_axi_arsize <= 3'b011; // 8 bytes
                    m_axi_arburst <= 2'b01; // INCR
                    m_axi_arvalid <= 1;
                    m_axi_rready <= 1;
                    
                    burst_counter <= 0;
                end
                
                CACHE_MISS_READ_DATA: begin
                    if (m_axi_rvalid) begin
                        // SYNTHESIS FIX: Store one data element per cycle
                        if (burst_counter < BURST_LENGTH) begin
                            weight_cache_reg[cache_line_ptr * BURST_LENGTH + burst_counter] 
                                <= m_axi_rdata[15:0]; // Take first 16 bits
                        end
                        
                        burst_counter <= burst_counter + 1;
                        
                        if (m_axi_rlast) begin
                            cache_tags_reg[cache_line_ptr] <= current_cache_tag;
                            cache_valid_reg[cache_line_ptr] <= 1;
                            m_axi_arvalid <= 0;
                            m_axi_rready <= 0;
                        end
                    end
                end
                
                CACHE_UPDATE: begin
                    // Cache has been updated, now set correct index
                    cache_write_ptr <= cache_idx;
                end
                
                WEIGHT_READY: begin
                    weight_data <= weight_cache_reg[cache_write_ptr];
                    weight_valid <= 1;
                end
            endcase
        end
    end
    
    // Cache flush logic - SYNTHESIS FIX: Sequential initialization
    reg [$clog2(CACHE_SIZE/BURST_LENGTH)-1:0] flush_counter;
    reg flush_in_progress;
    
    always @(posedge clk) begin
        if (rst) begin
            flush_counter <= 0;
            flush_in_progress <= 0;
        end else if (cache_flush && !flush_in_progress) begin
            flush_in_progress <= 1;
            flush_counter <= 0;
        end else if (flush_in_progress) begin
            cache_valid_reg[flush_counter] <= 0;
            if (flush_counter < CACHE_SIZE/BURST_LENGTH - 1) begin
                flush_counter <= flush_counter + 1;
            end else begin
                flush_in_progress <= 0;
                cache_ready <= 1;
            end
        end
    end
    
    // AXI write channel (for weight loading) - simplified
    always @(posedge clk) begin
        if (rst) begin
            m_axi_awvalid <= 0;
            m_axi_wvalid <= 0;
            m_axi_bready <= 1;
        end
        // Write logic can be added here for weight loading from host
    end

endmodule 