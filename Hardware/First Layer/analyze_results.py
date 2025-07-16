#!/usr/bin/env python3
"""
Accuracy Verification Results Analyzer
This script analyzes the results from the accuracy verification testbench
and provides comprehensive insights into the accelerator's performance.
"""

import numpy as np
import matplotlib.pyplot as plt
import os
import sys
from pathlib import Path

def read_hex_file(filename):
    """Read hexadecimal values from a file."""
    values = []
    try:
        with open(filename, 'r') as f:
            for line in f:
                line = line.strip()
                if line:
                    try:
                        values.append(int(line, 16))
                    except ValueError:
                        continue
    except FileNotFoundError:
        print(f"Warning: File {filename} not found")
        return []
    return values

def read_analysis_file(filename):
    """Read and parse the accuracy analysis file."""
    results = {}
    try:
        with open(filename, 'r') as f:
            content = f.read()
            
        # Extract key metrics using simple parsing
        lines = content.split('\n')
        for line in lines:
            if 'Total outputs processed:' in line:
                results['total_outputs'] = int(line.split(':')[1].strip())
            elif 'Exact matches:' in line:
                parts = line.split('(')[0].split(':')[1].strip()
                results['exact_matches'] = int(parts)
            elif 'Close matches' in line and '≤1 LSB' in line:
                parts = line.split('(')[0].split(':')[1].strip()
                results['close_matches'] = int(parts)
            elif 'Total errors:' in line:
                parts = line.split('(')[0].split(':')[1].strip()
                results['total_errors'] = int(parts)
            elif 'Mean absolute error:' in line:
                results['mean_error'] = float(line.split(':')[1].strip().split()[0])
            elif 'Maximum error:' in line:
                results['max_error'] = float(line.split(':')[1].strip().split()[0])
            
    except FileNotFoundError:
        print(f"Warning: File {filename} not found")
        return {}
    
    return results

def analyze_channel_distribution(values, num_channels=16):
    """Analyze the distribution of values across channels."""
    if not values:
        return {}
    
    # Assuming values are interleaved by channel
    channel_data = [[] for _ in range(num_channels)]
    
    for i, value in enumerate(values):
        channel_idx = i % num_channels
        channel_data[channel_idx].append(value)
    
    analysis = {}
    for i, data in enumerate(channel_data):
        if data:
            analysis[f'channel_{i}'] = {
                'count': len(data),
                'mean': np.mean(data),
                'std': np.std(data),
                'min': np.min(data),
                'max': np.max(data),
                'non_zero_count': sum(1 for x in data if x != 0)
            }
    
    return analysis

def create_visualizations(actual_values, expected_values, analysis_results):
    """Create comprehensive visualizations of the results."""
    
    # Create output directory for plots
    plots_dir = Path("accuracy_plots")
    plots_dir.mkdir(exist_ok=True)
    
    # 1. Error Distribution Histogram
    if actual_values and expected_values:
        errors = np.array(actual_values[:len(expected_values)]) - np.array(expected_values)
        abs_errors = np.abs(errors)
        
        plt.figure(figsize=(12, 8))
        
        plt.subplot(2, 2, 1)
        plt.hist(abs_errors, bins=50, alpha=0.7, color='blue', edgecolor='black')
        plt.title('Absolute Error Distribution')
        plt.xlabel('Absolute Error (LSB)')
        plt.ylabel('Frequency')
        plt.grid(True, alpha=0.3)
        
        # 2. Error vs Position
        plt.subplot(2, 2, 2)
        positions = range(len(errors))
        plt.scatter(positions[:1000], abs_errors[:1000], alpha=0.5, s=1)
        plt.title('Error vs Position (First 1000 samples)')
        plt.xlabel('Sample Position')
        plt.ylabel('Absolute Error (LSB)')
        plt.grid(True, alpha=0.3)
        
        # 3. Actual vs Expected Scatter Plot
        plt.subplot(2, 2, 3)
        sample_size = min(1000, len(actual_values), len(expected_values))
        plt.scatter(expected_values[:sample_size], actual_values[:sample_size], alpha=0.5, s=1)
        plt.plot([0, max(expected_values[:sample_size])], [0, max(expected_values[:sample_size])], 'r--', label='Perfect Match')
        plt.title('Actual vs Expected Values')
        plt.xlabel('Expected Value')
        plt.ylabel('Actual Value')
        plt.legend()
        plt.grid(True, alpha=0.3)
        
        # 4. Channel-wise Error Analysis
        plt.subplot(2, 2, 4)
        channel_errors = []
        for i in range(16):
            channel_indices = [j for j in range(len(errors)) if j % 16 == i]
            if channel_indices:
                channel_error = np.mean([abs_errors[j] for j in channel_indices])
                channel_errors.append(channel_error)
            else:
                channel_errors.append(0)
        
        plt.bar(range(16), channel_errors, alpha=0.7, color='green')
        plt.title('Mean Error by Channel')
        plt.xlabel('Channel')
        plt.ylabel('Mean Absolute Error (LSB)')
        plt.grid(True, alpha=0.3)
        
        plt.tight_layout()
        plt.savefig(plots_dir / 'error_analysis.png', dpi=300, bbox_inches='tight')
        plt.close()
    
    # 5. Value Distribution Comparison
    if actual_values and expected_values:
        plt.figure(figsize=(15, 5))
        
        plt.subplot(1, 3, 1)
        plt.hist(actual_values, bins=50, alpha=0.7, label='Actual', color='blue')
        plt.title('Actual Values Distribution')
        plt.xlabel('Value')
        plt.ylabel('Frequency')
        plt.legend()
        plt.grid(True, alpha=0.3)
        
        plt.subplot(1, 3, 2)
        plt.hist(expected_values, bins=50, alpha=0.7, label='Expected', color='red')
        plt.title('Expected Values Distribution')
        plt.xlabel('Value')
        plt.ylabel('Frequency')
        plt.legend()
        plt.grid(True, alpha=0.3)
        
        plt.subplot(1, 3, 3)
        plt.hist(actual_values, bins=50, alpha=0.5, label='Actual', color='blue')
        plt.hist(expected_values, bins=50, alpha=0.5, label='Expected', color='red')
        plt.title('Comparison: Actual vs Expected')
        plt.xlabel('Value')
        plt.ylabel('Frequency')
        plt.legend()
        plt.grid(True, alpha=0.3)
        
        plt.tight_layout()
        plt.savefig(plots_dir / 'value_distributions.png', dpi=300, bbox_inches='tight')
        plt.close()

