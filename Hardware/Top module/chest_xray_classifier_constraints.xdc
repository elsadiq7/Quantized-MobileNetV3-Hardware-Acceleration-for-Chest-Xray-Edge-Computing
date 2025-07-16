# ============================================================================
# Chest X-Ray Classifier FPGA Implementation - Timing Constraints
# Target: Zynq-7020 (xc7z020clg484-2)
# ============================================================================

# ============================================================================
# PRIMARY CLOCK CONSTRAINTS
# ============================================================================

# Main system clock - 100 MHz (10ns period)
create_clock -period 10.000 -name sys_clk [get_ports clk]

# DDR4 interface clock - 300 MHz (3.33ns period) 
# Note: Adjust based on actual DDR4 controller implementation
create_clock -period 3.333 -name ddr4_clk [get_ports m_axi_*clk] -add

# ============================================================================
# CLOCK DOMAIN CROSSING CONSTRAINTS
# ============================================================================

# Asynchronous clock groups between system and DDR4 clocks
set_clock_groups -asynchronous \
    -group [get_clocks sys_clk] \
    -group [get_clocks ddr4_clk]

# ============================================================================
# INPUT/OUTPUT TIMING CONSTRAINTS
# ============================================================================

# Input constraints for pixel data
set_input_delay -clock sys_clk -max 2.0 [get_ports pixel_in*]
set_input_delay -clock sys_clk -min 0.5 [get_ports pixel_in*]
set_input_delay -clock sys_clk -max 2.0 [get_ports pixel_valid]
set_input_delay -clock sys_clk -min 0.5 [get_ports pixel_valid]

# Input constraints for control signals
set_input_delay -clock sys_clk -max 2.0 [get_ports rst]
set_input_delay -clock sys_clk -min 0.5 [get_ports rst]
set_input_delay -clock sys_clk -max 2.0 [get_ports en]
set_input_delay -clock sys_clk -min 0.5 [get_ports en]

# Output constraints for classification results
set_output_delay -clock sys_clk -max 2.0 [get_ports classification_result*]
set_output_delay -clock sys_clk -min 0.5 [get_ports classification_result*]
set_output_delay -clock sys_clk -max 2.0 [get_ports classification_valid]
set_output_delay -clock sys_clk -min 0.5 [get_ports classification_valid]
set_output_delay -clock sys_clk -max 2.0 [get_ports processing_done]
set_output_delay -clock sys_clk -min 0.5 [get_ports processing_done]
set_output_delay -clock sys_clk -max 2.0 [get_ports ready_for_image]
set_output_delay -clock sys_clk -min 0.5 [get_ports ready_for_image]

# ============================================================================
# DDR4 AXI4 INTERFACE CONSTRAINTS
# ============================================================================

# AXI4 Read Address Channel
set_output_delay -clock ddr4_clk -max 1.0 [get_ports m_axi_araddr*]
set_output_delay -clock ddr4_clk -min 0.2 [get_ports m_axi_araddr*]
set_output_delay -clock ddr4_clk -max 1.0 [get_ports m_axi_arlen*]
set_output_delay -clock ddr4_clk -min 0.2 [get_ports m_axi_arlen*]
set_output_delay -clock ddr4_clk -max 1.0 [get_ports m_axi_arsize*]
set_output_delay -clock ddr4_clk -min 0.2 [get_ports m_axi_arsize*]
set_output_delay -clock ddr4_clk -max 1.0 [get_ports m_axi_arburst*]
set_output_delay -clock ddr4_clk -min 0.2 [get_ports m_axi_arburst*]
set_output_delay -clock ddr4_clk -max 1.0 [get_ports m_axi_arvalid]
set_output_delay -clock ddr4_clk -min 0.2 [get_ports m_axi_arvalid]

# AXI4 Read Data Channel
set_input_delay -clock ddr4_clk -max 1.0 [get_ports m_axi_arready]
set_input_delay -clock ddr4_clk -min 0.2 [get_ports m_axi_arready]
set_input_delay -clock ddr4_clk -max 1.0 [get_ports m_axi_rdata*]
set_input_delay -clock ddr4_clk -min 0.2 [get_ports m_axi_rdata*]
set_input_delay -clock ddr4_clk -max 1.0 [get_ports m_axi_rresp*]
set_input_delay -clock ddr4_clk -min 0.2 [get_ports m_axi_rresp*]
set_input_delay -clock ddr4_clk -max 1.0 [get_ports m_axi_rlast]
set_input_delay -clock ddr4_clk -min 0.2 [get_ports m_axi_rlast]
set_input_delay -clock ddr4_clk -max 1.0 [get_ports m_axi_rvalid]
set_input_delay -clock ddr4_clk -min 0.2 [get_ports m_axi_rvalid]
set_output_delay -clock ddr4_clk -max 1.0 [get_ports m_axi_rready]
set_output_delay -clock ddr4_clk -min 0.2 [get_ports m_axi_rready]

