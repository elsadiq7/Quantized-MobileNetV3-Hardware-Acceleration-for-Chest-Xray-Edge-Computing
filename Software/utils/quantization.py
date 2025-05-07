from binary_fractions import Binary
import numpy as np
import pandas as pd
file_path_python = "D:/Way to  create brain/python/Machine-Learning-Specialization-Coursera-main/Machine-Learning-Specialization-Coursera-main/C2 - Advanced Learning Algorithms/week2/Handwritten digit classification using ANN/data/"
path_viv = "D:/Way to  create brain/1-Abdulrahman_Elsadiq/ai_acc_without_sys/ai_acc.srcs/sources_1/new/"
bias_const = {"l1": [8, 5, 8], "l2": [5, 5, 5], "l3": [3, 5, 3], "l4": [2, 5, 1]}
weight_const = {"l1": [8, 16, 49, "no"], "l2": [5, 1, 40, "no"], "l3": [3, 1, 25, "no"], "l4": [2, 1, 15, "yes"]}


def float_bin(number, places_int, places_float):
    '''

    :param number: it the float number to convert it to binary
    :param places_int: number of integer bits to represent int(number) in it
    :param places_float: number of floats bits to represent fraction number in it
    :return: binary representation of number consist of  (places_int+places_float)bit
    '''
    sign = 0
    number = float(number)
    if number < 0:
        sign = 1
        number = abs(number)

    if (number < 1):
        whole, dec = 0, float(number)
    else:
        whole, dec = str(number).split(".")
        dec = float("." + dec)
    # Convert both whole number and decimal
    # part from string type to integer type
    whole = int(whole)
    res = str(format(whole, f"0{places_int}b"))
    if (dec > 0):
        fraction_in_bin = str(Binary(dec))
        _, fraction_in_bin_2 = fraction_in_bin.split(".")
        fraction_rep = fraction_in_bin_2[0:places_float]

        if (len(fraction_rep) != places_float):  # confrim len of fraction is true
            fraction_rep += "0" * (places_float - len(fraction_rep))

        res += fraction_rep


    else:
        res += str(format(0, f"0{places_float}b"))
    if (sign):
        res = two_complement(res)

    return res


def two_complement(res):
    '''

    :param res:  it is the binary representation of number
    :return: two complemnt of the number
    '''
    ones_complement = ""
    for i in range(len(res)):
        if res[i] == "0":
            ones_complement += "1"
        else:
            ones_complement += "0"

    two_complement = ""
    flag_flow = 1  # Initialize outside the loop
    for i in range(len(res) - 1, -1, -1):
        if flag_flow == 0:
            two_complement += ones_complement[i]
        elif ones_complement[i] == "1" and flag_flow:
            two_complement += "0"
            flag_flow = 1
        elif ones_complement[i] == "0" and flag_flow:
            two_complement += "1"
            flag_flow = 0

    return two_complement[::-1]  # Reverse the result to get the correct order


def write_to_file(file_name, arr, mode="w"):
    '''

    :param file_name: file path
    :param arr: lines to write in the file
    :param mode: writing mode w or a
    :return: no retwurn just write lines in the file
    '''
    with open(file_name, mode) as file:
        file.writelines(arr)







def convert_two_complement2decmail(bin_num, int_len, float_len):
    '''

    :param bin_num: the binary representation of the number     :param int_len:  of int bits
    :param float_len: number of fraction bits
    :return: the decimal value of the number
    '''
    bin_num_int = bin_num[0:int_len]
    bin_num_float = bin_num[int_len:]

    dec_num = 0
    # convert binary intger to decmial
    for i in range(int_len):
        if i == 0:
            dec_num += int(bin_num_int[i]) * (-1) * 2 ** (int_len - 1 - i)
        else:
            dec_num += int(bin_num_int[i]) * (2) ** (int_len - 1 - i)
    for i in range(1, float_len + 1):
        dec_num += int(bin_num_float[i - 1]) * (2 ** (-i))

    return dec_num


def convert_big_num_to_binary(full_num, section_nums, int_len, float_len):
    '''

    :param full_num:is binary rep of n of number behind each other in one string
    :param section_nums:is the number of numbers in the string
    :param int_len: integer bit for each number
    :param float_len:float bit for each number
    :return:array of decimal values of the n numbers
    '''
    decimal_nums = []
    num_len = int_len + float_len
    for i in range(section_nums):
        bin_num = full_num[i * num_len:(i + 1) * num_len]
        decimal_nums.append(convert_two_complement2decmail(bin_num, int_len, float_len))

    return decimal_nums
