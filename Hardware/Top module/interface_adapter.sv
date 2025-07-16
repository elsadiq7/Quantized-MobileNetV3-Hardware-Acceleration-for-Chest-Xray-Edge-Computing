module interface_adapter #(
    parameter WIDTH = 16,
    parameter FRAC = 8,
    parameter ACC_OUT_CHANNELS = 16,    // Accelerator output channels
    parameter BN_IN_CHANNELS = 16,      // BottleNeck input channels  
    parameter BN_OUT_CHANNELS = 96,     // BottleNeck output channels
    parameter FINAL_IN_CHANNELS = 96,   // Final layer input channels
    parameter FINAL_NUM_CLASSES = 15    // Final layer output classes
)(
    input wire clk,
    input wire rst,
    input wire en,
    
    // Interface to accelerator (First Layer)
    input wire [WIDTH-1:0] acc_data_out,
    input wire acc_valid_out,
    input wire acc_done,
    output reg acc_ready,
    
    // Interface to BottleNeck_11stage
    output reg [WIDTH-1:0] bn_data_in,
    output reg [$clog2(BN_IN_CHANNELS)-1:0] bn_channel_in,
    output reg bn_valid_in,
    input wire [WIDTH-1:0] bn_data_out,
    input wire [$clog2(BN_OUT_CHANNELS)-1:0] bn_channel_out,
    input wire bn_valid_out,
    input wire bn_done,
    output reg bn_en,
    
    // Interface to final_layer_top
    output reg [WIDTH-1:0] final_data_in,
    output reg [$clog2(FINAL_IN_CHANNELS)-1:0] final_channel_in,
    output reg final_valid_in,
    input wire signed [WIDTH-1:0] final_data_out [0:FINAL_NUM_CLASSES-1],
    input wire final_valid_out,
    output reg final_en,
    
    // Overall system outputs
    output reg signed [WIDTH-1:0] system_data_out [0:FINAL_NUM_CLASSES-1],
    output reg system_valid_out,
    output reg system_done
);

    // State machine for pipeline control
    typedef enum logic [2:0] {
        IDLE,
        STAGE1_PROCESSING,   // Accelerator processing
        STAGE1_TO_STAGE2,    // Transfer from accelerator to BottleNeck
        STAGE2_PROCESSING,   // BottleNeck processing
        STAGE2_TO_STAGE3,    // Transfer from BottleNeck to final layer
        STAGE3_PROCESSING,   // Final layer processing
        DONE
    } pipeline_state_t;
    
    pipeline_state_t state, next_state;
    
    // CLEAN: Activity tracking for progression (no timeout counters)
    reg [$clog2(10000)-1:0] acc_output_count;
    reg [$clog2(10000)-1:0] bn_output_count;
    
    // Buffer for accelerator to BottleNeck transfer
    localparam ACC_BUFFER_SIZE = 16384; // Sufficient for 112x112x16 features
    reg [WIDTH-1:0] acc_to_bn_buffer [0:ACC_BUFFER_SIZE-1];
    reg [$clog2(ACC_BUFFER_SIZE+1)-1:0] acc_buffer_write_ptr;
    reg [$clog2(ACC_BUFFER_SIZE+1)-1:0] acc_buffer_read_ptr;
    reg [$clog2(ACC_BUFFER_SIZE+1)-1:0] acc_buffer_count;
    reg acc_buffer_full, acc_buffer_empty;
    
    // Buffer for BottleNeck to final layer transfer
    localparam BN_BUFFER_SIZE = 4704; // 7x7x96 = 4704 features
    reg [WIDTH-1:0] bn_to_final_buffer [0:BN_BUFFER_SIZE-1];
    reg [$clog2(BN_BUFFER_SIZE+1)-1:0] bn_buffer_write_ptr;
    reg [$clog2(BN_BUFFER_SIZE+1)-1:0] bn_buffer_read_ptr;
    reg [$clog2(BN_BUFFER_SIZE+1)-1:0] bn_buffer_count;
    reg bn_buffer_full, bn_buffer_empty;
    
    // Transfer control signals
    reg acc_transfer_active;
    reg bn_transfer_active;
    reg final_processing_active;
    
    // Channel counters for proper data ordering
    reg [$clog2(BN_IN_CHANNELS)-1:0] bn_channel_counter;
    reg [$clog2(FINAL_IN_CHANNELS)-1:0] final_channel_counter;
    
    // Debug variables - declared outside always blocks  
    int wait_cycles = 0;
    bit done_announced = 0;
    int stage1_cycles = 0, stage2_cycles = 0, stage3_cycles = 0;
    
    // State machine logic
    always @(posedge clk) begin
        if (rst) begin
            state <= IDLE;
        end else begin
            state <= next_state;
        end
    end
    
    // CLEAN: Pure logic-based next state transitions (no timeouts)
    always @(*) begin
        case (state)
            IDLE: begin
                if (en) 
                    next_state = STAGE1_PROCESSING;
                else
                    next_state = IDLE;
            end
            
            STAGE1_PROCESSING: begin
                // CLEAN: Pure completion detection based on accelerator done signal
                if (acc_done) begin
                    next_state = STAGE1_TO_STAGE2;
                end
                else begin
                    next_state = STAGE1_PROCESSING;
                end
            end
            
            STAGE1_TO_STAGE2: begin
                if (acc_buffer_empty)  // All data transferred
                    next_state = STAGE2_PROCESSING;
                else
                    next_state = STAGE1_TO_STAGE2;
            end
            
            STAGE2_PROCESSING: begin
                // CLEAN: Pure completion detection based on bottleneck done signal
                if (bn_done) begin
                    next_state = STAGE2_TO_STAGE3;
                end
                else begin
                    next_state = STAGE2_PROCESSING;
                end
            end
            
            STAGE2_TO_STAGE3: begin
                if (bn_buffer_empty)  // All data transferred
                    next_state = STAGE3_PROCESSING;
                else
                    next_state = STAGE2_TO_STAGE3;
            end
            
            STAGE3_PROCESSING: begin
                // CLEAN: Pure completion detection based on final layer output
                if (final_valid_out) begin
                    next_state = DONE;
                end
                else begin
                    next_state = STAGE3_PROCESSING;
                end
            end
            
            DONE: begin
                if (!en)
                    next_state = IDLE;
                else
                    next_state = DONE;
            end
            
            default: next_state = IDLE;
        endcase
    end
    
    // CLEAN: Buffer management and control logic (no timeout monitoring)
    always @(posedge clk) begin
        if (rst) begin
            // Reset all pointers and flags
            acc_buffer_write_ptr <= 0;
            acc_buffer_read_ptr <= 0;
            acc_buffer_count <= 0;
            acc_buffer_full <= 0;
            acc_buffer_empty <= 1;
            
            bn_buffer_write_ptr <= 0;
            bn_buffer_read_ptr <= 0;
            bn_buffer_count <= 0;
            bn_buffer_full <= 0;
            bn_buffer_empty <= 1;
            
            // Reset control signals
            acc_ready <= 1;
            bn_en <= 0;
            final_en <= 0;
            
            bn_data_in <= 0;
            bn_channel_in <= 0;
            bn_valid_in <= 0;
            
            final_data_in <= 0;
            final_channel_in <= 0;
            final_valid_in <= 0;
            
            system_valid_out <= 0;
            system_done <= 0;
            
            // Reset transfer control
            acc_transfer_active <= 0;
            bn_transfer_active <= 0;
            final_processing_active <= 0;
            
            bn_channel_counter <= 0;
            final_channel_counter <= 0;
            
        end else begin
            case (state)
                IDLE: begin
                    acc_ready <= 1;
                    bn_en <= 0;
                    final_en <= 0;
                    system_done <= 0;
                end
                
                STAGE1_PROCESSING: begin
                    acc_ready <= 1;
                    bn_en <= 0;
                    final_en <= 0;
                    
                    // Buffer accelerator output
                    if (acc_valid_out && !acc_buffer_full) begin
                        acc_to_bn_buffer[acc_buffer_write_ptr] <= acc_data_out;
                        acc_buffer_write_ptr <= acc_buffer_write_ptr + 1;
                        acc_buffer_count <= acc_buffer_count + 1;
                        acc_buffer_empty <= 0;
                        
                        if (acc_buffer_count == ACC_BUFFER_SIZE - 1) begin
                            acc_buffer_full <= 1;
                        end
                    end
                    
                end
                
                STAGE1_TO_STAGE2: begin
                    acc_ready <= 0;
                    bn_en <= 1;
                    acc_transfer_active <= 1;
                    
                    // Transfer data from buffer to BottleNeck
                    if (!acc_buffer_empty) begin
                        bn_data_in <= acc_to_bn_buffer[acc_buffer_read_ptr];
                        bn_channel_in <= bn_channel_counter;
                        bn_valid_in <= 1;
                        
                        acc_buffer_read_ptr <= acc_buffer_read_ptr + 1;
                        acc_buffer_count <= acc_buffer_count - 1;
                        
                        // Update channel counter
                        if (bn_channel_counter == BN_IN_CHANNELS - 1) begin
                            bn_channel_counter <= 0;
                        end else begin
                            bn_channel_counter <= bn_channel_counter + 1;
                        end
                        
                        if (acc_buffer_count == 1) begin
                            acc_buffer_empty <= 1;
                            acc_buffer_full <= 0;
                        end
                    end else begin
                        bn_valid_in <= 0;
                        acc_transfer_active <= 0;
                    end
                end
                
                STAGE2_PROCESSING: begin
                    bn_valid_in <= 0; // Stop input to BottleNeck
                    
                    // Buffer BottleNeck output
                    if (bn_valid_out && !bn_buffer_full) begin
                        bn_to_final_buffer[bn_buffer_write_ptr] <= bn_data_out;
                        bn_buffer_write_ptr <= bn_buffer_write_ptr + 1;
                        bn_buffer_count <= bn_buffer_count + 1;
                        bn_buffer_empty <= 0;
                        
                        if (bn_buffer_count == BN_BUFFER_SIZE - 1) begin
                            bn_buffer_full <= 1;
                        end
                    end
                    
                end
                
                STAGE2_TO_STAGE3: begin
                    bn_en <= 0;
                    final_en <= 1;
                    bn_transfer_active <= 1;
                    
                    // Transfer data from buffer to final layer
                    if (!bn_buffer_empty) begin
                        final_data_in <= bn_to_final_buffer[bn_buffer_read_ptr];
                        final_channel_in <= final_channel_counter;
                        final_valid_in <= 1;
                        
                        bn_buffer_read_ptr <= bn_buffer_read_ptr + 1;
                        bn_buffer_count <= bn_buffer_count - 1;
                        
                        // Update channel counter
                        if (final_channel_counter == FINAL_IN_CHANNELS - 1) begin
                            final_channel_counter <= 0;
                        end else begin
                            final_channel_counter <= final_channel_counter + 1;
                        end
                        
                        if (bn_buffer_count == 1) begin
                            bn_buffer_empty <= 1;
                            bn_buffer_full <= 0;
                        end
                    end else begin
                        final_valid_in <= 0;
                        bn_transfer_active <= 0;
                    end
                end
                
                STAGE3_PROCESSING: begin
                    final_valid_in <= 0; // Stop input to final layer
                    final_processing_active <= 1;
                    
                    // Capture final layer output
                    if (final_valid_out) begin
                        system_data_out <= final_data_out;
                        system_valid_out <= 1;
                    end
                end
                
                DONE: begin
                    final_en <= 0;
                    system_done <= 1;
                    final_processing_active <= 0;
                end
            endcase
        end
    end
    
    // ENHANCED: Comprehensive debug monitoring with detailed pipeline tracing
    always @(posedge clk) begin
        if (!rst && en) begin
            case (state)
                IDLE: begin
                    if (en) begin
                        $display("=== INTERFACE ADAPTER DEBUG ===");
                        $display("Interface: Starting pipeline - transitioning to STAGE1_PROCESSING at time %0t", $time);
                        $display("Interface: Initial buffer states - acc_empty=%b, bn_empty=%b", acc_buffer_empty, bn_buffer_empty);
                    end
                end
                
                STAGE1_PROCESSING: begin
                    if (acc_valid_out) begin
                        acc_output_count = acc_output_count + 1;
                        if (acc_output_count % 1000 == 0 || acc_output_count < 10) begin
                            $display("Interface: Buffering accelerator output #%0d - data=0x%04x, buffer_count=%0d/%0d", 
                                     acc_output_count, acc_data_out, acc_buffer_count, ACC_BUFFER_SIZE);
                        end
                    end
                    if (acc_done) begin
                        $display("Interface: *** ACCELERATOR COMPLETED *** - received %0d outputs", acc_output_count);
                        $display("Interface: Final buffer state - count=%0d, full=%b, empty=%b", 
                                 acc_buffer_count, acc_buffer_full, acc_buffer_empty);
                        $display("Interface: Transitioning to STAGE1_TO_STAGE2 for data transfer");
                    end
                end
                
                STAGE1_TO_STAGE2: begin
                    if (bn_valid_in && bn_channel_counter % 1000 == 0) begin
                        $display("Interface: Transferring to BottleNeck - data=0x%04x, ch=%0d, buffer_remaining=%0d", 
                                 bn_data_in, bn_channel_in, acc_buffer_count);
                    end
                    if (acc_buffer_empty) begin
                        $display("Interface: *** ACCELERATOR BUFFER EMPTY *** - transfer complete");
                        $display("Interface: Transitioning to STAGE2_PROCESSING - enabling BottleNeck");
                    end
                end
                
                STAGE2_PROCESSING: begin
                    if (bn_valid_out) begin
                        bn_output_count = bn_output_count + 1;
                        if (bn_output_count % 100 == 0 || bn_output_count < 10) begin
                            $display("Interface: Buffering BottleNeck output #%0d - data=0x%04x, ch=%0d, count=%0d/%0d", 
                                     bn_output_count, bn_data_out, bn_channel_out, bn_buffer_count, BN_BUFFER_SIZE);
                        end
                    end
                    if (bn_done) begin
                        $display("Interface: *** BOTTLENECK COMPLETED *** - received %0d outputs", bn_output_count);
                        $display("Interface: Final buffer state - count=%0d, full=%b, empty=%b", 
                                 bn_buffer_count, bn_buffer_full, bn_buffer_empty);
                        $display("Interface: Transitioning to STAGE2_TO_STAGE3 for data transfer");
                    end
                end
                
                STAGE2_TO_STAGE3: begin
                    if (final_valid_in && final_channel_counter % 100 == 0) begin
                        $display("Interface: Transferring to final layer - data=0x%04x, ch=%0d, buffer_remaining=%0d", 
                                 final_data_in, final_channel_in, bn_buffer_count);
                    end
                    if (bn_buffer_empty) begin
                        $display("Interface: *** BOTTLENECK BUFFER EMPTY *** - transfer complete");
                        $display("Interface: Transitioning to STAGE3_PROCESSING - enabling final layer");
                    end
                end
                
                STAGE3_PROCESSING: begin
                    if (final_valid_out) begin
                        $display("Interface: *** FINAL LAYER OUTPUT RECEIVED *** - classification complete");
                        $display("Interface: Transitioning to DONE state");
                        for (int i = 0; i < FINAL_NUM_CLASSES; i++) begin
                            $display("  Class[%0d]: 0x%04x", i, final_data_out[i]);
                        end
                    end else begin
                        wait_cycles++;
                        if (wait_cycles % 1000 == 0) begin
                            $display("Interface: Waiting for final layer output - cycles waited: %0d", wait_cycles);
                            $display("Interface: final_en=%b, final_valid_in=%b, final_valid_out=%b", 
                                     final_en, final_valid_in, final_valid_out);
                        end
                    end
                end
                
                DONE: begin
                    if (!done_announced) begin
                        $display("Interface: *** PIPELINE COMPLETE *** - system_done asserted");
                        $display("Interface: Total processing complete at time %0t", $time);
                        done_announced = 1;
                    end
                end
            endcase
            
            // Enhanced periodic debug with more details
            if ($time % 10000 == 0 && $time > 0) begin  // Every 10,000 time units
                $display("=== INTERFACE PERIODIC DEBUG ===");
                $display("Interface: state=%0d (%s), time=%0t", state, state.name(), $time);
                $display("Interface: Signal states - acc_done=%b, bn_done=%b, final_valid=%b, system_done=%b", 
                         acc_done, bn_done, final_valid_out, system_done);
                $display("Interface: Enable signals - bn_en=%b, final_en=%b", bn_en, final_en);
                $display("Interface: Buffer states - acc: count=%0d empty=%b, bn: count=%0d empty=%b", 
                         acc_buffer_count, acc_buffer_empty, bn_buffer_count, bn_buffer_empty);
                $display("Interface: Output counts - acc=%0d, bn=%0d", acc_output_count, bn_output_count);
                $display("================================");
            end
            
            // Critical state monitoring - detect if stuck
            case (state)
                STAGE1_PROCESSING: begin
                    stage1_cycles++;
                    if (stage1_cycles % 5000 == 0) begin
                        $display("Interface: *** STAGE1 LONG RUNNING *** - %0d cycles, acc_done=%b, outputs=%0d", 
                                 stage1_cycles, acc_done, acc_output_count);
                    end
                end
                STAGE2_PROCESSING: begin
                    stage2_cycles++;
                    if (stage2_cycles % 5000 == 0) begin
                        $display("Interface: *** STAGE2 LONG RUNNING *** - %0d cycles, bn_done=%b, outputs=%0d", 
                                 stage2_cycles, bn_done, bn_output_count);
                    end
                end
                STAGE3_PROCESSING: begin
                    stage3_cycles++;
                    if (stage3_cycles % 1000 == 0) begin
                        $display("Interface: *** STAGE3 LONG RUNNING *** - %0d cycles, final_valid_out=%b", 
                                 stage3_cycles, final_valid_out);
                    end
                end
                default: begin
                    stage1_cycles = 0;
                    stage2_cycles = 0; 
                    stage3_cycles = 0;
                end
            endcase
        end
    end

endmodule 