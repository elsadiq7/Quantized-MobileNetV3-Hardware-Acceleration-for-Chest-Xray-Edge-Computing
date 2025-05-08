import torch
import numpy as np
import onnx
import onnxruntime
from onnxruntime.quantization import quantize_static, CalibrationDataReader, QuantType
from onnx import numpy_helper
from tqdm import tqdm
from torch.utils.data import DataLoader
from torchvision import transforms, datasets
from .models import MobileNetV3_Small
from binary_fractions import Binary
import numpy as np
import pandas as pd
#%% Entire Quantization Pipeline in One Cell
import torch
import numpy as np
import onnx
import onnxruntime
from onnxruntime.quantization import quantize_static, CalibrationDataReader, QuantType
from onnx import numpy_helper, helper, TensorProto
from torch.utils.data import DataLoader
from torchvision import transforms, datasets
from tqdm import tqdm

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
import numpy as np
import onnx
import onnxruntime
from onnxruntime.quantization import quantize_static, CalibrationDataReader, QuantType
from onnx import numpy_helper
from tqdm import tqdm
from torch.utils.data import DataLoader
from torchvision import transforms, datasets
from .models import MobileNetV3_Small

class ONNXQuantizer:
    def __init__(self, model, val_loader, test_loader, input_shape, input_name='input', output_name='output'):
        self.model = model.eval()
        self.val_loader = val_loader
        self.test_loader = test_loader
        self.device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
        self.model.to(self.device)
        self.input_shape = input_shape
        self.input_name = input_name
        self.output_name = output_name
        self.onnx_fp32_path = "models/model_fp32.onnx"
        self.onnx_int8_path = "models/model_int8.onnx"

    def export_to_onnx(self):
        dummy_input = torch.randn(*self.input_shape).to(self.device)
        torch.onnx.export(
            self.model, dummy_input, self.onnx_fp32_path,
            export_params=True,
            opset_version=11,
            do_constant_folding=True,
            input_names=[self.input_name], output_names=[self.output_name],
            dynamic_axes={self.input_name: {0: 'batch_size'}, self.output_name: {0: 'batch_size'}}
        )
        print(f"Model exported to {self.onnx_fp32_path}")

    class DataLoaderCalibrationReader(CalibrationDataReader):
        def __init__(self, data_loader, input_name):
            self.input_name = input_name
            self.enum_data = []
            for images, _ in tqdm(data_loader, desc="Collecting calibration data"):
                self.enum_data.append({self.input_name: images.numpy().astype(np.float32)})
            self.data_iter = iter(self.enum_data)

        def get_next(self):
            return next(self.data_iter, None)

        def rewind(self):
            self.data_iter = iter(self.enum_data)

    def quantize(self):
        reader = self.DataLoaderCalibrationReader(self.val_loader, self.input_name)
        quantize_static(
            model_input=self.onnx_fp32_path,
            model_output=self.onnx_int8_path,
            calibration_data_reader=reader,
            weight_type=QuantType.QInt8,
            activation_type=QuantType.QUInt8
        )
        print(f"Quantized model saved to {self.onnx_int8_path}")

    def test_quantized_model(self):
        session = onnxruntime.InferenceSession(self.onnx_int8_path, providers=['CPUExecutionProvider'])
        input_name = session.get_inputs()[0].name
        output_name = session.get_outputs()[0].name

        correct = 0
        total = 0

        for images, labels in tqdm(self.test_loader, desc="Testing INT8 model"):
            images_np = images.numpy().astype(np.float32)
            outputs = session.run([output_name], {input_name: images_np})[0]
            preds = torch.tensor(outputs).argmax(dim=1)
            correct += (preds == labels).sum().item()
            total += labels.size(0)

        acc = correct / total
        print(f"Quantized Model Accuracy: {acc:.4f}")
        return acc

    

def run_quantize(val_loader, test_loader):
    # Initialize the model and load the pretrained weights
    model = MobileNetV3_Small(in_channels=1, num_classes=15)
    model.load_state_dict(torch.load("models/mobilenetv3_small_best_v2_0.pth"))
    
    # Define the input shape
    input_shape = (1, 1, 224, 224)  # Adjust as needed for your model's input
    
    # Initialize the ONNXQuantizer with the model, validation loader, and input shape
    quantizer = ONNXQuantizer(model, val_loader, test_loader, input_shape=input_shape)

    # Export the model to ONNX
    print("Exporting model to ONNX...")
    quantizer.export_to_onnx()

    # Perform quantization
    print("Quantizing the model...")
    quantizer.quantize()

    # Test the quantized model
    print("Testing the quantized model...")
    quantizer.test_quantized_model()




