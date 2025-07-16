`timescale 1ns / 1ps

/*
 * SE-Shortcut Bridge Module
 * 
 * Synchronization bridge between SE_module_streaming and shortcut_with_actual_modules
 * to resolve timing and data flow mismatches in Config 4 (Full Integration).
 * 
 * Key Functions:
 * 1. Buffer SE module's progressive outputs
 * 2. Provide continuous data flow to shortcut module
 * 3. Handle SE scale update gaps
 * 4. Maintain streaming interface compatibility
 * 
 * Author: Augment Agent
 * Date: 2025-07-06
 * Purpose: Fix Config 4 integration quality degradation
 */

module SE_Shortcut_Bridge #(
    parameter DATA_WIDTH = 16,
    parameter CHANNELS = 16,
    parameter FEATURE_SIZE = 56,
    parameter BUFFER_DEPTH = 64
) (
    input logic clk,
    input logic rst,
    input logic en,
    
    // SE module input interface
    input logic [DATA_WIDTH-1:0] se_data_in,
    input logic [$clog2(CHANNELS)-1:0] se_channel_in,
    input logic se_valid_in,
    
    // Shortcut output interface
    output logic [DATA_WIDTH-1:0] shortcut_data_out,
    output logic [$clog2(CHANNELS)-1:0] shortcut_channel_out,
    output logic shortcut_valid_out,
    
    // Buffer status
    output logic buffer_full,
    output logic buffer_empty,
    output logic [$clog2(BUFFER_DEPTH):0] buffer_level
);

    // Buffer memory
    logic [DATA_WIDTH-1:0] data_buffer [BUFFER_DEPTH-1:0];
    logic [$clog2(CHANNELS)-1:0] channel_buffer [BUFFER_DEPTH-1:0];
    
    // Buffer pointers
    logic [$clog2(BUFFER_DEPTH)-1:0] write_ptr;
    logic [$clog2(BUFFER_DEPTH)-1:0] read_ptr;
    logic [$clog2(BUFFER_DEPTH):0] count;
    
    // Buffer status signals
    assign buffer_full = (count >= BUFFER_DEPTH);
    assign buffer_empty = (count == 0);
    assign buffer_level = count;
    
    // Initialize buffer with generate block for synthesis
    genvar i;
    generate
        for (i = 0; i < BUFFER_DEPTH; i = i + 1) begin : gen_buffer_init
            always_ff @(posedge clk) begin
                if (rst) begin
                    data_buffer[i] <= {DATA_WIDTH{1'b0}};
                    channel_buffer[i] <= {$clog2(CHANNELS){1'b0}};
                end
            end
        end
    endgenerate
    
    // Buffer control logic
    always_ff @(posedge clk) begin
        if (rst) begin
            write_ptr <= 0;
            read_ptr <= 0;
            count <= 0;
            shortcut_data_out <= {DATA_WIDTH{1'b0}};
            shortcut_channel_out <= {$clog2(CHANNELS){1'b0}};
            shortcut_valid_out <= 1'b0;
        end else if (en) begin
            
            // Write logic
            if (se_valid_in && !buffer_full) begin
                data_buffer[write_ptr] <= se_data_in;
                channel_buffer[write_ptr] <= se_channel_in;
                write_ptr <= (write_ptr + 1) % BUFFER_DEPTH;
                count <= count + 1;
            end
            
            // Read logic
            if (!buffer_empty) begin
                shortcut_data_out <= data_buffer[read_ptr];
                shortcut_channel_out <= channel_buffer[read_ptr];
                shortcut_valid_out <= 1'b1;
                read_ptr <= (read_ptr + 1) % BUFFER_DEPTH;
                
                // Adjust count based on whether we wrote this cycle
                if (se_valid_in && !buffer_full) begin
                    count <= count; // No change if both read and write
                end else begin
                    count <= count - 1;
                end
            end else begin
                shortcut_valid_out <= 1'b0;
            end
            
        end else begin
            // Not enabled - clear outputs
            shortcut_data_out <= {DATA_WIDTH{1'b0}};
            shortcut_channel_out <= {$clog2(CHANNELS){1'b0}};
            shortcut_valid_out <= 1'b0;
        end
    end

endmodule