import matplotlib.pyplot as plt
import seaborn as sns
import pandas as pd
import torch
import torch.nn as nn
from torchvision.models import mobilenet_v3_large

class CustomMobileNet(nn.Module):
    def __init__(self, num_classes=15, pretrained=True):
        super(CustomMobileNet, self).__init__()
        # Load the pre-trained MobileNetV3
        self.base_model = mobilenet_v3_large(pretrained=pretrained)
        
        # Modify the first convolutional layer to accept grayscale input
        self.base_model.features[0][0] = nn.Conv2d(
            in_channels=1,  # Grayscale input
            out_channels=self.base_model.features[0][0].out_channels,
            kernel_size=self.base_model.features[0][0].kernel_size,
            stride=self.base_model.features[0][0].stride,
            padding=self.base_model.features[0][0].padding,
            bias=False
        )
        
        # Modify the classifier for the desired number of classes
        num_features = self.base_model.classifier[0].in_features
        self.base_model.classifier = nn.Sequential(
            nn.Linear(num_features, num_classes)
        )
    
    def forward(self, x):
        return self.base_model(x)

# Instantiate the model with 15 output classes
model = CustomMobileNet(num_classes=15)
model.load_state_dict(torch.load("trained_models/CustomMobileNet_best_model_v2.pth"))
model.to("cpu")

def quantize_to_fixed_point_int(tensor, bits=8, fractional_bits=4):
    """
    Quantize a tensor to true fixed-point integer representation
    
    Args:
        tensor: Input tensor
        bits: Total number of bits
        fractional_bits: Number of bits for fractional part
    """
    # Calculate scaling factor (2^fractional_bits)
    scale = 2 ** fractional_bits
    
    # Calculate the maximum and minimum representable values
    n_integer_bits = bits - fractional_bits - 1  # -1 for sign bit
    max_val = 2 ** n_integer_bits - 1 / scale
    min_val = -(2 ** n_integer_bits)
    
    # Clamp values to representable range
    tensor_clamped = torch.clamp(tensor, min_val, max_val)
    
    # Scale up to integer values
    tensor_scaled = tensor_clamped * scale
    
    # Round to nearest integer
    tensor_int = torch.round(tensor_scaled)
    
    # Convert back to fixed-point representation
    return tensor_int / scale

def quantize_model_parameters_fixed_point(model, bits=8, fractional_bits=4):
    """
    Apply fixed-point integer quantization to model parameters
    
    Args:
        model: PyTorch model
        bits: Total number of bits
        fractional_bits: Number of bits for fractional part
    """
    for name, param in model.named_parameters():
            param.data = quantize_to_fixed_point_int(param.data, bits, fractional_bits)
            
    return model

# Example usage with different bit configurations
def print_tensor_stats(tensor, name="Tensor"):
    """Helper function to print tensor statistics"""
    print(f"\n{name} statistics:")
    print(f"Min: {tensor.min().item():.6f}")
    print(f"Max: {tensor.max().item():.6f}")
    print(f"Mean: {tensor.mean().item():.6f}")
    print(f"Sample values: {tensor.flatten()[:5].tolist()}")

# Test the quantization
def test_quantization():
    # Create a sample tensor
    original_tensor = torch.randn(5, 5) * 2
    
    print("Original tensor:")
    print_tensor_stats(original_tensor, "Original")
    
    # Test different bit configurations
    bit_configs = [
        (8, 4),   # 8-bit total, 4-bit fractional
        (16, 8),  # 16-bit total, 8-bit fractional
        (8, 3),   # 8-bit total, 3-bit fractional
    ]
    
    for total_bits, frac_bits in bit_configs:
        quantized = quantize_to_fixed_point_int(
            original_tensor, 
            bits=total_bits, 
            fractional_bits=frac_bits
        )
        print(f"\nQuantized ({total_bits}-bit, {frac_bits}-bit fractional):")
        print_tensor_stats(quantized, f"Quantized_{total_bits}_{frac_bits}")

