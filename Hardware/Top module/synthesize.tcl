# Vivado Synthesis Script for Chest X-Ray Classifier
# Optimized for FPGA synthesis with resource constraints

# Create project (adjust path as needed)
create_project chest_xray_synth ./synth_project -part xc7z020clg484-1 -force

# SYNTHESIS-ONLY FILES - Exclude all testbench files
# Add source files in correct dependency order

# Timing optimized modules first
add_files -norecurse timing_optimized_modules.sv
add_files -norecurse dsp_resource_manager.sv

# BottleNeck modules (core functionality only)
add_files -norecurse bneck/HSwish.sv
add_files -norecurse bneck/Relu.sv
add_files -norecurse bneck/batchnorm_debug.sv
add_files -norecurse bneck/pointwise_conv_debug.sv
add_files -norecurse bneck/depthwise_conv_simple.sv
add_files -norecurse bneck/BottleNeck_const_func.sv
add_files -norecurse bneck/SE_module.sv
add_files -norecurse bneck/BatchNorm_se.sv
add_files -norecurse bneck/ReLU_se.sv
add_files -norecurse bneck/HardSwishSigmoid.sv
add_files -norecurse bneck/Conv2D.sv
add_files -norecurse bneck/AdaptiveAvgPool2d_1x1.sv
add_files -norecurse bneck/BottleNeck_11Stage_Sequential_Optimized.sv

# First layer modules
add_files -norecurse "First Layer/HSwish.sv"
add_files -norecurse "First Layer/Relu6.sv"
add_files -norecurse "First Layer/batchnorm_accumulator.sv"
add_files -norecurse "First Layer/batchnorm_normalizer.sv"
add_files -norecurse "First Layer/batchnorm_top.sv"
add_files -norecurse "First Layer/convolver.sv"
add_files -norecurse "First Layer/image_handler_send.sv"
add_files -norecurse "First Layer/accelerator.sv"

# Final layer modules
add_files -norecurse "Final layer/hswish.sv"
add_files -norecurse "Final layer/batchnorm.sv"
add_files -norecurse "Final layer/batchnorm1d.sv"
add_files -norecurse "Final layer/pointwise_conv.sv"
add_files -norecurse "Final layer/linear.sv"
add_files -norecurse "Final layer/linear_external_weights.sv"
add_files -norecurse "Final layer/final_layer_top.sv"

# Memory and system modules (add these last due to dependencies)
add_files -norecurse external_memory_controller.sv
add_files -norecurse weight_memory_manager.sv
add_files -norecurse interface_adapter.sv

# Top module (must be last)
add_files -norecurse chest_xray_classifier_top.sv

# Add constraints
add_files -fileset constrs_1 -norecurse synthesis_constraints.xdc

# Set top module
set_property top chest_xray_classifier_top [current_fileset]

# SYNTHESIS OPTIMIZATION SETTINGS
# Enable out-of-context synthesis for better resource utilization
set_property strategy Flow_RuntimeOptimized [get_runs synth_1]
set_property {STEPS.SYNTH_DESIGN.ARGS.MORE OPTIONS} {-mode out_of_context -flatten_hierarchy rebuilt} [get_runs synth_1]

# Enable area optimization for resource-constrained FPGA
set_property {STEPS.SYNTH_DESIGN.ARGS.DIRECTIVE} AreaOptimized_high [get_runs synth_1]

# Set memory synthesis options to avoid unsupported patterns
set_property {STEPS.SYNTH_DESIGN.ARGS.MORE OPTIONS} {-mode out_of_context -flatten_hierarchy rebuilt -ram_style block} [get_runs synth_1]

# Run synthesis
launch_runs synth_1 -jobs 8
wait_on_run synth_1

# Check synthesis results
if {[get_property PROGRESS [get_runs synth_1]] != "100%"} {
    error "Synthesis failed"
}

# Generate reports
open_run synth_1 -name synth_1
report_utilization -file utilization_synth.rpt
report_timing -file timing_synth.rpt

puts "Synthesis completed successfully!"
puts "Check utilization_synth.rpt and timing_synth.rpt for results." 