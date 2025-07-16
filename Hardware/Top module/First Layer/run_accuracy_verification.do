# ModelSim do file for Accuracy Verification Testbench
# This file runs the comprehensive accuracy verification testbench

# Set working directory
cd "C:/Users/lenovo/Downloads/First Block/First Block"

# Create work library if it doesn't exist
if {![file exists work]} {
    vlib work
}

# Compile all required modules
vlog -work work accelerator.sv
vlog -work work image_handler_send.sv
vlog -work work convolver.sv
vlog -work work batchnorm_top.sv
vlog -work work batchnorm_accumulator.sv
vlog -work work batchnorm_normalizer.sv
vlog -work work HSwish.sv
vlog -work work Relu6.sv

# Compile the accuracy verification testbench
vlog -work work accuracy_verification_tb.sv

# Start simulation with the accuracy verification testbench
vsim -t ps work.accuracy_verification_tb

# Add waves for comprehensive monitoring
add wave -divider "Clock and Control"
add wave -radix binary /accuracy_verification_tb/clk
add wave -radix binary /accuracy_verification_tb/reset
add wave -radix binary /accuracy_verification_tb/en
add wave -radix binary /accuracy_verification_tb/done

add wave -divider "Input Interface"
add wave -radix hex /accuracy_verification_tb/pixel
add wave -radix binary /accuracy_verification_tb/valid

add wave -divider "Output Interface"
add wave -radix hex /accuracy_verification_tb/data_out
add wave -radix binary /accuracy_verification_tb/valid_out
add wave -radix binary /accuracy_verification_tb/ready_for_data

add wave -divider "DUT Internal Signals"
add wave -radix hex /accuracy_verification_tb/dut/conv_out
add wave -radix unsigned /accuracy_verification_tb/dut/channel_out
add wave -radix binary /accuracy_verification_tb/dut/conv_valid
add wave -radix binary /accuracy_verification_tb/dut/conv_done
add wave -radix hex /accuracy_verification_tb/dut/bn_out
add wave -radix binary /accuracy_verification_tb/dut/bn_valid
add wave -radix hex /accuracy_verification_tb/dut/act_out

add wave -divider "Statistics"
add wave -radix unsigned /accuracy_verification_tb/receivedData
add wave -radix unsigned /accuracy_verification_tb/nonzero_outputs
add wave -radix hex /accuracy_verification_tb/max_value
add wave -radix hex /accuracy_verification_tb/min_value

add wave -divider "Accuracy Metrics"
add wave -radix unsigned /accuracy_verification_tb/exact_matches
add wave -radix unsigned /accuracy_verification_tb/close_matches
add wave -radix unsigned /accuracy_verification_tb/acceptable_matches
add wave -radix unsigned /accuracy_verification_tb/large_errors
add wave -radix unsigned /accuracy_verification_tb/total_errors
add wave -radix decimal /accuracy_verification_tb/mean_error
add wave -radix decimal /accuracy_verification_tb/max_error

add wave -divider "Channel Analysis"
add wave -radix unsigned /accuracy_verification_tb/channel_counts
add wave -radix unsigned /accuracy_verification_tb/channel_errors

# Set wave display options
config wave -signalnamewidth 1
config wave -timelineunits ns

# Run the simulation
run -all

# Display final results
echo "=========================================="
echo "ACCURACY VERIFICATION COMPLETED"
echo "=========================================="
echo "Check the following files for detailed analysis:"
echo "  - accuracy_analysis.txt: Main analysis report"
echo "  - error_details.txt: Detailed error information"
echo "  - statistics.txt: Comprehensive statistics"
echo "  - output_results.txt: Actual accelerator output"
echo "  - output_results.hex: Output in hexadecimal format"
echo "=========================================="

# Keep simulation running to view results
run 1000ns 