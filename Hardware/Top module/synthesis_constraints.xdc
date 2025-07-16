# FPGA Synthesis Constraints for Chest X-Ray Classifier
# Optimized for resource-constrained FPGA synthesis

# Clock constraints
create_clock -period 10.000 -name clk [get_ports clk]
set_input_delay -clock clk -min 2.000 [all_inputs]
set_input_delay -clock clk -max 8.000 [all_inputs]
set_output_delay -clock clk -min 2.000 [all_outputs]
set_output_delay -clock clk -max 8.000 [all_outputs]

# Resource optimization directives
set_property RAM_STYLE BLOCK [get_cells -hier -filter {NAME =~ "*weight_memory*"}]
set_property RAM_STYLE DISTRIBUTED [get_cells -hier -filter {NAME =~ "*bias_memory*"}]
set_property RAM_STYLE DISTRIBUTED [get_cells -hier -filter {NAME =~ "*gamma_mem*"}]
set_property RAM_STYLE DISTRIBUTED [get_cells -hier -filter {NAME =~ "*beta_mem*"}]

# DSP48 optimization
set_property USE_DSP48 YES [get_cells -hier -filter {NAME =~ "*mult*"}]
set_property USE_DSP48 YES [get_cells -hier -filter {NAME =~ "*mac*"}]

# Timing optimization
set_max_delay 10.0 -from [all_inputs] -to [all_outputs]
set_multicycle_path -setup 2 -from [get_pins -hier -filter {NAME =~ "*/*reg*/C}] -to [get_pins -hier -filter {NAME =~ "*/*reg*/D}]

# Resource utilization constraints
set_property MAX_FANOUT 50 [get_nets -hier]

# Synthesis strategy
set_property STRATEGY Performance_Explore [get_runs synth_1]
set_property STRATEGY Performance_ExplorePostRoutePhysOpt [get_runs impl_1]

# Power optimization
set_property POWER_OPT_DESIGN true [current_design]

# Area optimization for small FPGAs
set_property SEVERITY {Warning} [get_drc_checks NSTD-1]
set_property SEVERITY {Warning} [get_drc_checks UCIO-1]

# Synthesis Constraints for Chest X-Ray Classifier
# Prevent optimization of key modules to ensure they appear in utilization report

# Set synthesis strategy to preserve hierarchy
set_property STEPS.SYNTH_DESIGN.ARGS.FLATTEN_HIERARCHY none [get_runs synth_1]

# Keep main module instances
set_property DONT_TOUCH true [get_cells accelerator_inst]
set_property DONT_TOUCH true [get_cells bottleneck_inst]
set_property DONT_TOUCH true [get_cells final_layer_inst]
set_property DONT_TOUCH true [get_cells adapter_inst]
set_property DONT_TOUCH true [get_cells dsp_mgr_inst]
set_property DONT_TOUCH true [get_cells weight_mgr_inst]

# CRITICAL: Bottleneck-specific constraints to prevent optimization
set_property DONT_TOUCH true [get_cells bottleneck_inst]
set_property KEEP_HIERARCHY true [get_cells bottleneck_inst]
set_property DONT_TOUCH true [get_cells bottleneck_inst/*]
set_property KEEP_HIERARCHY true [get_cells bottleneck_inst/*]

# Force keep all bottleneck stage instances
set_property DONT_TOUCH true [get_cells bottleneck_inst/stage*]
set_property KEEP_HIERARCHY true [get_cells bottleneck_inst/stage*]
set_property DONT_TOUCH true [get_cells bottleneck_inst/stage*/bottleneck_core]
set_property DONT_TOUCH true [get_cells bottleneck_inst/stage*/gen_se_module.*]
set_property DONT_TOUCH true [get_cells bottleneck_inst/stage*/gen_shortcut_module.*]

# Keep critical inter-module signals
set_property KEEP true [get_nets bn_en]
set_property KEEP true [get_nets final_en]
set_property KEEP true [get_nets system_enable]
set_property KEEP true [get_nets acc_done]
set_property KEEP true [get_nets bn_done]
set_property KEEP true [get_nets final_valid_out]
set_property KEEP true [get_nets system_done]
set_property KEEP true [get_nets synthesis_prevent_optimization]

# CRITICAL: Force keep bottleneck signals
set_property KEEP true [get_nets bn_data_out]
set_property KEEP true [get_nets bn_valid_out]
set_property KEEP true [get_nets bn_channel_out]
set_property KEEP true [get_nets bn_data_in_wire]
set_property KEEP true [get_nets bn_valid_in_wire]
set_property KEEP true [get_nets bn_channel_in_wire]
set_property KEEP true [get_nets bottleneck_output_register*]
set_property KEEP true [get_nets bottleneck_activity_flag]
set_property KEEP true [get_nets bottleneck_test_data*]
set_property KEEP true [get_nets bottleneck_test_channel*]
set_property KEEP true [get_nets bottleneck_test_valid]
set_property KEEP true [get_nets bottleneck_test_counter*]

