# ModelSim/QuestaSim DO script for Depthwise Convolution Testbench
# 
# This script automates the compilation and simulation process
# Usage: vsim -do run_test.do

# Create work library if it doesn't exist
if {![file exists work]} {
    vlib work
}

# Compile the design files
echo "Compiling RTL files..."
vlog -sv depthwise_conv.sv

echo "Compiling testbench files..."
vlog -sv depthwise_conv_tb.sv

# Check for compilation errors
if {[runStatus] != ""} {
    echo "Compilation failed!"
    quit -f
}

echo "Compilation successful!"

# Load the testbench
vsim -t ps depthwise_conv_tb

# Add key signals to waveform
add wave -divider "Clock and Reset"
add wave -radix binary sim:/depthwise_conv_tb/clk
add wave -radix binary sim:/depthwise_conv_tb/rst
add wave -radix binary sim:/depthwise_conv_tb/en

add wave -divider "Input Interface"
add wave -radix hex sim:/depthwise_conv_tb/data_in
add wave -radix unsigned sim:/depthwise_conv_tb/channel_in
add wave -radix binary sim:/depthwise_conv_tb/valid_in

add wave -divider "Output Interface"
add wave -radix hex sim:/depthwise_conv_tb/data_out
add wave -radix unsigned sim:/depthwise_conv_tb/channel_out
add wave -radix binary sim:/depthwise_conv_tb/valid_out
add wave -radix binary sim:/depthwise_conv_tb/done

add wave -divider "Test Control"
add wave -radix unsigned sim:/depthwise_conv_tb/input_idx
add wave -radix unsigned sim:/depthwise_conv_tb/output_idx
add wave -radix unsigned sim:/depthwise_conv_tb/cycle_count

add wave -divider "DUT Internal State"
add wave -radix ascii sim:/depthwise_conv_tb/dut/state
add wave -radix binary sim:/depthwise_conv_tb/dut/weights_loaded
add wave -radix binary sim:/depthwise_conv_tb/dut/buffer_ready

# Configure wave window
configure wave -namecolwidth 250
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2

# Run simulation
echo "Starting simulation..."
run 50ms

# Check if simulation completed successfully
if {[examine sim:/depthwise_conv_tb/done] == 1} {
    echo "Simulation completed successfully!"
    echo "Output samples captured: [examine -radix unsigned sim:/depthwise_conv_tb/output_idx]"
} else {
    echo "Simulation did not complete within timeout!"
}

# Zoom to fit the waveform
wave zoom full

echo "Simulation finished. Use 'wave zoom full' to view complete waveform."
echo "Check the transcript for detailed test results."
