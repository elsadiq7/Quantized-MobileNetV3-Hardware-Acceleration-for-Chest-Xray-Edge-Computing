// ============================================================================
// Simplified State Machine for Chest X-Ray Classifier
// Addresses complex nested state machine issues identified in design review
// ============================================================================

module simplified_state_machine #(
    parameter WIDTH = 16
) (
    input wire clk,
    input wire rst,
    input wire en,
    
    // Status inputs from processing stages
    input wire acc_done,
    input wire bn_done,
    input wire final_valid,
    input wire weights_loaded,
    input wire memory_ready,
    
    // Control outputs
    output reg system_enable,
    output reg acc_en,
    output reg bn_en,
    output reg final_en,
    output reg processing_done,
    output reg ready_for_image,
    
    // Status outputs
    output reg [2:0] current_stage,
    output reg error_state,
    output reg [31:0] timeout_counter
);

    // Simplified state encoding - one-hot for better synthesis
    typedef enum logic [3:0] {
        IDLE        = 4'b0001,
        PROCESSING  = 4'b0010,
        WAITING     = 4'b0100,
        DONE        = 4'b1000
    } simple_state_t;
    
    simple_state_t current_state, next_state;
    
    // Stage tracking - simplified to 3 main stages
    typedef enum logic [2:0] {
        STAGE_IDLE = 3'b000,
        STAGE_ACC  = 3'b001,
        STAGE_BN   = 3'b010,
        STAGE_FINAL = 3'b100
    } stage_t;
    
    stage_t processing_stage, next_processing_stage;
    
    // Timeout management
    localparam TIMEOUT_LIMIT = 100000; // 100k cycles max per stage
    reg [31:0] stage_timeout_counter;
    reg timeout_occurred;
    
    // Stage completion tracking
    reg acc_completed, bn_completed, final_completed;
    
    // ========================================================================
    // State Machine Logic - Simplified for Better Synthesis
    // ========================================================================
    
    // State register
    always_ff @(posedge clk) begin
        if (rst) begin
            current_state <= IDLE;
            processing_stage <= STAGE_IDLE;
            timeout_counter <= 0;
            stage_timeout_counter <= 0;
            acc_completed <= 0;
            bn_completed <= 0;
            final_completed <= 0;
            timeout_occurred <= 0;
        end else begin
            current_state <= next_state;
            processing_stage <= next_processing_stage;
            
            // Timeout management
            if (current_state == PROCESSING) begin
                stage_timeout_counter <= stage_timeout_counter + 1;
                timeout_counter <= timeout_counter + 1;
                
                if (stage_timeout_counter >= TIMEOUT_LIMIT) begin
                    timeout_occurred <= 1;
                end
            end else begin
                stage_timeout_counter <= 0;
                if (current_state == IDLE) begin
                    timeout_counter <= 0;
                    timeout_occurred <= 0;
                end
            end
            
            // Completion tracking with edge detection
            if (acc_done && !acc_completed) begin
                acc_completed <= 1;
                stage_timeout_counter <= 0; // Reset timeout on progress
            end
            
            if (bn_done && !bn_completed) begin
                bn_completed <= 1;
                stage_timeout_counter <= 0;
            end
            
            if (final_valid && !final_completed) begin
                final_completed <= 1;
                stage_timeout_counter <= 0;
            end
            
            // Reset completion flags when starting new processing
            if (current_state == IDLE && next_state == PROCESSING) begin
                acc_completed <= 0;
                bn_completed <= 0;
                final_completed <= 0;
            end
        end
    end
    
    // Next state logic - simplified decision tree
    always_comb begin
        next_state = current_state;
        
        case (current_state)
            IDLE: begin
                if (en && weights_loaded && memory_ready) begin
                    next_state = PROCESSING;
                end
            end
            
            PROCESSING: begin
                // Simple completion check - all stages done OR timeout
                if ((acc_completed && bn_completed && final_completed) || timeout_occurred) begin
                    next_state = DONE;
                end
                // Optional waiting state for complex handshaking
                else if (acc_completed && bn_completed && !final_completed) begin
                    next_state = WAITING;
                end
            end
            
            WAITING: begin
                // Wait for final stage or timeout
                if (final_completed || timeout_occurred) begin
                    next_state = DONE;
                end
                // Return to processing if needed
                else if (stage_timeout_counter < (TIMEOUT_LIMIT / 2)) begin
                    next_state = PROCESSING;
                end
            end
            
            DONE: begin
                // Stay in done state until reset or new enable
                if (!en) begin
                    next_state = IDLE;
                end
            end
            
            default: next_state = IDLE;
        endcase
    end
    
    // Processing stage logic - sequential progression
    always_comb begin
        next_processing_stage = processing_stage;
        
        case (processing_stage)
            STAGE_IDLE: begin
                if (current_state == PROCESSING) begin
                    next_processing_stage = STAGE_ACC;
                end
            end
            
            STAGE_ACC: begin
                if (acc_completed) begin
                    next_processing_stage = STAGE_BN;
                end
            end
            
            STAGE_BN: begin
                if (bn_completed) begin
                    next_processing_stage = STAGE_FINAL;
                end
            end
            
            STAGE_FINAL: begin
                if (final_completed || current_state == DONE) begin
                    next_processing_stage = STAGE_IDLE;
                end
            end
            
            default: next_processing_stage = STAGE_IDLE;
        endcase
    end
    
    // ========================================================================
    // Output Logic - Combinational for Fast Response
    // ========================================================================
    
    always_comb begin
        // Default values
        system_enable = 0;
        acc_en = 0;
        bn_en = 0;
        final_en = 0;
        processing_done = 0;
        ready_for_image = 0;
        error_state = 0;
        current_stage = processing_stage;
        
        case (current_state)
            IDLE: begin
                ready_for_image = weights_loaded && memory_ready;
                system_enable = 0;
            end
            
            PROCESSING: begin
                system_enable = 1;
                
                // Enable stages based on current processing stage
                case (processing_stage)
                    STAGE_ACC: begin
                        acc_en = 1;
                        bn_en = 0;
                        final_en = 0;
                    end
                    
                    STAGE_BN: begin
                        acc_en = 0;  // Keep accelerator disabled to save power
                        bn_en = 1;
                        final_en = 0;
                    end
                    
                    STAGE_FINAL: begin
                        acc_en = 0;
                        bn_en = 0;
                        final_en = 1;
                    end
                    
                    default: begin
                        acc_en = 1;  // Default to accelerator
                        bn_en = 0;
                        final_en = 0;
                    end
                endcase
                
                // Error detection
                error_state = timeout_occurred;
            end
            
            WAITING: begin
                system_enable = 1;
                acc_en = 0;
                bn_en = 0;
                final_en = 1;  // Only final stage active
                error_state = timeout_occurred;
            end
            
            DONE: begin
                system_enable = 0;
                processing_done = 1;
                ready_for_image = 0;
                error_state = timeout_occurred;
            end
            
            default: begin
                // Safe defaults
                system_enable = 0;
                ready_for_image = 0;
                error_state = 1;  // Unknown state is error
            end
        endcase
    end
    
    // ========================================================================
    // Synthesis Attributes for Optimization
    // ========================================================================
    
    // Ensure one-hot encoding for state machine
    (* fsm_encoding = "one_hot" *) simple_state_t current_state_attr;
    assign current_state_attr = current_state;
    
    // Pipeline the timeout counter for better timing
    (* max_fanout = 50 *) reg [31:0] timeout_counter_reg;
    always_ff @(posedge clk) begin
        timeout_counter_reg <= timeout_counter;
    end

endmodule
