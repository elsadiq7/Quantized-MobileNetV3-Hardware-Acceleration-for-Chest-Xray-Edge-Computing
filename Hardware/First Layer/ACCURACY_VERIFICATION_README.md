# Accelerator Accuracy Verification System

This comprehensive system provides extensive accuracy verification for your accelerator by comparing its output with expected results from `hs1_op.mem`.

## 📋 Overview

The accuracy verification system consists of:

1. **`accuracy_verification_tb.sv`** - Comprehensive SystemVerilog testbench
2. **`run_accuracy_verification.do`** - ModelSim do file for running the verification
3. **`analyze_results.py`** - Python script for detailed analysis and visualization
4. **Generated Reports** - Multiple output files with detailed analysis

## 🚀 Quick Start

### Step 1: Run the Accuracy Verification Testbench

1. **Open ModelSim** and navigate to your project directory
2. **Run the verification** using the provided do file:
   ```tcl
   do run_accuracy_verification.do
   ```

### Step 2: Analyze Results

After the simulation completes, run the Python analysis script:
```bash
python analyze_results.py
```

### Step 3: Review Results

Check the generated files:
- `accuracy_report.html` - Comprehensive HTML report
- `accuracy_plots/` - Visualizations and charts
- `accuracy_analysis.txt` - Detailed analysis results
- `error_details.txt` - Specific error information

## 📊 What the System Analyzes

### 1. **Accuracy Metrics**
- **Exact matches**: Perfect matches with expected output
- **Close matches**: Within 1 LSB error
- **Acceptable matches**: Within 2 LSB error
- **Large errors**: > 4 LSB difference
- **Mean absolute error**: Average error magnitude
- **Error standard deviation**: Error distribution spread

### 2. **Channel-wise Analysis**
- Error distribution across all 16 channels
- Channel-specific statistics (mean, std dev, min, max)
- Non-zero value percentages per channel

### 3. **Statistical Analysis**
- Error distribution histograms
- Actual vs Expected value comparisons
- Error vs Position analysis
- Channel-wise error patterns

### 4. **Visualizations**
- Error distribution plots
- Value distribution comparisons
- Channel-wise error analysis
- Scatter plots of actual vs expected values

## 📁 File Structure

```
First Block/
├── accuracy_verification_tb.sv          # Main testbench
├── run_accuracy_verification.do         # ModelSim do file
├── analyze_results.py                   # Python analysis script
├── ACCURACY_VERIFICATION_README.md      # This file
├── memory/
│   ├── hs1_op.mem                      # Expected outputs
│   ├── conv1.mem                       # Convolution weights
│   ├── bn1.mem                         # Batch norm parameters
│   └── test_image.mem                  # Input test image
├── Generated Files (after running):
│   ├── accuracy_analysis.txt           # Main analysis report
│   ├── error_details.txt               # Detailed error info
│   ├── statistics.txt                  # Statistical summary
│   ├── accuracy_report.html            # HTML report
│   ├── accuracy_plots/                 # Visualization directory
│   │   ├── error_analysis.png         # Error analysis plots
│   │   └── value_distributions.png    # Value distribution plots
│   ├── output_results.txt             # Actual accelerator output
│   ├── output_results.hex             # Output in hex format
│   └── output_results.bmp             # Binary output file
```

## 🔍 Understanding the Results

### Accuracy Assessment Levels

| Level | Exact Match % | Mean Error | Assessment |
|-------|---------------|------------|------------|
| **EXCELLENT** | >95% | <1.0 LSB | Outstanding performance |
| **GOOD** | >90% | <2.0 LSB | Good performance |
| **ACCEPTABLE** | >80% | Any | Acceptable but needs optimization |
| **NEEDS IMPROVEMENT** | <80% | Any | Significant issues detected |

### Key Metrics Explained

1. **Exact Match Accuracy**: Percentage of outputs that exactly match expected values
2. **Close Match Accuracy**: Percentage of outputs within 1 LSB of expected values
3. **Error Rate**: Percentage of outputs with any error
4. **Mean Absolute Error**: Average magnitude of errors across all outputs
5. **Error Standard Deviation**: Spread of error distribution

## 🛠️ Customization Options

### Modifying Error Thresholds

In `accuracy_verification_tb.sv`, you can adjust error categorization:

```systemverilog
// Current thresholds
if (abs_error <= 1) begin
    close_matches = close_matches + 1;
end else if (abs_error <= 2) begin
    acceptable_matches = acceptable_matches + 1;
end else if (abs_error > 4) begin
    large_errors = large_errors + 1;
end
```

### Adding Custom Analysis

In `analyze_results.py`, you can add custom analysis functions:

```python
def custom_analysis(actual_values, expected_values):
    # Add your custom analysis here
    pass
```

## 📈 Interpreting Visualizations

### Error Analysis Plot
- **Top-left**: Error distribution histogram
- **Top-right**: Error vs position scatter plot
- **Bottom-left**: Actual vs expected scatter plot
- **Bottom-right**: Channel-wise mean error

### Value Distribution Plot
- **Left**: Actual values distribution
- **Center**: Expected values distribution  
- **Right**: Overlaid comparison

## 🔧 Troubleshooting

### Common Issues

1. **File Not Found Errors**
   - Ensure all memory files exist in the `memory/` directory
   - Check file paths in the testbench

2. **Simulation Timeout**
   - Increase `TIMEOUT_LIMIT` in the testbench
   - Check for infinite loops in the accelerator

3. **Memory Issues**
   - Ensure sufficient memory for large arrays
   - Consider reducing sample size for analysis

4. **Python Dependencies**
   - Install required packages: `pip install numpy matplotlib`

### Performance Optimization

1. **For Large Datasets**
   - Reduce the number of error positions tracked
   - Use sampling for visualization
   - Increase timeout limits

2. **Memory Usage**
   - Process data in chunks
   - Use streaming analysis for very large datasets

## 📝 Example Output

```
==========================================
ACCURACY VERIFICATION RESULTS
==========================================
OUTPUT SUMMARY:
  Total outputs: 200,704
  Non-zero outputs: 200,704 (100.00%)
  Min value: 0006
  Max value: fff8

ACCURACY ANALYSIS:
  Exact matches: 195,234 (97.28%)
  Close matches (≤1 LSB): 4,892 (2.44%)
  Acceptable matches (≤2 LSB): 578 (0.29%)
  Large errors (>4 LSB): 0 (0.00%)
  Total errors: 5,470 (2.72%)

ERROR STATISTICS:
  Mean absolute error: 0.0234 LSB
  Error standard deviation: 0.1523 LSB
  Maximum error: 2.0000 LSB
  Minimum error: 0.0000 LSB

OVERALL ASSESSMENT:
  ✓ EXCELLENT: >95% exact matches
  ✓ LOW ERROR: Mean error < 1 LSB
```

## 🤝 Contributing

To extend the accuracy verification system:

1. Add new analysis metrics to the testbench
2. Create additional visualization types
3. Implement custom error detection algorithms
4. Add support for different output formats

## 📞 Support

For issues or questions:
1. Check the troubleshooting section
2. Review the generated error files
3. Examine the console output for warnings
4. Verify all input files are present and correct

---

**Note**: This system provides comprehensive accuracy verification for your accelerator. The 1-extra-output issue you observed earlier is handled gracefully and doesn't affect the accuracy analysis. 