# Use in your model evaluation loop
def evaluate_different_bits(model_class, model_path, test_loader, bit_configs):
    """
    Evaluate model with different fixed-point configurations
    
    Args:
        bit_configs: List of tuples (total_bits, fractional_bits)
    """
    results = {}
    
    for total_bits, frac_bits in tqdm(bit_configs, desc="Testing different bit configurations"):
        print(f"\nTesting with {total_bits}-bit quantization ({frac_bits} fractional bits)")
        
        # Instantiate a fresh model
        model = model_class(num_classes=15)
        model.load_state_dict(torch.load(model_path))
        model.to("cuda")
        
        # Apply quantization
        model = quantize_model_parameters_fixed_point(
            model, 
            bits=total_bits, 
            fractional_bits=frac_bits
        )
        
        # Save the quantized model
        save_path = f'trained_models/mobilenet_fixed_point_{total_bits}_{frac_bits}.pth'
        torch.save(model.state_dict(), save_path)
        
        # Evaluate
        accuracy, f1, report = evaluate_model(model, test_loader, "cuda")
        
        # Calculate model size
        model_size = os.path.getsize(save_path) / (1024 * 1024)  # Size in MB
        
        # Store results
        results[(total_bits, frac_bits)] = {
            'accuracy': accuracy,
            'f1_score': f1,
            'model_size': model_size,
            'report': report
        }
        
        print(f"Model Size: {model_size:.2f} MB")
        print(f"Test Accuracy: {accuracy:.4f}")
        print(f"Test F1 Score: {f1:.4f}")
        
    return results

# Example usage
bit_configs = [
    (4, 2),    # 8-bit total, 4-bit fractional
    (8, 4),   # 16-bit total, 8-bit fractional
    (12, 6),    # 8-bit total, 3-bit fractional
    (16, 8),   # 12-bit total, 6-bit fractional
    (18,9)
]


# Evaluate model with different configurations
results = evaluate_different_bits(
    CustomMobileNet,
    "trained_models/CustomMobileNet_best_model_v2.pth",
    test_loader,
    bit_configs
)



# Convert results to a DataFrame for easier plotting
def create_results_df(results):
    data = []
    for (total_bits, frac_bits), metrics in results.items():
        data.append({
            'Total Bits': total_bits,
            'Fractional Bits': frac_bits,
            'Integer Bits': total_bits - frac_bits,
            'Accuracy': metrics['accuracy'],
            'F1 Score': metrics['f1_score'],
            'Model Size (MB)': metrics['model_size']
        })
    return pd.DataFrame(data)

import matplotlib.pyplot as plt
import seaborn as sns

# After your evaluation loop, create simple plots
def plot_quantization_results(results):
    # Extract data
    total_bits = [config[0] for config in results.keys()]
    frac_bits = [config[1] for config in results.keys()]
    accuracies = [data['accuracy'] for data in results.values()]
    f1_scores = [data['f1_score'] for data in results.values()]
    model_sizes = [data['model_size'] for data in results.values()]

    # Create figure with 2x2 subplots
    fig, ((ax1, ax2), (ax3, ax4)) = plt.subplots(2, 2, figsize=(15, 12))

    # 1. Accuracy vs Total Bits
    ax1.plot(total_bits, accuracies, 'bo-', label='Accuracy')
    ax1.plot(total_bits, f1_scores, 'ro-', label='F1 Score')
    ax1.set_xlabel('Total Bits')
    ax1.set_ylabel('Score')
    ax1.set_title('Performance vs Total Bits')
    ax1.grid(True)
    ax1.legend()

    # 2. Model Size vs Total Bits
    ax2.plot(total_bits, model_sizes, 'go-')
    ax2.set_xlabel('Total Bits')
    ax2.set_ylabel('Model Size (MB)')
    ax2.set_title('Model Size vs Total Bits')
    ax2.grid(True)

    # 3. Accuracy vs Fractional Bits
    ax3.plot(frac_bits, accuracies, 'bo-', label='Accuracy')
    ax3.plot(frac_bits, f1_scores, 'ro-', label='F1 Score')
    ax3.set_xlabel('Fractional Bits')
    ax3.set_ylabel('Score')
    ax3.set_title('Performance vs Fractional Bits')
    ax3.grid(True)
    ax3.legend()

    # 4. Size vs Accuracy scatter plot
    ax4.scatter(model_sizes, accuracies)
    for i, (size, acc, bits) in enumerate(zip(model_sizes, accuracies, total_bits)):
        ax4.annotate(f'{bits}bits', (size, acc))
    ax4.set_xlabel('Model Size (MB)')
    ax4.set_ylabel('Accuracy')
    ax4.set_title('Accuracy vs Model Size')
    ax4.grid(True)

    plt.tight_layout()
    plt.savefig('quantization_results.png')
    plt.show()

    # Print summary
    print("\nResults Summary:")
    print("-" * 50)
    for (total_b, frac_b), metrics in results.items():
        print(f"\nConfiguration: {total_b} total bits, {frac_b} fractional bits")
        print(f"Accuracy: {metrics['accuracy']:.4f}")
        print(f"F1 Score: {metrics['f1_score']:.4f}")
        print(f"Model Size: {metrics['model_size']:.2f} MB")

# Use the plotting function after your evaluation
plot_quantization_results(results)