# ============================================================================
# WEIGHT MEMORY INTERFACE CONSTRAINTS
# ============================================================================

# Weight data interfaces (internal - no external timing requirements)
set_input_delay -clock sys_clk -max 1.0 [get_ports acc_weight_data*]
set_input_delay -clock sys_clk -min 0.2 [get_ports acc_weight_data*]
set_input_delay -clock sys_clk -max 1.0 [get_ports acc_bn_data*]
set_input_delay -clock sys_clk -min 0.2 [get_ports acc_bn_data*]

# ============================================================================
# CRITICAL PATH TIMING CONSTRAINTS
# ============================================================================

# DSP48 pipeline constraints - ensure proper timing for multiply-accumulate
set_multicycle_path -setup 2 -from [get_pins */dsp_mgr_inst/dsp48_inst[*]/dsp48_mac/a_reg*] \
                              -to [get_pins */dsp_mgr_inst/dsp48_inst[*]/dsp48_mac/p_reg*]
set_multicycle_path -hold 1  -from [get_pins */dsp_mgr_inst/dsp48_inst[*]/dsp48_mac/a_reg*] \
                              -to [get_pins */dsp_mgr_inst/dsp48_inst[*]/dsp48_mac/p_reg*]

# Convolution pipeline constraints
set_multicycle_path -setup 3 -from [get_pins */accelerator_inst/convolver_inst/*] \
                              -to [get_pins */accelerator_inst/bn/*]
set_multicycle_path -hold 2  -from [get_pins */accelerator_inst/convolver_inst/*] \
                              -to [get_pins */accelerator_inst/bn/*]

# ============================================================================
# FALSE PATH CONSTRAINTS
# ============================================================================

# Reset signals - asynchronous
set_false_path -from [get_ports rst]

# Debug and status signals (not timing critical)
set_false_path -to [get_pins *debug*]
set_false_path -to [get_pins *status*]

# ============================================================================
# PHYSICAL CONSTRAINTS
# ============================================================================

# DSP48 placement - group DSP slices for better routing
set_property LOC DSP48_X0Y0 [get_cells */dsp_mgr_inst/dsp48_inst[0]/dsp48_mac]
set_property LOC DSP48_X0Y1 [get_cells */dsp_mgr_inst/dsp48_inst[1]/dsp48_mac]
set_property LOC DSP48_X0Y2 [get_cells */dsp_mgr_inst/dsp48_inst[2]/dsp48_mac]
set_property LOC DSP48_X0Y3 [get_cells */dsp_mgr_inst/dsp48_inst[3]/dsp48_mac]

# BRAM placement - distribute across available BRAM columns
set_property LOC RAMB36_X0Y0 [get_cells */weight_mgr_inst/acc_weight_mem_reg]
set_property LOC RAMB36_X1Y0 [get_cells */final_layer_inst/pw_conv_weights_reg]

# ============================================================================
# POWER OPTIMIZATION
# ============================================================================

# Clock enable optimization for power savings
set_property CLOCK_GATING true [get_nets sys_clk]

# ============================================================================
# SYNTHESIS DIRECTIVES
# ============================================================================

# Memory inference directives
set_property RAM_STYLE "block" [get_cells */weight_mgr_inst/*_mem_reg]
set_property RAM_STYLE "distributed" [get_cells */weight_mgr_inst/*_gamma_mem_reg]
set_property RAM_STYLE "distributed" [get_cells */weight_mgr_inst/*_beta_mem_reg]

# DSP inference directives
set_property USE_DSP "yes" [get_cells */dsp_mgr_inst/dsp48_inst[*]/dsp48_mac]

# ============================================================================
# TIMING EXCEPTIONS FOR SPECIFIC PATHS
# ============================================================================

# State machine transitions - allow extra cycle for complex logic
set_multicycle_path -setup 2 -from [get_pins */system_state_reg*] \
                              -to [get_pins */next_system_state*]

# Buffer management - allow relaxed timing for buffer pointers
set_multicycle_path -setup 2 -from [get_pins */adapter_inst/*_buffer_*_ptr_reg*] \
                              -to [get_pins */adapter_inst/*_buffer_*]

# ============================================================================
# REPORT GENERATION
# ============================================================================

# Generate comprehensive timing reports after implementation
set_property STEPS.ROUTE_DESIGN.ARGS.REPORT_TIMING_SUMMARY true [get_runs impl_1]
set_property STEPS.ROUTE_DESIGN.ARGS.REPORT_POWER true [get_runs impl_1]
set_property STEPS.ROUTE_DESIGN.ARGS.REPORT_UTILIZATION true [get_runs impl_1]
