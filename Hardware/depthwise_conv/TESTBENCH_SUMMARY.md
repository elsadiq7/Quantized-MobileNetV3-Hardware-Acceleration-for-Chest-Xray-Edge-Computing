# Depthwise Convolution Testbench - Complete Implementation

## 📋 Overview

This repository contains a comprehensive SystemVerilog testbench for the depthwise convolution module (`depthwise_conv.sv`). The testbench provides complete verification capabilities including input data generation, weight management, convolution processing simulation, and output verification.

## 🗂️ File Structure

```
depth/
├── depthwise_conv.sv           # DUT - Depthwise convolution module
├── depthwise_conv_tb.sv        # Main testbench file
├── generate_test_data.py       # Python script for test data generation
├── run_test.do                 # ModelSim/QuestaSim simulation script
├── Makefile                    # Build automation
├── README_testbench.md         # Detailed documentation
├── TESTBENCH_SUMMARY.md        # This summary file
│
├── Generated Test Data Files:
├── input_data.mem              # Input feature map data (200,704 entries)
├── weights.mem                 # Convolution weights (144 entries)
├── simple_input.mem            # Simple test case input
├── simple_weights.mem          # Simple test case weights
│
└── Generated Output Files:
    └── output_data.mem         # Convolution results (generated during simulation)
```

## ⚙️ Technical Specifications

### Module Parameters
- **Data Width**: 16 bits (Q8.8 signed fixed-point)
- **Input Dimensions**: 112×112×16 (Width × Height × Channels)
- **Output Dimensions**: 56×56×16 (due to stride=2)
- **Kernel Size**: 3×3
- **Stride**: 2
- **Padding**: 1
- **Parallelism**: 4 channels processed simultaneously

### Data Format
- **Fixed-Point**: Q8.8 format (8 integer bits, 8 fractional bits)
- **Range**: -128.0 to +127.996
- **Resolution**: 1/256 ≈ 0.0039
- **File Format**: 4-digit hexadecimal values

## 🚀 Quick Start

### Method 1: Using Makefile (Recommended)
```bash
# Generate test data, compile, and run simulation
make all

# Run with GUI for debugging
make sim-gui

# Clean generated files
make clean
```

### Method 2: Manual Steps
```bash
# 1. Generate test data
python generate_test_data.py

# 2. Compile and simulate (ModelSim/QuestaSim)
vsim -do run_test.do

# 3. Or compile manually
vlog depthwise_conv.sv depthwise_conv_tb.sv
vsim -c depthwise_conv_tb -do "run 50ms; quit"
```

## 📊 Test Data Patterns

### Input Patterns (by Channel)
1. **Channel 0 (mod 4)**: Checkerboard pattern (alternating ±0.5)
2. **Channel 1 (mod 4)**: Linear gradient pattern
3. **Channel 2 (mod 4)**: 2D sine wave pattern
4. **Channel 3 (mod 4)**: Gaussian random noise

### Weight Patterns (by Channel)
1. **Type 0**: Identity kernel (center=1, others=0)
2. **Type 1**: Blur kernel (uniform 1/9 weights)
3. **Type 2**: Edge detection kernel (center=8/9, others=-1/9)
4. **Type 3**: Sobel X gradient filter

## 🔍 Verification Features

### Functional Verification
- ✅ Complete data flow verification (input → processing → output)
- ✅ Timing and handshaking protocol verification
- ✅ Parallel processing unit verification
- ✅ Memory management and buffering verification

### Output Verification
- ✅ Sample count verification (expected: 50,176 outputs)
- ✅ Data range validation
- ✅ Format consistency checking
- ✅ File I/O integrity verification

### Debug Features
- 📊 Real-time signal monitoring
- 📈 Progress indicators and statistics
- 🔍 Detailed transaction logging
- ⚠️ Error detection and reporting
- ⏱️ Timeout protection (50ms default)

## 📈 Expected Results

### Performance Metrics
- **Input Samples**: 200,704 (112×112×16)
- **Output Samples**: 50,176 (56×56×16)
- **Weight Parameters**: 144 (3×3×16)
- **Memory Usage**: ~400KB for test data

### Test Outcomes
Upon successful completion, the testbench will:
1. Generate comprehensive test summary
2. Create output data file with results
3. Report verification status (PASS/FAIL)
4. Provide performance statistics

## 🛠️ Customization Options

### Parameter Modification
```systemverilog
// Modify testbench parameters for different test scenarios
parameter IN_WIDTH = 224;      // Different input size
parameter CHANNELS = 32;       // More channels
parameter STRIDE = 1;          // Different stride
parameter PARALLELISM = 8;     // More parallel units
```

### Custom Test Patterns
```systemverilog
// Add custom input patterns in generate_input_data()
pixel_value = custom_function(x, y, ch);

// Add custom weight patterns in generate_weights()
weight_value = custom_kernel[ky][kx];
```

## 🐛 Troubleshooting

### Common Issues and Solutions

1. **Compilation Errors**
   ```bash
   # Check SystemVerilog syntax
   vlog -lint depthwise_conv_tb.sv
   ```

2. **File I/O Issues**
   ```bash
   # Ensure proper file permissions
   chmod 644 *.mem
   ```

3. **Memory Issues**
   ```bash
   # For large simulations, increase simulator memory
   vsim -voptargs="+acc" depthwise_conv_tb
   ```

4. **Timeout Issues**
   ```systemverilog
   // Increase timeout in testbench
   #100000000; // 100ms timeout
   ```

## 📋 Verification Checklist

- [ ] Test data files generated successfully
- [ ] Compilation completed without errors
- [ ] Simulation runs to completion
- [ ] All expected output samples captured
- [ ] Output values within reasonable range
- [ ] No timeout or error conditions
- [ ] Output files properly formatted
- [ ] Test summary shows PASS status

## 🔧 Advanced Features

### Regression Testing
```bash
# Run complete regression test
make regression
```

### Performance Analysis
```bash
# Generate file statistics
make stats
```

### Custom Simulation Scripts
The testbench supports custom simulation scenarios through:
- Modular task structure
- Configurable test patterns
- Flexible verification methods
- Extensible file I/O framework

## 📚 Additional Resources

- **`README_testbench.md`**: Comprehensive technical documentation
- **`generate_test_data.py`**: Detailed data generation documentation
- **`run_test.do`**: ModelSim simulation script with waveform setup
- **`Makefile`**: Build automation with multiple targets

## 🎯 Success Criteria

The testbench is considered successful when:
1. All 200,704 input samples are processed
2. All 50,176 output samples are generated
3. No range violations or errors occur
4. Output file is properly formatted
5. Test summary reports PASS status

## 📞 Support

For issues or questions:
1. Check the detailed documentation in `README_testbench.md`
2. Review the simulation transcript for error messages
3. Use the debug features and waveform analysis
4. Verify file permissions and simulator settings

---

**Note**: This testbench has been designed for comprehensive verification of the depthwise convolution module and includes extensive documentation, automation, and debugging capabilities for professional development workflows.