def generate_report(analysis_results, channel_analysis):
    """Generate a comprehensive HTML report."""
    
    html_content = """
    <!DOCTYPE html>
    <html>
    <head>
        <title>Accelerator Accuracy Verification Report</title>
        <style>
            body { font-family: Arial, sans-serif; margin: 40px; }
            .header { background-color: #f0f0f0; padding: 20px; border-radius: 5px; }
            .section { margin: 20px 0; padding: 15px; border: 1px solid #ddd; border-radius: 5px; }
            .metric { display: inline-block; margin: 10px; padding: 10px; background-color: #e8f4f8; border-radius: 3px; }
            .good { background-color: #d4edda; }
            .warning { background-color: #fff3cd; }
            .error { background-color: #f8d7da; }
            table { border-collapse: collapse; width: 100%; }
            th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }
            th { background-color: #f2f2f2; }
            .plot { text-align: center; margin: 20px 0; }
        </style>
    </head>
    <body>
        <div class="header">
            <h1>Accelerator Accuracy Verification Report</h1>
            <p>Comprehensive analysis of the accelerator's performance against expected outputs</p>
        </div>
    """
    
    # Summary Metrics
    if analysis_results:
        total_outputs = analysis_results.get('total_outputs', 0)
        exact_matches = analysis_results.get('exact_matches', 0)
        close_matches = analysis_results.get('close_matches', 0)
        total_errors = analysis_results.get('total_errors', 0)
        mean_error = analysis_results.get('mean_error', 0)
        max_error = analysis_results.get('max_error', 0)
        
        accuracy_percent = (exact_matches / total_outputs * 100) if total_outputs > 0 else 0
        close_accuracy_percent = ((exact_matches + close_matches) / total_outputs * 100) if total_outputs > 0 else 0
        error_percent = (total_errors / total_outputs * 100) if total_outputs > 0 else 0
        
        accuracy_class = "good" if accuracy_percent > 95 else "warning" if accuracy_percent > 80 else "error"
        error_class = "good" if error_percent < 5 else "warning" if error_percent < 20 else "error"
        
        html_content += f"""
        <div class="section">
            <h2>Summary Metrics</h2>
            <div class="metric {accuracy_class}">
                <strong>Exact Match Accuracy:</strong><br>
                {accuracy_percent:.2f}% ({exact_matches:,} / {total_outputs:,})
            </div>
            <div class="metric good">
                <strong>Close Match Accuracy:</strong><br>
                {close_accuracy_percent:.2f}% (≤1 LSB error)
            </div>
            <div class="metric {error_class}">
                <strong>Error Rate:</strong><br>
                {error_percent:.2f}% ({total_errors:,} errors)
            </div>
            <div class="metric">
                <strong>Mean Error:</strong><br>
                {mean_error:.4f} LSB
            </div>
            <div class="metric">
                <strong>Max Error:</strong><br>
                {max_error:.4f} LSB
            </div>
        </div>
        """
    
    # Channel Analysis
    if channel_analysis:
        html_content += """
        <div class="section">
            <h2>Channel-wise Analysis</h2>
            <table>
                <tr>
                    <th>Channel</th>
                    <th>Count</th>
                    <th>Mean Value</th>
                    <th>Std Dev</th>
                    <th>Min</th>
                    <th>Max</th>
                    <th>Non-zero %</th>
                </tr>
        """
        
        for channel_name, data in channel_analysis.items():
            channel_num = channel_name.split('_')[1]
            non_zero_percent = (data['non_zero_count'] / data['count'] * 100) if data['count'] > 0 else 0
            
            html_content += f"""
                <tr>
                    <td>{channel_num}</td>
                    <td>{data['count']:,}</td>
                    <td>{data['mean']:.2f}</td>
                    <td>{data['std']:.2f}</td>
                    <td>{data['min']}</td>
                    <td>{data['max']}</td>
                    <td>{non_zero_percent:.1f}%</td>
                </tr>
            """
        
        html_content += "</table></div>"
    
    # Plots
    plots_dir = Path("accuracy_plots")
    if plots_dir.exists():
        html_content += """
        <div class="section">
            <h2>Visualizations</h2>
        """
        
        for plot_file in plots_dir.glob("*.png"):
            html_content += f"""
            <div class="plot">
                <h3>{plot_file.stem.replace('_', ' ').title()}</h3>
                <img src="{plot_file}" alt="{plot_file.stem}" style="max-width: 100%; height: auto;">
            </div>
            """
        
        html_content += "</div>"
    
    # Assessment
    if analysis_results:
        accuracy_percent = (exact_matches / total_outputs * 100) if total_outputs > 0 else 0
        mean_error = analysis_results.get('mean_error', 0)
        
        if accuracy_percent > 95 and mean_error < 1.0:
            assessment = "EXCELLENT"
            assessment_class = "good"
            assessment_desc = "The accelerator shows excellent accuracy with very low error rates."
        elif accuracy_percent > 90 and mean_error < 2.0:
            assessment = "GOOD"
            assessment_class = "good"
            assessment_desc = "The accelerator shows good accuracy with acceptable error rates."
        elif accuracy_percent > 80:
            assessment = "ACCEPTABLE"
            assessment_class = "warning"
            assessment_desc = "The accelerator shows acceptable accuracy but may need optimization."
        else:
            assessment = "NEEDS IMPROVEMENT"
            assessment_class = "error"
            assessment_desc = "The accelerator shows significant accuracy issues that need to be addressed."
        
        html_content += f"""
        <div class="section">
            <h2>Overall Assessment</h2>
            <div class="metric {assessment_class}">
                <strong>Assessment:</strong> {assessment}
            </div>
            <p>{assessment_desc}</p>
        </div>
        """
    
    html_content += """
    </body>
    </html>
    """
    
    with open("accuracy_report.html", "w", encoding="utf-8") as f:
        f.write(html_content)
    
    print("HTML report generated: accuracy_report.html")

