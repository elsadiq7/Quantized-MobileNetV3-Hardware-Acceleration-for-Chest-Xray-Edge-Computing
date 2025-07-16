# Depthwise Convolution Testbench Documentation

## Overview

This comprehensive SystemVerilog testbench verifies the functionality of the `depthwise_conv.sv` module, which implements a depthwise convolution operation commonly used in neural networks. The testbench includes complete input/output data management, weight generation, and verification capabilities.

## Module Under Test

**File:** `depthwise_conv.sv`

**Key Parameters:**
- Data width: 16 bits (signed fixed-point Q8.8 format)
- Input dimensions: 112×112×16 (Width × Height × Channels)
- Output dimensions: 56×56×16 (due to stride=2)
- Kernel size: 3×3
- Stride: 2
- Padding: 1
- Parallelism: 4 channels processed simultaneously

## Data Format

### Fixed-Point Representation
All data uses **Q8.8 signed fixed-point format**:
- Total bits: 16
- Integer bits: 8 (including sign bit)
- Fractional bits: 8
- Range: -128.0 to +127.996 (step size: 1/256 ≈ 0.0039)

### Conversion Functions
```systemverilog
// Real to Q8.8 fixed-point
scaled_value = real_value * 256;
fixed_point = $signed(scaled_value);

// Q8.8 fixed-point to real
real_value = $signed(fixed_point) / 256.0;
```

## File Organization

### Input Files
1. **`input_data.mem`** - Input feature map data
   - Format: 4-digit hexadecimal values
   - Size: 112×112×16 = 200,704 entries
   - Organization: Channel-major order (all pixels of channel 0, then channel 1, etc.)

2. **`weights.mem`** - Convolution weights
   - Format: 4-digit hexadecimal values
   - Size: 3×3×16 = 144 entries
   - Organization: Channel-major, then row-major within each kernel

### Output Files
1. **`output_data.mem`** - Convolution results
   - Format: 4-digit hexadecimal values with header
   - Size: 56×56×16 = 50,176 entries
   - Organization: Same as input (channel-major order)

### Test Data Generation
Use the provided Python script to generate test data:
```bash
python generate_test_data.py
```

This creates:
- `input_data.mem` - Main test input with various patterns
- `weights.mem` - Different kernel types (identity, blur, edge detection, Sobel)
- `simple_input.mem` - Simple test case for verification
- `simple_weights.mem` - Identity weights for simple verification

## Testbench Architecture

### Main Components

1. **Clock and Reset Generation**
   - 100MHz clock (10ns period)
   - Proper reset sequence

2. **DUT Instantiation**
   - All parameters properly configured
   - Complete signal connectivity

3. **Memory Arrays**
   - Input memory: Stores test input data
   - Weight memory: Stores convolution weights
   - Output memory: Captures results

4. **Test Control Tasks**
   - `generate_input_data()`: Creates test patterns
   - `generate_weights()`: Creates convolution kernels
   - `feed_input_data()`: Feeds data to DUT
   - `capture_output_data()`: Captures results
   - `verify_output()`: Basic verification

### Test Patterns

The testbench generates diverse test patterns:

1. **Channel 0 (mod 4)**: Checkerboard pattern
2. **Channel 1 (mod 4)**: Gradient pattern  
3. **Channel 2 (mod 4)**: Sine wave pattern
4. **Channel 3 (mod 4)**: Random noise

### Weight Patterns

Different kernel types for each channel group:

1. **Type 0**: Identity kernel (center=1, others=0)
2. **Type 1**: Blur kernel (all weights=1/9)
3. **Type 2**: Edge detection (-1 around, 8 in center)
4. **Type 3**: Sobel X gradient filter

## Running the Testbench

### Prerequisites
- ModelSim/QuestaSim or compatible simulator
- Python 3.x (for test data generation)
- NumPy library

### Compilation and Simulation

1. **Generate test data:**
   ```bash
   python generate_test_data.py
   ```

2. **Compile SystemVerilog files:**
   ```bash
   vlog depthwise_conv.sv depthwise_conv_tb.sv
   ```

3. **Run simulation:**
   ```bash
   vsim -c depthwise_conv_tb -do "run -all; quit"
   ```

### Expected Output

The testbench will:
1. Generate and save test data
2. Load weights into the DUT
3. Feed input data systematically
4. Capture all output results
5. Perform basic verification
6. Generate a comprehensive test summary

## Verification Strategy

### Functional Verification
- **Data Flow**: Ensures proper input→processing→output flow
- **Timing**: Verifies correct handshaking and valid signals
- **Completeness**: Checks all expected outputs are generated

### Output Verification
- **Range Checking**: Outputs within reasonable bounds
- **Sample Count**: Correct number of output samples
- **Format Validation**: Proper data format and organization

### Coverage Analysis
- **Input Patterns**: Multiple test patterns per channel
- **Weight Variations**: Different kernel types
- **Edge Cases**: Boundary conditions and corner cases

## Debugging Features

### Signal Monitoring
- Real-time display of key signals
- Progress indicators during long operations
- Detailed logging of input/output transactions

### File Output
- Comprehensive header information in output files
- Human-readable format with conversion utilities
- Separate files for different test scenarios

### Error Reporting
- Detailed error messages with timestamps
- Range violation warnings
- Timeout detection and reporting

## Performance Metrics

### Expected Results
- **Input samples**: 200,704 (112×112×16)
- **Output samples**: 50,176 (56×56×16)
- **Processing time**: Depends on implementation efficiency
- **Memory usage**: ~400KB for test data storage

### Timing Analysis
The testbench measures:
- Total simulation cycles
- Data throughput (samples/cycle)
- Processing latency
- Memory access patterns

## Customization

### Parameter Modification
To test different configurations, modify parameters in the testbench:
```systemverilog
parameter IN_WIDTH = 224;    // Different input size
parameter CHANNELS = 32;     // More channels
parameter STRIDE = 1;        // Different stride
```

### Test Pattern Customization
Modify the `generate_input_data()` task to create custom test patterns:
```systemverilog
// Custom test pattern
pixel_value = custom_function(x, y, ch);
input_memory[index] = real_to_fixed(pixel_value);
```

### Weight Customization
Create custom convolution kernels in `generate_weights()`:
```systemverilog
// Custom kernel
weight_value = custom_kernel[ky][kx];
weight_memory[index] = real_to_fixed(weight_value);
```

## Troubleshooting

### Common Issues

1. **File I/O Errors**
   - Ensure write permissions in simulation directory
   - Check file paths and naming conventions

2. **Memory Allocation**
   - Large arrays may require simulator memory settings
   - Consider reducing test size for initial verification

3. **Timing Issues**
   - Verify clock and reset timing
   - Check setup/hold requirements

4. **Data Format**
   - Ensure consistent Q8.8 format usage
   - Verify hexadecimal file format

### Debug Tips
- Use waveform viewer for signal analysis
- Enable verbose logging for detailed trace
- Start with simple test cases before complex patterns
- Verify intermediate results at each processing stage

## Future Enhancements

Potential improvements to the testbench:
- Golden reference model for bit-accurate verification
- Automated test vector generation
- Performance benchmarking capabilities
- Integration with continuous integration systems
- Support for different data formats and precisions
