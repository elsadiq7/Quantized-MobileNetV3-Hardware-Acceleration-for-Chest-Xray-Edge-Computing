#!/usr/bin/env python3
"""
Test Data Generation Script for Depthwise Convolution Testbench

This script generates input feature maps and convolution weights in the proper
format for the SystemVerilog testbench. The data is generated in Q8.8 fixed-point
format and saved as hexadecimal values.

Usage: python generate_test_data.py
"""

import numpy as np
import math

# Parameters matching the Winograd SystemVerilog testbench
N = 16              # Data width
Q = 8               # Fractional bits
IN_WIDTH = 112      # Input width
IN_HEIGHT = 112     # Input height
CHANNELS = 16       # Number of channels
KERNEL_SIZE = 3     # Kernel size
PARALLELISM = 1     # Single channel processing

def real_to_fixed(value, n_bits=N, q_bits=Q):
    """Convert real number to Q8.8 fixed-point format"""
    scaled = value * (1 << q_bits)
    # Clamp to valid range for signed 16-bit
    scaled = max(-32768, min(32767, scaled))
    return int(scaled) & 0xFFFF

def generate_test_input():
    """Generate test input feature maps with various patterns"""
    print("Generating test input data...")
    
    input_data = []
    
    for ch in range(CHANNELS):
        for y in range(IN_HEIGHT):
            for x in range(IN_WIDTH):
                # Create different test patterns for different channels
                if ch % 4 == 0:
                    # Checkerboard pattern
                    value = 0.5 if (x + y) % 2 == 0 else -0.5
                elif ch % 4 == 1:
                    # Gradient pattern
                    value = (x + y) / (IN_WIDTH + IN_HEIGHT) - 0.5
                elif ch % 4 == 2:
                    # Sine wave pattern
                    value = 0.5 * math.sin(2 * math.pi * x / 32) * math.cos(2 * math.pi * y / 32)
                else:
                    # Random noise
                    value = np.random.normal(0, 0.3)
                
                # Add channel-specific offset
                value += 0.1 * ch / CHANNELS
                
                input_data.append(real_to_fixed(value))
    
    return input_data

def generate_test_weights():
    """Generate convolution weights for different filter types"""
    print("Generating convolution weights...")
    
    weight_data = []
    
    # Define different kernel types
    kernels = {
        0: [[ 0,  0,  0],    # Identity (center only)
            [ 0,  1,  0],
            [ 0,  0,  0]],
        
        1: [[ 1,  1,  1],    # Blur kernel
            [ 1,  1,  1],
            [ 1,  1,  1]],
        
        2: [[-1, -1, -1],    # Edge detection
            [-1,  8, -1],
            [-1, -1, -1]],
        
        3: [[-1,  0,  1],    # Sobel X
            [-2,  0,  2],
            [-1,  0,  1]]
    }
    
    for ch in range(CHANNELS):
        kernel_type = ch % 4
        kernel = kernels[kernel_type]
        
        # Normalize kernel
        if kernel_type == 1:  # Blur kernel
            scale = 1.0 / 9.0
        elif kernel_type == 2:  # Edge detection
            scale = 1.0 / 9.0
        elif kernel_type == 3:  # Sobel
            scale = 1.0 / 8.0
        else:  # Identity
            scale = 1.0
        
        for ky in range(KERNEL_SIZE):
            for kx in range(KERNEL_SIZE):
                weight_value = kernel[ky][kx] * scale
                weight_data.append(real_to_fixed(weight_value))
    
    return weight_data

def save_memory_file(data, filename, description):
    """Save data to memory file in hexadecimal format"""
    print(f"Saving {description} to {filename}...")
    
    with open(filename, 'w') as f:
        f.write(f"// {description}\n")
        f.write(f"// Format: 16-bit signed fixed-point (Q8.8)\n")
        f.write(f"// Total entries: {len(data)}\n")
        f.write("//\n")
        
        for i, value in enumerate(data):
            f.write(f"{value:04x}\n")
    
    print(f"Saved {len(data)} values to {filename}")

def generate_simple_test_case():
    """Generate a simple test case for verification"""
    print("Generating simple test case...")
    
    # Simple 3x3 input with known values
    simple_input = []
    simple_weights = []
    
    # Create a simple 3x3 pattern for each channel
    for ch in range(CHANNELS):
        for y in range(IN_HEIGHT):
            for x in range(IN_WIDTH):
                if x < 3 and y < 3:
                    # Simple pattern in top-left corner
                    value = (x + y + 1) * 0.1
                else:
                    value = 0.0
                simple_input.append(real_to_fixed(value))
    
    # Simple identity weights for verification
    for ch in range(CHANNELS):
        for ky in range(KERNEL_SIZE):
            for kx in range(KERNEL_SIZE):
                if ky == 1 and kx == 1:  # Center of kernel
                    weight_value = 1.0
                else:
                    weight_value = 0.0
                simple_weights.append(real_to_fixed(weight_value))
    
    save_memory_file(simple_input, "simple_input.mem", "Simple Test Input Data")
    save_memory_file(simple_weights, "simple_weights.mem", "Simple Test Weights")

def main():
    """Main function to generate all test data"""
    print("="*60)
    print("Depthwise Convolution Test Data Generator")
    print("="*60)
    print(f"Parameters:")
    print(f"  Input dimensions: {IN_WIDTH}x{IN_HEIGHT}x{CHANNELS}")
    print(f"  Kernel size: {KERNEL_SIZE}x{KERNEL_SIZE}")
    print(f"  Data format: Q{N-Q}.{Q} fixed-point")
    print(f"  Parallelism: {PARALLELISM}")
    print()
    
    # Generate main test data
    input_data = generate_test_input()
    weight_data = generate_test_weights()
    
    # Save to files
    save_memory_file(input_data, "input_data.mem", "Input Feature Map Data")
    save_memory_file(weight_data, "weights.mem", "Convolution Weights")
    
    # Generate simple test case for verification
    generate_simple_test_case()
    
    print()
    print("Test data generation completed!")
    print("Files generated:")
    print("  - input_data.mem: Main test input data")
    print("  - weights.mem: Main test weights")
    print("  - simple_input.mem: Simple test case input")
    print("  - simple_weights.mem: Simple test case weights")

if __name__ == "__main__":
    main()
