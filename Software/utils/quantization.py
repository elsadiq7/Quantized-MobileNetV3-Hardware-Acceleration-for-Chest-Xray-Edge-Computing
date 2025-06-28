import torch
import numpy as np
from torch.utils.data import DataLoader
from torchvision import transforms, datasets
from tqdm import tqdm
import onnx
import onnxruntime
from onnxruntime.quantization import quantize_static, CalibrationDataReader, QuantType
from onnx import numpy_helper, helper, TensorProto
from .models import MobileNetV3_Small
from binary_fractions import Binary
import pandas as pd
import os 
import torch.nn as nn

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


import torch
from torch.utils.data import DataLoader

class ActivationRangeAnalyzer:
    def __init__(self, model: torch.nn.Module):
        self.model = model
        self.layer_names = {}
        self.layer_ranges = {}  # Tracks min/max during analyze()
        self._register_layer_names()
        self.hooks = []

    def _register_layer_names(self, module=None, parent_name=''):
        if module is None:
            module = self.model
            self.layer_names = {}
        
        for name, child in module.named_children():
            full_name = f"{parent_name}.{name}" if parent_name else name
            self.layer_names[child] = full_name
            self._register_layer_names(child, full_name)

    def _hook_fn_analyze(self, module, inputs, outputs):
        """Hook for tracking min/max during analyze()"""
        if isinstance(outputs, torch.Tensor):
            current_min = outputs.min().item()
            current_max = outputs.max().item()
            
            if module not in self.layer_ranges:
                self.layer_ranges[module] = {'min': float('inf'), 'max': float('-inf')}
                
            self.layer_ranges[module]['min'] = min(
                self.layer_ranges[module]['min'], current_min
            )
            self.layer_ranges[module]['max'] = max(
                self.layer_ranges[module]['max'], current_max
            )

    def register_hooks(self, hook_type='analyze'):
        """Register hooks for different purposes (analyze vs get_activations)"""
        self._clear_hooks()
        if hook_type == 'analyze':
            for module in self.model.modules():
                self.hooks.append(module.register_forward_hook(self._hook_fn_analyze))

    def analyze(self, test_loader: DataLoader, device: str = 'cuda'):
        """Analyze activation ranges across dataset (min/max tracking)"""
        self.layer_ranges.clear()
        self.register_hooks('analyze')
        
        device = torch.device(device if torch.cuda.is_available() else 'cpu')
        self.model = self.model.to(device)
        self.model.eval()

        with torch.no_grad():
            for inputs, _ in test_loader:
                inputs = inputs.to(device, dtype=torch.float32)
                _ = self.model(inputs)

        self._clear_hooks()

    def get_activations(self, input_tensor: torch.Tensor, device: str = 'cuda') -> dict:
        """
        Get all activation values for a single input tensor
        Args:
            input_tensor: Input tensor (must include batch dimension)
            device: Device to use for computation
        Returns:
            Dictionary {layer_name: flattened_numpy_array_of_activations}
        """
        activations = {}
        hooks = []

        def _hook_fn_collect(module, inputs, outputs):
            """Temporary hook to collect activations"""
            if isinstance(outputs, torch.Tensor):
                activations[self.layer_names[module]] = outputs.detach().cpu().numpy()

        # Register temporary hooks
        for module in self.model.modules():
            if module in self.layer_names:
                hooks.append(module.register_forward_hook(_hook_fn_collect))

        # Run inference
        device = torch.device(device if torch.cuda.is_available() else 'cpu')
        self.model.to(device).eval()
        with torch.no_grad():
            _ = self.model(input_tensor.to(device, dtype=torch.float32))

        # Cleanup hooks
        for hook in hooks:
            hook.remove()

        return activations

    def _clear_hooks(self):
        for hook in self.hooks:
            hook.remove()
        self.hooks = []

    def print_results(self):
        """Print summary of activation ranges from analyze()"""
        if not self.layer_ranges:
            print("No activation data available. Run analyze() first.")
            return

        # Initialize tracking variables
        global_min = float('inf')
        global_max = -float('inf')
        min_layer = ""
        max_layer = ""
        total_layers = len(self.layer_ranges)

        # Find global extremes and their layers
        for module, stats in self.layer_ranges.items():
            layer_name = self.layer_names.get(module, str(module))
            
            if stats['min'] < global_min:
                global_min = stats['min']
                min_layer = layer_name
                
            if stats['max'] > global_max:
                global_max = stats['max']
                max_layer = layer_name

        # Print summary
        print("\nActivation Range Summary:")
        print(f"Tracked layers: {total_layers}")
        print(f"Global minimum: {global_min:.6f} (found in '{min_layer}')")
        print(f"Global maximum: {global_max:.6f} (found in '{max_layer}')")
        print(f"Total range: {global_max - global_min:.6f}")