# Force keep debug outputs
set_property KEEP true [get_nets debug_bn_data_out]
set_property KEEP true [get_nets debug_bn_valid_out]
set_property KEEP true [get_nets debug_bn_done]
set_property KEEP true [get_nets debug_bn_channel_out]

# Keep all bottleneck stage outputs
set_property KEEP true [get_nets bottleneck_inst/stage*/data_out]
set_property KEEP true [get_nets bottleneck_inst/stage*/valid_out]
set_property KEEP true [get_nets bottleneck_inst/stage*/done]

# Keep final layer sub-module outputs
set_property KEEP true [get_nets final_layer_inst/*/data_out]
set_property KEEP true [get_nets final_layer_inst/*/valid_out]

# Preserve module hierarchy in synthesis
set_property KEEP_HIERARCHY true [get_cells accelerator_inst]
set_property KEEP_HIERARCHY true [get_cells bottleneck_inst]
set_property KEEP_HIERARCHY true [get_cells final_layer_inst]
set_property KEEP_HIERARCHY true [get_cells adapter_inst]

# Disable aggressive optimization
set_property STEPS.SYNTH_DESIGN.ARGS.RESOURCE_SHARING off [get_runs synth_1]
set_property STEPS.SYNTH_DESIGN.ARGS.SHREG_MIN_SIZE 5 [get_runs synth_1]

# Force synthesis to retain all instantiated modules
set_property STEPS.SYNTH_DESIGN.ARGS.KEEP_EQUIVALENT_REGISTERS true [get_runs synth_1]

# CRITICAL: Final layer optimization constraints
set_property DONT_TOUCH true [get_cells final_layer_inst]
set_property KEEP_HIERARCHY true [get_cells final_layer_inst]

# Force final layer weight arrays into BRAM
set_property RAM_STYLE BLOCK [get_cells -hierarchical -filter {NAME =~ "*final_layer_inst*pw_conv_weights*"}]
set_property RAM_STYLE DISTRIBUTED [get_cells -hierarchical -filter {NAME =~ "*final_layer_inst*bn1_gamma*"}]
set_property RAM_STYLE DISTRIBUTED [get_cells -hierarchical -filter {NAME =~ "*final_layer_inst*bn1_beta*"}]
set_property RAM_STYLE DISTRIBUTED [get_cells -hierarchical -filter {NAME =~ "*final_layer_inst*linear1_biases*"}]
set_property RAM_STYLE DISTRIBUTED [get_cells -hierarchical -filter {NAME =~ "*final_layer_inst*bn2_gamma*"}]
set_property RAM_STYLE DISTRIBUTED [get_cells -hierarchical -filter {NAME =~ "*final_layer_inst*bn2_beta*"}]
set_property RAM_STYLE DISTRIBUTED [get_cells -hierarchical -filter {NAME =~ "*final_layer_inst*linear2_biases*"}]

# Force DSP48 usage for multiplications in final layer
set_property USE_DSP48 yes [get_cells -hierarchical -filter {NAME =~ "*final_layer_inst*"}]

# Optimize final layer sub-modules
set_property DONT_TOUCH true [get_cells final_layer_inst/pw_conv_inst]
set_property DONT_TOUCH true [get_cells final_layer_inst/bn1_inst]
set_property DONT_TOUCH true [get_cells final_layer_inst/hswish1_inst]
set_property DONT_TOUCH true [get_cells final_layer_inst/linear1_inst]
set_property DONT_TOUCH true [get_cells final_layer_inst/bn2_inst]
set_property DONT_TOUCH true [get_cells final_layer_inst/hswish2_inst]
set_property DONT_TOUCH true [get_cells final_layer_inst/linear2_inst]

# Force efficient packing
set_property MAX_FANOUT 50 [get_nets -hierarchical -filter {NAME =~ "*final_layer_inst*"}]
set_property KEEP true [get_nets -hierarchical -filter {NAME =~ "*final_layer_inst*data_out*"}]
set_property KEEP true [get_nets -hierarchical -filter {NAME =~ "*final_layer_inst*valid_out*"}]

# AGGRESSIVE: Final layer resource optimization
set_property STEPS.SYNTH_DESIGN.ARGS.DIRECTIVE AreaOptimized_medium [get_runs synth_1]
set_property STEPS.SYNTH_DESIGN.ARGS.RESOURCE_SHARING on [get_runs synth_1]
set_property STEPS.SYNTH_DESIGN.ARGS.SHREG_MIN_SIZE 3 [get_runs synth_1]

# Force final layer to use minimum resources
set_property SLICE_LUT_PACK dense [get_cells -hierarchical -filter {NAME =~ "*final_layer_inst*"}]
set_property IOB false [get_ports -filter {NAME =~ "*final_layer*"}]

# Control final layer register packing
set_property REGISTER_BALANCING on [get_cells -hierarchical -filter {NAME =~ "*final_layer_inst*"}]
set_property REGISTER_DUPLICATION off [get_cells -hierarchical -filter {NAME =~ "*final_layer_inst*"}] 