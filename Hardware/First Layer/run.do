# Create the work library
vlib work

# Compile the design files with SystemVerilog support
vlog -sv *.sv

# Start a simulation
vsim -voptargs="+acc" work.accelerator_tb

# Save all signals to the wave
add wave -r /*

# Run the simulation with extended time limit
run -all

# Exit Questa Sim
quit