def run_qun_range_based(test_loader, image, model):

    # Initialize analyzer
    analyzer = ActivationRangeAnalyzer(model)

    # 1. Analyze activation ranges across dataset
    analyzer.analyze(test_loader)
    analyzer.print_results()

    if image.dim() == 3:
        image = image.unsqueeze(0)

 

    # 2. Run model to collect activations
    activations = analyzer.get_activations(image)

    return activations


      
def write_to_file(file_name, arr, mode="w"):
    '''

    :param file_name: file path
    :param arr: lines to write in the file
    :param mode: writing mode w or a
    :return: no retwurn just write lines in the file
    '''
    with open(file_name, mode) as file:
        file.writelines(arr)   


def qun_image(padded_image,file_name,float_len=8,int_len=8):
    main_path="memory_files"
    os.makedirs(main_path,exist_ok=True)
    if len(padded_image.shape)>2:
        padded_image=padded_image[0]
    
    
    arr=[]
    for i in range (padded_image.shape[0]):
      it_raw=""
      for j in range (padded_image.shape[0]):
             rep=float_bin(padded_image[i][j], int_len, float_len)
             it_raw= rep+it_raw
      if (i!=(padded_image.shape[0]-1)):
          it_raw+="\n"
      arr.append(it_raw)
    write_to_file(main_path+"/"+file_name, arr, "w")

def write_to_file(path, lines, mode="w"):
    with open(path, mode) as f:
        for line in lines:
            f.write(line)

def get_module_by_name(model, layer_name):
    parts = layer_name.split('.')
    for part in parts:
        if part.isdigit():
            model = model[int(part)]
        else:
            model = getattr(model, part)
    return model



def qun_conv(model, layer_name, file_name, float_len=8, int_len=8):
    os.makedirs("memory_files", exist_ok=True)
    conv = get_module_by_name(model, layer_name)
    weights = conv.weight.data.cpu()
    out_channels, in_channels, kH, kW = weights.shape
    arr = []
    for i in range(out_channels):
        it_raw = ""
        for j in range(kH):
            for k in range(kW):
                rep = float_bin(weights[i][0][j][k], int_len, float_len)
                it_raw = rep + it_raw
        it_raw += "\n"
        arr.append(it_raw)
    write_to_file("memory_files/" + file_name, arr)

def qun_bn(model, layer_name, file_name, float_len=8, int_len=8):
    os.makedirs("memory_files", exist_ok=True)
    bn = get_module_by_name(model, layer_name)
    gamma = bn.weight.data.cpu()
    beta = bn.bias.data.cpu()
    gamma_raw = "".join(float_bin(g, int_len, float_len) for g in reversed(gamma)) + "\n"
    beta_raw = "".join(float_bin(b, int_len, float_len) for b in reversed(beta)) + "\n"
    write_to_file("memory_files/" + file_name, [gamma_raw, beta_raw])


def qun_layer_op(output, file_name, float_len=8, int_len=8):
    os.makedirs("memory_files", exist_ok=True)

    # === FIX: No .cpu() — already NumPy array ===
    output = output[0]  # [C, H, W]
    C, H, W = output.shape
    arr = []
    for i in range(C):
        for j in range(H):
            it_raw = ""
            for k in range(W):
                rep = float_bin(output[i][j][k], int_len, float_len)
                it_raw = rep + it_raw
            arr.append(it_raw + "\n")
    write_to_file("memory_files/" + file_name, arr)

