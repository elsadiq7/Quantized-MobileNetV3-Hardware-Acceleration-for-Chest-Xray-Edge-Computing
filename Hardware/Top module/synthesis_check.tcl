# ============================================================================
# Synthesis Check Script for Chest X-Ray Classifier FPGA Implementation
# Verifies fixes for synthesizability issues identified in design review
# ============================================================================

# Set target device
set_part xc7z020clg484-2

# Create project
create_project -force chest_xray_synthesis_check ./synthesis_check -part xc7z020clg484-2

# Add source files
add_files -norecurse {
    chest_xray_classifier_top.sv
    interface_adapter.sv
    weight_memory_manager.sv
    dsp_resource_manager.sv
    external_memory_controller.sv
    timing_optimized_modules.sv
    simplified_state_machine.sv
}

# Add First Layer files
add_files -norecurse {
    "First Layer/accelerator.sv"
    "First Layer/convolver.sv"
    "First Layer/batchnorm_top.sv"
    "First Layer/HSwish.sv"
}

# Add BottleNeck Layer files
add_files -norecurse {
    "BottleNeck layer/BottleNeck_11stage.sv"
    "BottleNeck layer/BottleNeck_const_func.sv"
    "BottleNeck layer/depthwise_conv_simple.sv"
    "BottleNeck layer/pointwise_conv_debug.sv"
}

# Add Final Layer files
add_files -norecurse {
    "Final layer/final_layer_top.sv"
    "Final layer/linear.sv"
    "Final layer/pointwise_conv.sv"
    "Final layer/batchnorm1d.sv"
}

# Add constraint file
add_files -fileset constrs_1 -norecurse chest_xray_classifier_constraints.xdc

# Set top module
set_property top chest_xray_classifier_top [current_fileset]

# Configure synthesis settings for thorough checking
set_property strategy "Vivado Synthesis Defaults" [get_runs synth_1]
set_property STEPS.SYNTH_DESIGN.ARGS.FLATTEN_HIERARCHY "rebuilt" [get_runs synth_1]
set_property STEPS.SYNTH_DESIGN.ARGS.GATED_CLOCK_CONVERSION "off" [get_runs synth_1]
set_property STEPS.SYNTH_DESIGN.ARGS.BUFG "12" [get_runs synth_1]
set_property STEPS.SYNTH_DESIGN.ARGS.FANOUT_LIMIT "400" [get_runs synth_1]
set_property STEPS.SYNTH_DESIGN.ARGS.DIRECTIVE "RuntimeOptimized" [get_runs synth_1]
set_property STEPS.SYNTH_DESIGN.ARGS.CONTROL_SET_OPT_THRESHOLD "16" [get_runs synth_1]

# Enable comprehensive error checking
set_property STEPS.SYNTH_DESIGN.ARGS.ASSERT "true" [get_runs synth_1]
set_property STEPS.SYNTH_DESIGN.ARGS.NO_LC "false" [get_runs synth_1]

# Run synthesis with error checking
puts "Starting synthesis with comprehensive error checking..."
launch_runs synth_1 -jobs 4
wait_on_run synth_1

# Check synthesis results
if {[get_property PROGRESS [get_runs synth_1]] != "100%"} {
    puts "ERROR: Synthesis failed!"
    puts "Check synthesis log for errors:"
    puts [get_property STATUS [get_runs synth_1]]
    exit 1
} else {
    puts "SUCCESS: Synthesis completed successfully!"
}

# Generate detailed reports
open_run synth_1 -name synth_1

# Utilization report
report_utilization -file synthesis_check_utilization.rpt -name utilization_1
puts "Utilization report generated: synthesis_check_utilization.rpt"

# Timing summary (preliminary)
report_timing_summary -delay_type min_max -report_unconstrained -check_timing_verbose -max_paths 10 -input_pins -routable_nets -file synthesis_check_timing.rpt
puts "Timing report generated: synthesis_check_timing.rpt"

# Check for critical warnings and errors
set critical_warnings [get_msg_config -count -severity "CRITICAL WARNING"]
set errors [get_msg_config -count -severity "ERROR"]

puts "=== SYNTHESIS CHECK SUMMARY ==="
puts "Critical Warnings: $critical_warnings"
puts "Errors: $errors"

if {$errors > 0} {
    puts "ERROR: Synthesis completed with errors!"
    exit 1
} elseif {$critical_warnings > 5} {
    puts "WARNING: High number of critical warnings detected!"
    puts "Review synthesis log for potential issues."
} else {
    puts "SUCCESS: Clean synthesis with minimal warnings!"
}

# Resource utilization summary
set lut_util [get_property LUT_AS_LOGIC.USED [get_cells]]
set ff_util [get_property REGISTER.USED [get_cells]]
set bram_util [get_property RAMB36E1.USED [get_cells]]
set dsp_util [get_property DSP48E1.USED [get_cells]]

puts "=== RESOURCE UTILIZATION ==="
puts "LUTs: $lut_util"
puts "Flip-Flops: $ff_util" 
puts "BRAM: $bram_util"
puts "DSP48: $dsp_util"

# Check for synthesis optimizations
puts "=== SYNTHESIS OPTIMIZATIONS ==="
puts "Checking for proper resource inference..."

# Check DSP inference
set dsp_cells [get_cells -hierarchical -filter {REF_NAME =~ "*DSP48E1*"}]
if {[llength $dsp_cells] > 0} {
    puts "SUCCESS: DSP48 slices properly inferred: [llength $dsp_cells]"
} else {
    puts "WARNING: No DSP48 slices found - check multiplier inference"
}

# Check BRAM inference  
set bram_cells [get_cells -hierarchical -filter {REF_NAME =~ "*RAMB*"}]
if {[llength $bram_cells] > 0} {
    puts "SUCCESS: Block RAM properly inferred: [llength $bram_cells]"
} else {
    puts "INFO: No Block RAM inferred - using distributed RAM"
}

# Check for proper clock gating
set clock_gates [get_cells -hierarchical -filter {REF_NAME =~ "*BUFGCE*"}]
puts "Clock gating cells: [llength $clock_gates]"

puts "=== SYNTHESIS CHECK COMPLETE ==="
puts "Review generated reports for detailed analysis:"
puts "  - synthesis_check_utilization.rpt"
puts "  - synthesis_check_timing.rpt"

# Close project
close_project