def main():
    """Main analysis function."""
    print("Accelerator Accuracy Verification Results Analyzer")
    print("=" * 60)
    
    # Read actual and expected outputs
    print("Reading output files...")
    actual_values = read_hex_file("output_results.txt")
    expected_values = read_hex_file("memory/hs1_op_fixed.mem")
    
    print(f"Actual outputs: {len(actual_values):,}")
    print(f"Expected outputs: {len(expected_values):,}")
    
    # Read analysis results
    print("Reading analysis results...")
    analysis_results = read_analysis_file("accuracy_analysis.txt")
    
    # Analyze channel distribution
    print("Analyzing channel distribution...")
    channel_analysis = analyze_channel_distribution(actual_values)
    
    # Create visualizations
    print("Creating visualizations...")
    create_visualizations(actual_values, expected_values, analysis_results)
    
    # Generate report
    print("Generating comprehensive report...")
    generate_report(analysis_results, channel_analysis)
    
    # Print summary
    print("\n" + "=" * 60)
    print("ANALYSIS COMPLETED")
    print("=" * 60)
    
    if analysis_results:
        total_outputs = analysis_results.get('total_outputs', 0)
        exact_matches = analysis_results.get('exact_matches', 0)
        total_errors = analysis_results.get('total_errors', 0)
        mean_error = analysis_results.get('mean_error', 0)
        
        accuracy_percent = (exact_matches / total_outputs * 100) if total_outputs > 0 else 0
        
        print(f"Total outputs processed: {total_outputs:,}")
        print(f"Exact matches: {exact_matches:,} ({accuracy_percent:.2f}%)")
        print(f"Total errors: {total_errors:,}")
        print(f"Mean absolute error: {mean_error:.4f} LSB")
        
        if accuracy_percent > 95:
            print("✓ EXCELLENT: >95% exact matches")
        elif accuracy_percent > 90:
            print("✓ GOOD: >90% exact matches")
        elif accuracy_percent > 80:
            print("⚠ ACCEPTABLE: >80% exact matches")
        else:
            print("✗ NEEDS IMPROVEMENT: <80% exact matches")
    
    print("\nGenerated files:")
    print("  - accuracy_report.html: Comprehensive HTML report")
    print("  - accuracy_plots/: Directory containing visualizations")
    print("  - accuracy_analysis.txt: Detailed analysis results")
    print("  - error_details.txt: Specific error information")
    print("  - statistics.txt: Statistical summary")

if __name__ == "__main__":
    main() 