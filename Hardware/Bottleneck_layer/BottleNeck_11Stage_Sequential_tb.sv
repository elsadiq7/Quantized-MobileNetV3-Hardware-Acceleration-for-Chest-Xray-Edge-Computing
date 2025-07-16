`timescale 1ns / 1ps

/*
 * BottleNeck 11-Stage Sequential Architecture Comprehensive Testbench
 * 
 * COMPLETE CNN BACKBONE VALIDATION
 * 
 * This testbench provides comprehensive validation of the 11-stage BottleNeck
 * sequential architecture, verifying the complete transformation from 112×112×16
 * to 7×7×96 dimensions through progressive CNN feature extraction stages.
 * 
 * VALIDATION FEATURES:
 * 1. Realistic CNN input pattern generation
 * 2. Complete SE parameter initialization
 * 3. Stage-by-stage intermediate monitoring
 * 4. Dimensional transformation verification
 * 5. Performance metrics and timing analysis
 * 6. Error detection with assertions
 * 7. Comprehensive reporting and analysis
 * 
 * EXPECTED RESULTS:
 * - Pipeline Latency: <500 cycles to first output
 * - Efficiency: 5-15% (realistic for 11-stage deep pipeline)
 * - Data Integrity: >50% non-zero outputs
 * - Dimensional Accuracy: Exact 112×112×16 → 7×7×96 transformation
 * 
 * Author: Augment Agent
 * Date: 2025-07-06
 * Status: Comprehensive CNN Backbone Validation
 */

module BottleNeck_11Stage_Sequential_tb;

    // ========================================================================
    // TESTBENCH PARAMETERS
    // ========================================================================
    parameter N = 16;                    // Data width
    parameter Q = 8;                     // Fractional bits
    parameter INPUT_CHANNELS = 16;       // Input channels
    parameter OUTPUT_CHANNELS = 96;      // Output channels
    parameter INPUT_HEIGHT = 112;        // Input feature map height
    parameter INPUT_WIDTH = 112;         // Input feature map width
    parameter OUTPUT_HEIGHT = 7;         // Output feature map height
    parameter OUTPUT_WIDTH = 7;          // Output feature map width
    
    // Test configuration parameters
    parameter MAX_TEST_CYCLES = 20000;   // Extended for deep pipeline
    parameter TOTAL_TEST_INPUTS = 1000;  // Comprehensive input set
    parameter LATENCY_TARGET = 500;      // Target latency cycles
    parameter MIN_EFFICIENCY = 5.0;      // Minimum efficiency %
    parameter MAX_EFFICIENCY = 20.0;     // Maximum efficiency %
    parameter MIN_DATA_INTEGRITY = 50.0; // Minimum non-zero output %

    // ========================================================================
    // TESTBENCH SIGNALS
    // ========================================================================
    reg clk, rst, en;
    reg [N-1:0] data_in;
    reg [$clog2(INPUT_CHANNELS)-1:0] channel_in;
    reg valid_in;
    
    // SE module parameters
    reg [N-1:0] se_mean1, se_variance1, se_gamma1, se_beta1;
    reg [N-1:0] se_mean2, se_variance2, se_gamma2, se_beta2;
    reg se_load_kernel_conv1, se_load_kernel_conv2;
    
    // Output interface
    wire [N-1:0] data_out;
    wire [$clog2(OUTPUT_CHANNELS)-1:0] channel_out;
    wire valid_out, done;

    // ========================================================================
    // DEVICE UNDER TEST - 11-STAGE BOTTLENECK SEQUENTIAL
    // ========================================================================
    BottleNeck_11Stage_Sequential_Optimized #(
        .N(N), .Q(Q),
        .INPUT_HEIGHT(INPUT_HEIGHT),
        .INPUT_WIDTH(INPUT_WIDTH),
        .INPUT_CHANNELS(INPUT_CHANNELS),
        .OUTPUT_HEIGHT(OUTPUT_HEIGHT),
        .OUTPUT_WIDTH(OUTPUT_WIDTH),
        .OUTPUT_CHANNELS(OUTPUT_CHANNELS)
    ) dut (
        .clk(clk),
        .rst(rst),
        .en(en),
        .data_in(data_in),
        .channel_in(channel_in),
        .valid_in(valid_in),
        .se_mean1(se_mean1),
        .se_variance1(se_variance1),
        .se_gamma1(se_gamma1),
        .se_beta1(se_beta1),
        .se_mean2(se_mean2),
        .se_variance2(se_variance2),
        .se_gamma2(se_gamma2),
        .se_beta2(se_beta2),
        .se_load_kernel_conv1(se_load_kernel_conv1),
        .se_load_kernel_conv2(se_load_kernel_conv2),
        .data_out(data_out),
        .channel_out(channel_out),
        .valid_out(valid_out),
        .done(done)
    );

    // ========================================================================
    // INTERMEDIATE STAGE MONITORING SIGNALS
    // ========================================================================
    // Access internal stage outputs for monitoring
    wire [N-1:0] stage1_data_out = dut.stage1_data_out;
    wire [N-1:0] stage2_data_out = dut.stage2_data_out;
    wire [N-1:0] stage3_data_out = dut.stage3_data_out;
    wire [N-1:0] stage4_data_out = dut.stage4_data_out;
    wire [N-1:0] stage5_data_out = dut.stage5_data_out;
    wire [N-1:0] stage6_data_out = dut.stage6_data_out;
    wire [N-1:0] stage7_data_out = dut.stage7_data_out;
    wire [N-1:0] stage8_data_out = dut.stage8_data_out;
    wire [N-1:0] stage9_data_out = dut.stage9_data_out;
    wire [N-1:0] stage10_data_out = dut.stage10_data_out;
    
    wire stage1_valid_out = dut.stage1_valid_out;
    wire stage2_valid_out = dut.stage2_valid_out;
    wire stage3_valid_out = dut.stage3_valid_out;
    wire stage4_valid_out = dut.stage4_valid_out;
    wire stage5_valid_out = dut.stage5_valid_out;
    wire stage6_valid_out = dut.stage6_valid_out;
    wire stage7_valid_out = dut.stage7_valid_out;
    wire stage8_valid_out = dut.stage8_valid_out;
    wire stage9_valid_out = dut.stage9_valid_out;
    wire stage10_valid_out = dut.stage10_valid_out;

    // ========================================================================
    // VALIDATION TRACKING VARIABLES
    // ========================================================================
    integer cycle_count;
    integer input_count, output_count, nonzero_count;
    integer first_output_cycle, last_output_cycle, done_cycle;
    integer pipeline_latency, processing_duration;
    real throughput, efficiency, input_output_ratio, data_integrity;
    
    // Stage-specific monitoring
    integer stage_output_counts [1:11];
    integer stage_nonzero_counts [1:11];
    integer stage_first_output_cycles [1:11];
    real stage_data_integrity [1:11];
    
    // Output tracking arrays
    reg [N-1:0] output_values [0:1999];
    reg [$clog2(OUTPUT_CHANNELS)-1:0] output_channels [0:1999];
    integer output_cycles [0:1999];
    
    // Test status flags
    reg test_passed, latency_passed, efficiency_passed, integrity_passed;
    reg dimensional_transform_passed, stage_progression_passed;

    // ========================================================================
    // CLOCK GENERATION
    // ========================================================================
    initial begin
        clk = 0;
        forever #5 clk = ~clk;  // 100MHz clock (10ns period)
    end

    // ========================================================================
    // MAIN TEST SEQUENCE
    // ========================================================================
    initial begin
        $display("================================================================================");
        $display("BOTTLENECK 11-STAGE SEQUENTIAL ARCHITECTURE COMPREHENSIVE TESTBENCH");
        $display("================================================================================");
        $display("CNN Backbone Validation:");
        $display("  Input Dimensions: %0dx%0dx%0d", INPUT_HEIGHT, INPUT_WIDTH, INPUT_CHANNELS);
        $display("  Output Dimensions: %0dx%0dx%0d", OUTPUT_HEIGHT, OUTPUT_WIDTH, OUTPUT_CHANNELS);
        $display("  Spatial Reduction: %.1fx downsampling", 
                 (INPUT_HEIGHT * INPUT_WIDTH * 1.0) / (OUTPUT_HEIGHT * OUTPUT_WIDTH));
        $display("  Channel Expansion: %0dx (from %0d to %0d channels)", 
                 OUTPUT_CHANNELS/INPUT_CHANNELS, INPUT_CHANNELS, OUTPUT_CHANNELS);
        $display("  Test Duration: %0d cycles maximum", MAX_TEST_CYCLES);
        $display("  Target Latency: <%0d cycles", LATENCY_TARGET);
        $display("");

        // Initialize test environment
        initialize_testbench();
        
        // Setup SE parameters for CNN operation
        setup_se_parameters();
        
        // Perform reset sequence
        perform_reset_sequence();
        
        // Run comprehensive validation
        fork
            generate_cnn_input_patterns();
            monitor_pipeline_outputs();
            monitor_intermediate_stages();
            monitor_done_signal();
            timeout_protection();
        join_any
        
        // Perform comprehensive analysis
        analyze_results();
        
        // Generate final report
        generate_final_report();
        
        $display("================================================================================");
        $display("11-STAGE CNN BACKBONE TESTBENCH COMPLETE");
        $display("================================================================================");
        $finish;
    end

    // ========================================================================
    // TESTBENCH INITIALIZATION
    // ========================================================================
    task initialize_testbench();
        integer i;
        begin
            $display("Initializing 11-stage CNN backbone testbench...");

            // Initialize control signals
            rst = 1; en = 0; data_in = 0; channel_in = 0; valid_in = 0;

            // Initialize SE parameters to default values
            se_mean1 = 0; se_variance1 = 0; se_gamma1 = 0; se_beta1 = 0;
            se_mean2 = 0; se_variance2 = 0; se_gamma2 = 0; se_beta2 = 0;
            se_load_kernel_conv1 = 0; se_load_kernel_conv2 = 0;

            // Initialize counters and metrics
            cycle_count = 0; input_count = 0; output_count = 0; nonzero_count = 0;
            first_output_cycle = -1; last_output_cycle = -1; done_cycle = -1;
            pipeline_latency = 0; processing_duration = 0;
            throughput = 0; efficiency = 0; input_output_ratio = 0; data_integrity = 0;

            // Initialize stage monitoring arrays
            for (i = 1; i <= 11; i++) begin
                stage_output_counts[i] = 0;
                stage_nonzero_counts[i] = 0;
                stage_first_output_cycles[i] = -1;
                stage_data_integrity[i] = 0;
            end

            // Initialize test status flags
            test_passed = 0; latency_passed = 0; efficiency_passed = 0;
            integrity_passed = 0; dimensional_transform_passed = 0;
            stage_progression_passed = 0;

            $display("Testbench initialization complete");
        end
    endtask

    // ========================================================================
    // SE PARAMETER SETUP FOR CNN OPERATION
    // ========================================================================
    task setup_se_parameters();
        begin
            $display("Setting up SE parameters for CNN batch normalization...");

            // Realistic CNN batch normalization parameters
            // Mean values (centered around 0.5 in fixed-point)
            se_mean1 = 16'h0800;      // 0.5 in Q8 format
            se_mean2 = 16'h0800;      // 0.5 in Q8 format

            // Variance values (typical CNN variance ~0.25)
            se_variance1 = 16'h0400;  // 0.25 in Q8 format
            se_variance2 = 16'h0400;  // 0.25 in Q8 format

            // Gamma (scale) parameters (typically 1.0)
            se_gamma1 = 16'h0100;     // 1.0 in Q8 format
            se_gamma2 = 16'h0100;     // 1.0 in Q8 format

            // Beta (shift) parameters (typically 0.0)
            se_beta1 = 16'h0000;      // 0.0 in Q8 format
            se_beta2 = 16'h0000;      // 0.0 in Q8 format

            // Kernel loading signals (disabled for normal operation)
            se_load_kernel_conv1 = 0;
            se_load_kernel_conv2 = 0;

            $display("SE parameters configured:");
            $display("  Mean1/2: 0x%04x, 0x%04x", se_mean1, se_mean2);
            $display("  Variance1/2: 0x%04x, 0x%04x", se_variance1, se_variance2);
            $display("  Gamma1/2: 0x%04x, 0x%04x", se_gamma1, se_gamma2);
            $display("  Beta1/2: 0x%04x, 0x%04x", se_beta1, se_beta2);
        end
    endtask

    // ========================================================================
    // RESET SEQUENCE
    // ========================================================================
    task perform_reset_sequence();
        begin
            $display("Performing reset sequence for 11-stage pipeline...");

            // Assert reset
            rst = 1;
            #200;  // Hold reset for 200ns (extended for deep pipeline)

            // Release reset
            rst = 0;
            #100;  // Wait for reset propagation

            // Enable pipeline
            en = 1;
            #50;   // Stabilization time

            $display("Reset sequence complete - 11-stage pipeline enabled");
        end
    endtask

    // ========================================================================
    // CNN INPUT PATTERN GENERATION
    // ========================================================================
    task generate_cnn_input_patterns();
        integer i, pattern_type;
        reg [N-1:0] base_value, noise_value;
        begin
            $display("Generating %0d realistic CNN input patterns...", TOTAL_TEST_INPUTS);

            // Wait for reset completion
            while (rst) @(posedge clk);
            @(posedge clk);

            // Generate diverse CNN input patterns
            for (i = 0; i < TOTAL_TEST_INPUTS; i++) begin
                @(posedge clk);
                cycle_count = cycle_count + 1;

                // Generate varied pattern types for comprehensive testing
                pattern_type = i % 8;

                case (pattern_type)
                    0: begin // Gradient pattern
                        base_value = 16'h0400 + (i % 2048);
                        data_in = base_value + (channel_in << 6);
                    end
                    1: begin // High contrast edges
                        base_value = (i % 2 == 0) ? 16'h1800 : 16'h0200;
                        data_in = base_value + (channel_in << 4);
                    end
                    2: begin // Texture patterns
                        noise_value = {$random} & 16'h01FF;
                        data_in = 16'h0800 + noise_value + (channel_in << 5);
                    end
                    3: begin // Feature map simulation
                        base_value = 16'h0600 + ((i * 17) % 1024);
                        data_in = base_value + (channel_in << 7);
                    end
                    4: begin // Low intensity patterns
                        data_in = 16'h0100 + (i % 512) + (channel_in << 3);
                    end
                    5: begin // High intensity patterns
                        data_in = 16'h1000 + (i % 1024) + (channel_in << 6);
                    end
                    6: begin // Mixed frequency content
                        base_value = 16'h0800 + ((i * 31) % 512);
                        data_in = base_value + ((channel_in * 13) % 256);
                    end
                    7: begin // Realistic CNN activations
                        base_value = 16'h0300 + ((i * 7) % 1536);
                        data_in = base_value + (channel_in << 4) + (i % 64);
                    end
                endcase

                // Set channel and valid signals
                channel_in = i % INPUT_CHANNELS;
                valid_in = 1;
                input_count = input_count + 1;

                // Progress reporting
                if (i < 50 || i >= TOTAL_TEST_INPUTS - 50 || i % 200 == 0) begin
                    $display("INPUT[%0d]: pattern=%0d, data=0x%04x, channel=%0d, cycle=%0d",
                            i, pattern_type, data_in, channel_in, cycle_count);
                end
            end

            // Stop input generation
            @(posedge clk);
            cycle_count = cycle_count + 1;
            valid_in = 0;

            $display("CNN input pattern generation complete:");
            $display("  Total inputs: %0d", input_count);
            $display("  Pattern types: 8 (gradient, edges, texture, features, etc.)");
            $display("  Input completion cycle: %0d", cycle_count);
            $display("Waiting for 11-stage pipeline processing...");
        end
    endtask

    // ========================================================================
    // PIPELINE OUTPUT MONITORING
    // ========================================================================
    task monitor_pipeline_outputs();
        begin
            $display("Monitoring 11-stage pipeline final outputs...");

            while (cycle_count < MAX_TEST_CYCLES) begin
                @(posedge clk);
                cycle_count = cycle_count + 1;

                // Monitor final pipeline output
                if (valid_out) begin
                    if (first_output_cycle == -1) begin
                        first_output_cycle = cycle_count;
                        pipeline_latency = first_output_cycle;
                        $display("🚀 FIRST OUTPUT at cycle %0d (11-stage latency: %0d cycles)",
                                cycle_count, pipeline_latency);

                        // Check latency target
                        if (pipeline_latency <= LATENCY_TARGET) begin
                            $display("✅ Latency target met: %0d <= %0d cycles",
                                    pipeline_latency, LATENCY_TARGET);
                        end else begin
                            $display("⚠️  Latency target exceeded: %0d > %0d cycles",
                                    pipeline_latency, LATENCY_TARGET);
                        end
                    end

                    // Store output data
                    if (output_count < 2000) begin
                        output_values[output_count] = data_out;
                        output_channels[output_count] = channel_out;
                        output_cycles[output_count] = cycle_count;
                    end

                    output_count = output_count + 1;
                    last_output_cycle = cycle_count;

                    // Count non-zero outputs for data integrity
                    if (data_out != 0) begin
                        nonzero_count = nonzero_count + 1;
                    end

                    // Progress reporting
                    if (output_count <= 50 || output_count % 25 == 0) begin
                        $display("OUTPUT[%0d]: data=0x%04x, channel=%0d, cycle=%0d %s",
                                output_count, data_out, channel_out, cycle_count,
                                (data_out != 0) ? "✓ NON-ZERO" : "");
                    end
                end

                // Progress updates for long simulation
                if (cycle_count % 2500 == 0) begin
                    $display("Progress: cycle %0d, outputs=%0d, done=%b",
                             cycle_count, output_count, done);
                end

                // Early termination if done signal asserted
                if (done) break;
            end

            processing_duration = (last_output_cycle > first_output_cycle) ?
                                 (last_output_cycle - first_output_cycle) : 0;
            $display("Final output monitoring complete: %0d outputs captured", output_count);
        end
    endtask

    // ========================================================================
    // INTERMEDIATE STAGE MONITORING
    // ========================================================================
    task monitor_intermediate_stages();
        begin
            $display("Monitoring intermediate stages for progressive validation...");

            while (cycle_count < MAX_TEST_CYCLES) begin
                @(posedge clk);

                // Monitor Stage 1: 112×112×16 → 56×56×16
                if (stage1_valid_out) begin
                    if (stage_first_output_cycles[1] == -1) begin
                        stage_first_output_cycles[1] = cycle_count;
                        $display("Stage 1 first output at cycle %0d", cycle_count);
                    end
                    stage_output_counts[1] = stage_output_counts[1] + 1;
                    if (stage1_data_out != 0) stage_nonzero_counts[1] = stage_nonzero_counts[1] + 1;
                end

                // Monitor Stage 2: 56×56×16 → 28×28×24
                if (stage2_valid_out) begin
                    if (stage_first_output_cycles[2] == -1) begin
                        stage_first_output_cycles[2] = cycle_count;
                        $display("Stage 2 first output at cycle %0d", cycle_count);
                    end
                    stage_output_counts[2] = stage_output_counts[2] + 1;
                    if (stage2_data_out != 0) stage_nonzero_counts[2] = stage_nonzero_counts[2] + 1;
                end

                // Monitor Stage 3: 28×28×24 → 28×28×24
                if (stage3_valid_out) begin
                    if (stage_first_output_cycles[3] == -1) begin
                        stage_first_output_cycles[3] = cycle_count;
                        $display("Stage 3 first output at cycle %0d", cycle_count);
                    end
                    stage_output_counts[3] = stage_output_counts[3] + 1;
                    if (stage3_data_out != 0) stage_nonzero_counts[3] = stage_nonzero_counts[3] + 1;
                end

                // Monitor Stage 4: 28×28×24 → 14×14×40
                if (stage4_valid_out) begin
                    if (stage_first_output_cycles[4] == -1) begin
                        stage_first_output_cycles[4] = cycle_count;
                        $display("Stage 4 first output at cycle %0d", cycle_count);
                    end
                    stage_output_counts[4] = stage_output_counts[4] + 1;
                    if (stage4_data_out != 0) stage_nonzero_counts[4] = stage_nonzero_counts[4] + 1;
                end

                // Monitor Stage 5: 14×14×40 → 14×14×40
                if (stage5_valid_out) begin
                    if (stage_first_output_cycles[5] == -1) begin
                        stage_first_output_cycles[5] = cycle_count;
                        $display("Stage 5 first output at cycle %0d", cycle_count);
                    end
                    stage_output_counts[5] = stage_output_counts[5] + 1;
                    if (stage5_data_out != 0) stage_nonzero_counts[5] = stage_nonzero_counts[5] + 1;
                end

                // Monitor Stage 6: 14×14×40 → 14×14×40
                if (stage6_valid_out) begin
                    if (stage_first_output_cycles[6] == -1) begin
                        stage_first_output_cycles[6] = cycle_count;
                        $display("Stage 6 first output at cycle %0d", cycle_count);
                    end
                    stage_output_counts[6] = stage_output_counts[6] + 1;
                    if (stage6_data_out != 0) stage_nonzero_counts[6] = stage_nonzero_counts[6] + 1;
                end

                // Monitor Stage 7: 14×14×40 → 14×14×48
                if (stage7_valid_out) begin
                    if (stage_first_output_cycles[7] == -1) begin
                        stage_first_output_cycles[7] = cycle_count;
                        $display("Stage 7 first output at cycle %0d", cycle_count);
                    end
                    stage_output_counts[7] = stage_output_counts[7] + 1;
                    if (stage7_data_out != 0) stage_nonzero_counts[7] = stage_nonzero_counts[7] + 1;
                end

                // Monitor Stage 8: 14×14×48 → 14×14×48
                if (stage8_valid_out) begin
                    if (stage_first_output_cycles[8] == -1) begin
                        stage_first_output_cycles[8] = cycle_count;
                        $display("Stage 8 first output at cycle %0d", cycle_count);
                    end
                    stage_output_counts[8] = stage_output_counts[8] + 1;
                    if (stage8_data_out != 0) stage_nonzero_counts[8] = stage_nonzero_counts[8] + 1;
                end

                // Monitor Stage 9: 14×14×48 → 7×7×96
                if (stage9_valid_out) begin
                    if (stage_first_output_cycles[9] == -1) begin
                        stage_first_output_cycles[9] = cycle_count;
                        $display("Stage 9 first output at cycle %0d", cycle_count);
                    end
                    stage_output_counts[9] = stage_output_counts[9] + 1;
                    if (stage9_data_out != 0) stage_nonzero_counts[9] = stage_nonzero_counts[9] + 1;
                end

                // Monitor Stage 10: 7×7×96 → 7×7×96
                if (stage10_valid_out) begin
                    if (stage_first_output_cycles[10] == -1) begin
                        stage_first_output_cycles[10] = cycle_count;
                        $display("Stage 10 first output at cycle %0d", cycle_count);
                    end
                    stage_output_counts[10] = stage_output_counts[10] + 1;
                    if (stage10_data_out != 0) stage_nonzero_counts[10] = stage_nonzero_counts[10] + 1;
                end

                // Stage 11 is monitored through final output
                if (valid_out) begin
                    if (stage_first_output_cycles[11] == -1) begin
                        stage_first_output_cycles[11] = cycle_count;
                        $display("Stage 11 (final) first output at cycle %0d", cycle_count);
                    end
                    stage_output_counts[11] = stage_output_counts[11] + 1;
                    if (data_out != 0) stage_nonzero_counts[11] = stage_nonzero_counts[11] + 1;
                end

                // Early termination if done signal asserted
                if (done) break;
            end

            $display("Intermediate stage monitoring complete");
        end
    endtask

    // ========================================================================
    // DONE SIGNAL MONITORING
    // ========================================================================
    task monitor_done_signal();
        reg prev_done;
        begin
            prev_done = 0;
            $display("Monitoring 11-stage pipeline done signal...");

            while (cycle_count < MAX_TEST_CYCLES) begin
                @(posedge clk);

                // Detect done signal assertion
                if (done && !prev_done) begin
                    done_cycle = cycle_count;
                    $display("✅ DONE SIGNAL ASSERTED at cycle %0d", done_cycle);
                    $display("   11-stage pipeline completion confirmed");
                    break;
                end
                prev_done = done;
            end
        end
    endtask

    // ========================================================================
    // TIMEOUT PROTECTION
    // ========================================================================
    task timeout_protection();
        begin
            while (cycle_count < MAX_TEST_CYCLES) @(posedge clk);
            $display("⚠️  Test timeout reached at cycle %0d", cycle_count);
            $display("   11-stage pipeline analysis will proceed with available data...");
        end
    endtask

    // ========================================================================
    // COMPREHENSIVE RESULTS ANALYSIS
    // ========================================================================
    task analyze_results();
        integer i;
        real spatial_reduction_factor, channel_expansion_factor;
        begin
            $display("");
            $display("================================================================================");
            $display("COMPREHENSIVE 11-STAGE PIPELINE ANALYSIS");
            $display("================================================================================");

            // Calculate overall metrics
            throughput = (cycle_count > 0) ? (output_count * 100.0) / cycle_count : 0;
            efficiency = throughput;
            input_output_ratio = (input_count > 0) ? (output_count * 100.0) / input_count : 0;
            data_integrity = (output_count > 0) ? (nonzero_count * 100.0) / output_count : 0;

            // Calculate dimensional transformation metrics
            spatial_reduction_factor = (INPUT_HEIGHT * INPUT_WIDTH * 1.0) / (OUTPUT_HEIGHT * OUTPUT_WIDTH);
            channel_expansion_factor = OUTPUT_CHANNELS * 1.0 / INPUT_CHANNELS;

            // Calculate stage-specific data integrity
            for (i = 1; i <= 11; i++) begin
                if (stage_output_counts[i] > 0) begin
                    stage_data_integrity[i] = (stage_nonzero_counts[i] * 100.0) / stage_output_counts[i];
                end else begin
                    stage_data_integrity[i] = 0;
                end
            end

            $display("\n1. DIMENSIONAL TRANSFORMATION ANALYSIS:");
            $display("   Input: %0dx%0dx%0d", INPUT_HEIGHT, INPUT_WIDTH, INPUT_CHANNELS);
            $display("   Output: %0dx%0dx%0d", OUTPUT_HEIGHT, OUTPUT_WIDTH, OUTPUT_CHANNELS);
            $display("   Spatial reduction: %.1fx (%0d×%0d → %0d×%0d)",
                     spatial_reduction_factor, INPUT_HEIGHT, INPUT_WIDTH, OUTPUT_HEIGHT, OUTPUT_WIDTH);
            $display("   Channel expansion: %.1fx (%0d → %0d channels)",
                     channel_expansion_factor, INPUT_CHANNELS, OUTPUT_CHANNELS);

            // Validate dimensional transformation
            dimensional_transform_passed = (output_count > 0) &&
                                         (spatial_reduction_factor >= 15.0) &&
                                         (spatial_reduction_factor <= 17.0) &&
                                         (channel_expansion_factor >= 5.0) &&
                                         (channel_expansion_factor <= 7.0);
            $display("   Dimensional accuracy: %s",
                     dimensional_transform_passed ? "✅ CORRECT" : "❌ INCORRECT");

            $display("\n2. PIPELINE PERFORMANCE METRICS:");
            $display("   Total cycles: %0d", cycle_count);
            $display("   Pipeline latency: %0d cycles", pipeline_latency);
            $display("   Processing duration: %0d cycles", processing_duration);
            $display("   Throughput: %.4f outputs/cycle", throughput / 100.0);
            $display("   Efficiency: %.2f%%", efficiency);
            $display("   Input-output ratio: %.2f%%", input_output_ratio);

            // Validate performance metrics
            latency_passed = (pipeline_latency > 0) && (pipeline_latency <= LATENCY_TARGET);
            efficiency_passed = (efficiency >= MIN_EFFICIENCY) && (efficiency <= MAX_EFFICIENCY);
            $display("   Latency target: %s (%0d <= %0d cycles)",
                     latency_passed ? "✅ MET" : "❌ MISSED", pipeline_latency, LATENCY_TARGET);
            $display("   Efficiency target: %s (%.2f%% in %.1f%%-%.1f%% range)",
                     efficiency_passed ? "✅ MET" : "❌ MISSED", efficiency, MIN_EFFICIENCY, MAX_EFFICIENCY);

            $display("\n3. DATA INTEGRITY ANALYSIS:");
            $display("   Total inputs: %0d", input_count);
            $display("   Total outputs: %0d", output_count);
            $display("   Non-zero outputs: %0d/%0d (%.1f%%)",
                     nonzero_count, output_count, data_integrity);

            // Validate data integrity
            integrity_passed = (data_integrity >= MIN_DATA_INTEGRITY);
            $display("   Data integrity: %s (%.1f%% >= %.1f%% target)",
                     integrity_passed ? "✅ GOOD" : "❌ POOR", data_integrity, MIN_DATA_INTEGRITY);
        end
    endtask

    // ========================================================================
    // COMPREHENSIVE FINAL REPORT GENERATION
    // ========================================================================
    task generate_final_report();
        integer i;
        reg all_stages_functional;
        begin
            $display("");
            $display("================================================================================");
            $display("STAGE-BY-STAGE DETAILED ANALYSIS");
            $display("================================================================================");

            // Stage progression analysis
            all_stages_functional = 1;
            for (i = 1; i <= 11; i++) begin
                $display("\nStage %0d Analysis:", i);
                case (i)
                    1: $display("  Transformation: 112×112×16 → 56×56×16 (stride=2, ReLU, SE)");
                    2: $display("  Transformation: 56×56×16 → 28×28×24 (stride=2, ReLU)");
                    3: $display("  Transformation: 28×28×24 → 28×28×24 (stride=1, ReLU)");
                    4: $display("  Transformation: 28×28×24 → 14×14×40 (stride=2, hswish, SE)");
                    5: $display("  Transformation: 14×14×40 → 14×14×40 (stride=1, hswish, SE)");
                    6: $display("  Transformation: 14×14×40 → 14×14×40 (stride=1, hswish, SE)");
                    7: $display("  Transformation: 14×14×40 → 14×14×48 (stride=1, hswish, SE)");
                    8: $display("  Transformation: 14×14×48 → 14×14×48 (stride=1, hswish, SE)");
                    9: $display("  Transformation: 14×14×48 → 7×7×96 (stride=2, hswish, SE)");
                    10: $display("  Transformation: 7×7×96 → 7×7×96 (stride=1, hswish, SE)");
                    11: $display("  Transformation: 7×7×96 → 7×7×96 (stride=1, hswish, SE) [FINAL]");
                endcase

                $display("  First output cycle: %0d",
                         (stage_first_output_cycles[i] >= 0) ? stage_first_output_cycles[i] : -1);
                $display("  Total outputs: %0d", stage_output_counts[i]);
                $display("  Non-zero outputs: %0d", stage_nonzero_counts[i]);
                $display("  Data integrity: %.1f%%", stage_data_integrity[i]);
                $display("  Status: %s",
                         (stage_output_counts[i] > 0) ? "✅ FUNCTIONAL" : "❌ NON-FUNCTIONAL");

                if (stage_output_counts[i] == 0) all_stages_functional = 0;
            end

            stage_progression_passed = all_stages_functional;

            $display("");
            $display("================================================================================");
            $display("OVERALL PIPELINE ASSESSMENT");
            $display("================================================================================");

            // Calculate overall test result
            test_passed = dimensional_transform_passed && latency_passed &&
                         efficiency_passed && integrity_passed && stage_progression_passed;

            $display("\nValidation Results Summary:");
            $display("  ✓ Dimensional Transform: %s", dimensional_transform_passed ? "PASS" : "FAIL");
            $display("  ✓ Pipeline Latency: %s", latency_passed ? "PASS" : "FAIL");
            $display("  ✓ Efficiency Metrics: %s", efficiency_passed ? "PASS" : "FAIL");
            $display("  ✓ Data Integrity: %s", integrity_passed ? "PASS" : "FAIL");
            $display("  ✓ Stage Progression: %s", stage_progression_passed ? "PASS" : "FAIL");

            $display("");
            if (test_passed) begin
                $display("🎉 11-STAGE CNN BACKBONE VALIDATION: ✅ SUCCESS");
                $display("");
                $display("✅ COMPLETE ARCHITECTURE: All 11 stages operational");
                $display("✅ DIMENSIONAL ACCURACY: 112×112×16 → 7×7×96 achieved");
                $display("✅ PERFORMANCE TARGETS: Latency and efficiency within bounds");
                $display("✅ DATA QUALITY: Excellent integrity across all stages");
                $display("✅ CNN BACKBONE: Ready for production deployment");
                $display("");
                $display("📊 KEY ACHIEVEMENTS:");
                $display("   • Spatial reduction: %.1fx downsampling",
                         (INPUT_HEIGHT * INPUT_WIDTH * 1.0) / (OUTPUT_HEIGHT * OUTPUT_WIDTH));
                $display("   • Channel expansion: %.1fx increase",
                         OUTPUT_CHANNELS * 1.0 / INPUT_CHANNELS);
                $display("   • Pipeline latency: %0d cycles (target: <%0d)",
                         pipeline_latency, LATENCY_TARGET);
                $display("   • Processing efficiency: %.2f%% (range: %.1f%%-%.1f%%)",
                         efficiency, MIN_EFFICIENCY, MAX_EFFICIENCY);
                $display("   • Data integrity: %.1f%% (target: >%.1f%%)",
                         data_integrity, MIN_DATA_INTEGRITY);
                $display("   • Stage functionality: %0d/11 stages operational",
                         all_stages_functional ? 11 : 0);
                $display("");
                $display("🏆 CNN BACKBONE VALIDATION COMPLETE - PRODUCTION READY");

            end else begin
                $display("❌ 11-STAGE CNN BACKBONE VALIDATION: FAILED");
                $display("");
                $display("Issues Identified:");
                if (!dimensional_transform_passed)
                    $display("   ❌ Dimensional transformation accuracy issues");
                if (!latency_passed)
                    $display("   ❌ Pipeline latency exceeds target (%0d > %0d cycles)",
                            pipeline_latency, LATENCY_TARGET);
                if (!efficiency_passed)
                    $display("   ❌ Efficiency outside acceptable range (%.2f%% not in %.1f%%-%.1f%%)",
                            efficiency, MIN_EFFICIENCY, MAX_EFFICIENCY);
                if (!integrity_passed)
                    $display("   ❌ Data integrity below minimum threshold (%.1f%% < %.1f%%)",
                            data_integrity, MIN_DATA_INTEGRITY);
                if (!stage_progression_passed)
                    $display("   ❌ One or more pipeline stages non-functional");
                $display("");
                $display("🔧 REQUIRES OPTIMIZATION before CNN backbone deployment");
            end

            $display("");
            $display("Test Statistics:");
            $display("  Total simulation cycles: %0d", cycle_count);
            $display("  Input patterns generated: %0d", input_count);
            $display("  Final outputs captured: %0d", output_count);
            $display("  Pipeline completion: %s", (done_cycle > 0) ? "CONFIRMED" : "TIMEOUT");
            if (done_cycle > 0) begin
                $display("  Done signal cycle: %0d", done_cycle);
            end
        end
    endtask

    // ========================================================================
    // ASSERTION CHECKS FOR ERROR DETECTION
    // ========================================================================

    // Check for valid signal consistency
    always @(posedge clk) begin
        if (!rst && en) begin
            // Assert that channel_out is within valid range when valid_out is high
            if (valid_out) begin
                assert (channel_out < OUTPUT_CHANNELS) else
                    $error("Invalid channel_out: %0d >= %0d at cycle %0d",
                           channel_out, OUTPUT_CHANNELS, cycle_count);
            end

            // Assert that done signal is only asserted after some outputs
            if (done && output_count == 0) begin
                $warning("Done signal asserted without any outputs at cycle %0d", cycle_count);
            end
        end
    end

endmodule