def qun_layer_linear_op(output, file_name, float_len=8, int_len=8):
    os.makedirs("memory_files", exist_ok=True)
    output = output[0] # shape: [D] or [D1, D2]
    arr = []

    if output.ndim == 1:
        for i in range(output.shape[0]):
            rep = float_bin(output[i], int_len, float_len)
            arr.append(rep + "\n")

    elif output.ndim == 2:
        D1, D2 = output.shape
        for i in range(D1):
            it_raw = ""
            for j in range(D2):
                rep = float_bin(output[i][j], int_len, float_len)
                it_raw = rep + it_raw
            it_raw += "\n"
            arr.append(it_raw)

    else:
        raise ValueError(f"Unsupported shape {output.shape} for linear activation.")

    write_to_file(file_name, arr)

def dump_all_quantized(model, activations_dict, float_len=8, int_len=8):
    os.makedirs("memory_files", exist_ok=True)

    # === Dump weights ===
    for name, module in model.named_modules():
        try:
            if isinstance(module, nn.Conv2d):
                qun_conv(model, name, f"{name.replace('.', '_')}_conv.mem", float_len, int_len)
            elif isinstance(module, nn.BatchNorm2d):
                qun_bn(model, name, f"{name.replace('.', '_')}_bn.mem", float_len, int_len)
        except Exception as e:
            print(f"Skipped weight {name}: {e}")

    # === Dump activations ===
    for i, (name, activation) in enumerate(activations_dict.items()):
        try:
            if not isinstance(activation, np.ndarray):
                raise TypeError(f"Activation '{name}' is not a NumPy array.")
            filename = f"{i:02d}_{name.replace('.', '_')}_act.mem"

            if activation.ndim > 3:
                qun_layer_op(activation, filename, float_len, int_len)
            elif activation.ndim in [1, 2]:
                qun_layer_linear_op(activation, filename, float_len, int_len)
            else:
                raise ValueError(f"Unsupported activation shape: {activation.shape}")

        except Exception as e:
            print(f"Skipped activation {name}: {e}")



# def qun_conv(model,layer_name,file_name,float_len=8,int_len=8):
#     main_path="memory_files"
#     os.makedirs(main_path,exist_ok=True)
#     conv=getattr(model, layer_name)
#     weights=conv.weight
#     weights_shape=weights.shape
    
#     arr=[]
#     for i in range (weights_shape[0]):
#       it_raw=""
#       for j in range (weights_shape[2]):
#           for k in range (weights_shape[3]):
#              rep=float_bin(weights[i][0][j][k], int_len, float_len)
#              it_raw= rep+it_raw
#       if (i!=15):
#           it_raw+="\n"
#       arr.append(it_raw)
#     write_to_file(main_path+"/"+file_name, arr, "w")

# def qun_bn(model,layer_name,file_name,float_len=8,int_len=8):
#     main_path="memory_files"
#     os.makedirs(main_path,exist_ok=True)
#     bn=getattr(model, layer_name)
#     gamma=bn.weight
#     beta=bn.bias
    
#     arr=[]
#     gamma_raw=""
#     beta_raw=""
#     for i in range (gamma.shape[0]):
#       rep=float_bin(gamma[i], int_len, float_len)
#       gamma_raw= rep+gamma_raw
#     for i in range (beta.shape[0]):
#       rep=float_bin(beta[i], int_len, float_len)
#       beta_raw= rep+beta_raw
        
#     gamma_raw+="\n"
#     arr.append(gamma_raw)
#     arr.append(beta_raw)
#     write_to_file(main_path+"/"+file_name, arr, "w")
    

# def qun_layer_op(output,file_name,float_len=8,int_len=8):
#     main_path="memory_files"
#     os.makedirs(main_path,exist_ok=True)
#     output=output[0]
#     weights_shape=output.shape

    
#     arr=[]
#     for i in range (weights_shape[0]):
#       for j in range (weights_shape[1]):
#           it_raw=""
#           for k in range (weights_shape[2]):
#              rep=float_bin(output[i][j][k], int_len, float_len)
#              it_raw= rep+it_raw
#           #if i!=(weights_shape[0]-1) and j!=(weights_shape[1]-1):
#           it_raw+="\n"
#           arr.append(it_raw)
#     write_to_file(main_path+"/"+file_name, arr, "w")





