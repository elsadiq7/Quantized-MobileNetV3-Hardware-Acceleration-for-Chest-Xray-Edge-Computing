# Makefile for Depthwise Convolution Testbench
# 
# This Makefile automates the compilation and simulation process for the
# depthwise convolution testbench using ModelSim/QuestaSim.
#
# Usage:
#   make all        - Generate data, compile, and run simulation
#   make data       - Generate test data files
#   make compile    - Compile SystemVerilog files
#   make sim        - Run simulation
#   make clean      - Clean generated files
#   make help       - Show this help

# Tool configuration
VLOG = vlog
VSIM = vsim
PYTHON = python3

# File definitions
RTL_FILES = depthwise_conv.sv
TB_FILES = depthwise_conv_tb.sv
DATA_SCRIPT = generate_test_data.py

# Generated files
DATA_FILES = input_data.mem weights.mem simple_input.mem simple_weights.mem
OUTPUT_FILES = output_data.mem
SIM_FILES = work transcript vsim.wlf

# Simulation parameters
TOP_MODULE = depthwise_conv_tb
SIM_TIME = 50ms

# Default target
all: data compile sim

# Generate test data
data: $(DATA_FILES)

$(DATA_FILES): $(DATA_SCRIPT)
	@echo "Generating test data..."
	$(PYTHON) $(DATA_SCRIPT)
	@echo "Test data generation completed."

# Compile SystemVerilog files
compile: work/_info

work/_info: $(RTL_FILES) $(TB_FILES)
	@echo "Compiling SystemVerilog files..."
	$(VLOG) $(RTL_FILES) $(TB_FILES)
	@echo "Compilation completed."

# Run simulation
sim: compile data
	@echo "Running simulation..."
	$(VSIM) -c $(TOP_MODULE) -do "run $(SIM_TIME); quit -f"
	@echo "Simulation completed."

# Run simulation with GUI
sim-gui: compile data
	@echo "Running simulation with GUI..."
	$(VSIM) $(TOP_MODULE) -do "add wave -radix hex sim:/$(TOP_MODULE)/*; run $(SIM_TIME)"

# Run quick simulation with simple test data
sim-simple: compile
	@echo "Running simple test simulation..."
	$(PYTHON) -c "exec(open('$(DATA_SCRIPT)').read()); generate_simple_test_case()"
	$(VSIM) -c $(TOP_MODULE) -do "run 1ms; quit -f"

# Verify output data
verify: $(OUTPUT_FILES)
	@echo "Verifying output data..."
	@if [ -f output_data.mem ]; then \
		echo "Output file generated successfully."; \
		wc -l output_data.mem; \
	else \
		echo "ERROR: Output file not found!"; \
		exit 1; \
	fi

# Clean generated files
clean:
	@echo "Cleaning generated files..."
	rm -rf $(SIM_FILES) $(DATA_FILES) $(OUTPUT_FILES)
	rm -f *.log *.vstf *.wlf
	@echo "Clean completed."

# Clean everything including work directory
clean-all: clean
	rm -rf work

# Show file sizes and statistics
stats:
	@echo "File Statistics:"
	@echo "=================="
	@if [ -f input_data.mem ]; then \
		echo "Input data: $$(wc -l < input_data.mem) lines"; \
	fi
	@if [ -f weights.mem ]; then \
		echo "Weights: $$(wc -l < weights.mem) lines"; \
	fi
	@if [ -f output_data.mem ]; then \
		echo "Output data: $$(wc -l < output_data.mem) lines"; \
	fi

# Run regression test
regression: clean all verify
	@echo "Regression test completed successfully!"

# Help target
help:
	@echo "Depthwise Convolution Testbench Makefile"
	@echo "========================================"
	@echo ""
	@echo "Available targets:"
	@echo "  all        - Generate data, compile, and run simulation"
	@echo "  data       - Generate test data files using Python script"
	@echo "  compile    - Compile SystemVerilog files"
	@echo "  sim        - Run simulation in batch mode"
	@echo "  sim-gui    - Run simulation with GUI"
	@echo "  sim-simple - Run quick simulation with simple test data"
	@echo "  verify     - Verify that output files were generated"
	@echo "  stats      - Show file statistics"
	@echo "  clean      - Remove generated files (keep work directory)"
	@echo "  clean-all  - Remove all generated files including work directory"
	@echo "  regression - Run complete regression test"
	@echo "  help       - Show this help message"
	@echo ""
	@echo "Files:"
	@echo "  RTL: $(RTL_FILES)"
	@echo "  Testbench: $(TB_FILES)"
	@echo "  Data script: $(DATA_SCRIPT)"
	@echo ""
	@echo "Generated data files: $(DATA_FILES)"
	@echo "Output files: $(OUTPUT_FILES)"

# Declare phony targets
.PHONY: all data compile sim sim-gui sim-simple verify clean clean-all stats regression help

# Default shell
SHELL := /bin/bash
