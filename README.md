# 🔧 Project Overview

🚀 **Graduation Project** | FPGA-Based AI Accelerator for Medical Imaging

We proudly present a complete system that integrates **FPGA hardware modules** and a **Python-based software stack** to accelerate deep learning inference for **chest X-ray image classification**.

> 🛠️ Developed under the mentorship of the **Analog Devices Digital Team – Cairo** and **Dr. Mohammed Sharaf**.

---

### 📁 Repository Structure

```
├── Hardware/                     # Verilog modules for CNN acceleration on FPGA
│   ├── Bottleneck_layer/         # Efficient MobileNet-style bottlenecks
│   ├── CONST_BOTTEL_FUNC/        # Constants and reusable parameters
│   ├── Final layer/              # Output stage for classification
│   ├── First Layer/              # Initial input processing
│   ├── SE layer/                 # Squeeze-and-Excitation attention blocks
│   ├── SHORTCUT/                 # Residual connection logic
│   ├── Top module/               # Top-level system integration
│   ├── depthwise_conv/           # Depthwise convolution units
│   └── pointwise layer/          # Pointwise (1×1) convolution
│
├── Software/                     # Python tools for training, quantization & UI
│   ├── app.py                    # Gradio app for interactive inference
│   ├── memory_files/             # Quantized memory files for FPGA loading
│   ├── models/                   # Trained models and configurations
│   ├── utils/                    # Helper scripts for preprocessing & training
│   ├── project_flow.ipynb        # Notebook showing full ML-to-FPGA pipeline
│   └── training_histories.json   # Saved training/validation performance
│
├── README.md                     # Project documentation
└── .gitignore                    # Git exclusions
```

---

Here’s a refined, more readable version of your **💻 Software Overview** section with consistent formatting, improved clarity, and a polished flow:

---

### 💻 Software Overview (`/Software`)

This software stack powers the full machine learning pipeline—from data prep to FPGA-ready deployment.

---

#### 📁 Dataset Preparation

* Downloads and cleans the **NIH ChestX-ray14** dataset
* Splits data into train/val/test sets
* Removes outliers and applies image augmentation

---

#### 🧠 Model Training

* Uses a lightweight CNN based on **MobileNetV3-Small**
* Monitors both **training** and **validation** performance
* The model can classify **14 chest conditions** plus **"No Finding"**

##### 🩺 Classification Categories:

| Label                     | Description                                                   |
| ------------------------- | ------------------------------------------------------------- |
| **No Finding 🩺**         | X-ray appears normal. Continue regular checkups.              |
| **Infiltration 🌫️**      | Possible lung fluid or infection. See a pulmonologist.        |
| **Atelectasis 🫁**        | Partial lung collapse. Needs urgent evaluation.               |
| **Effusion 💧**           | Fluid around lungs. Prompt physician visit recommended.       |
| **Nodule 🔬**             | Small spot found. May need scan or biopsy.                    |
| **Pneumothorax 🫁❌**      | Air in chest cavity. Emergency care needed.                   |
| **Mass ⚪**                | Abnormal tissue. See a specialist.                            |
| **Consolidation 🫁🩸**    | Possible pneumonia or infection. Doctor consultation advised. |
| **Pleural Thickening 🧱** | Lung lining scarring. Regular monitoring required.            |
| **Cardiomegaly ❤️**       | Enlarged heart. Cardiologist follow-up needed.                |
| **Emphysema 💨**          | Chronic lung condition. Pulmonary care important.             |
| **Fibrosis 🧵**           | Lung scarring. Ongoing monitoring may be needed.              |
| **Edema 🌊**              | Fluid in lungs. Heart evaluation essential.                   |
| **Pneumonia 🤒**          | Infection detected. Immediate antibiotics recommended.        |
| **Hernia 🩻**             | Possible diaphragm hernia. Surgical review advised.           |

---

#### 📦 Model Quantization & Export

* Applies **Q8.8 fixed-point quantization**
* Outputs FPGA-compatible **memory files** for deployment

---

#### 🎛️ Gradio Interface

* Clean, interactive UI to test model predictions on X-rays

---

#### 🔗 Kaggle Integration

* Streamlined access to datasets via Kaggle API

---

### 🛠️ Hardware Modules (`/Hardware`)

All hardware blocks are implemented in **Verilog** and synthesized with **Xilinx Vivado** for real-time edge inference:

* **🔹 First Layer**
  Initial convolution layer that processes the input image.

* **🔹 Bottleneck Layer**
  Efficient depth-reduction/expansion inspired by MobileNetV3.

* **🔹 SE Layer**
  Implements Squeeze-and-Excitation blocks for channel-wise attention.

* **🔹 Depthwise Convolution**
  Lightweight convolution per channel to minimize computation.

* **🔹 Pointwise Layer**
  Performs 1×1 convolution for channel mixing.

* **🔹 SHORTCUT**
  Residual connections for improved learning and stability.

* **🔹 Final Layer**
  Final projection or classification layer.

* **🔹 CONST\_BOTTEL\_FUNC**
  Shared constants and configuration for bottleneck logic.

* **🔹 Top Module**
  Combines all components into a complete, synthesizable system.

---

### 📈 Performance Benchmarks

This system achieves real-time inference and high accuracy on medical images, making it practical for **edge deployment in clinical settings**.

| Metric                       | Value                              |
| ---------------------------- | ---------------------------------- |
| **Model Architecture**       | MobileNetV3-Small                  |
| **Training Accuracy**        | 100%                               |
| **Testing Accuracy**         | 82%                                |
| **Quantization Format**      | Fixed-point Q8.8 (INT16)           |
| **Inference Latency (FPGA)** | \~100 ms per image                 |
| **Throughput**               | \~10 FPS                           |
| **Target Device**            | Xilinx FPGA (Vivado Synthesized)   |
| **Application**              | Chest X-ray Classification (NIH14) |

🧮 The quantization pipeline preserves model performance while enabling efficient hardware execution. Each prediction runs in **\~100 ms**, suitable for **real-time edge AI**.

---

### 🧠 Why This Matters

This project bridges the gap between **AI development** and **hardware deployment**:

* ✅ Full-stack pipeline from dataset to FPGA
* ✅ Real-time inference at the edge
* ✅ Quantization-aware design for resource-limited devices
* ✅ Medical relevance with real-world dataset

---



Here’s your **Getting Started** section, fully cleaned up, formatted for clarity, and made more professional and consistent with your full README. It’s ready to paste directly:

---

## ⚙️ Getting Started

Follow these steps to set up the software and hardware environments for development, simulation, and deployment.

---

### ✅ Prerequisites

* **Hardware Tools**:

  * [Xilinx Vivado 2019.2](https://www.xilinx.com/support/download.html) (or later)
  * [QuestaSim](https://eda.sw.siemens.com/en-US/ic/questa/) for Verilog simulation

* **Software Requirements**:

  * Python 3.x
  * Required packages (see `requirements.txt`)

  Install dependencies:

  ```bash
  pip install -r requirements.txt
  ```


---

### 📦 Setup Instructions

1. **Clone the Repository**

   ```bash
   git clone <repository-url>
   cd <repository-directory>
   ```

2. **Install Python Dependencies**

   ```bash
   pip install -r requirements.txt
   ```

3. **Configure Kaggle Credentials**

   Place your `kaggle.json` API token in the appropriate location:

   * **Linux/Mac**:
     `~/.kaggle/kaggle.json`
   * **Windows**:
     `C:\Users\<YourUsername>\.kaggle\kaggle.json`

   Set correct file permissions (for Unix systems):

   ```bash
   chmod 600 ~/.kaggle/kaggle.json
   ```

4. **Run Project Pipeline (Jupyter Notebook)**
   Open the main workflow notebook to run preprocessing, training, and quantization steps:

   ```bash
   jupyter notebook Software/project_flow.ipynb
   ```

5. **Launch the Gradio Inference UI**
   Use the trained model through a simple web interface:

   ```bash
   python Software/app.py
   ```

6. **Open & Simulate in Vivado / QuestaSim**

   #### ▶️ Vivado (FPGA Flow)

   1. Navigate to the Vivado project:

      ```bash
      cd Hardware/Top module/
      ```
   2. Open the `.xpr` project file in Vivado and follow these steps:

      * RTL Analysis
      * Synthesis
      * Implementation
      * Bitstream Generation

   #### 🔬 QuestaSim (Module Simulation)

   1. Go to the folder of the module you want to simulate (e.g., `Bottleneck`, `SE_layer`):

      ```bash
      cd Hardware/<Module_Name>/
      ```
   2. Run the simulation script:

      ```bash
      vsim -do <script_name>.do
      ```

---

## 📌 Future Work

* Extend hardware modules for broader neural architectures
* Improve software integration with cloud inference services

---

## 🙏 Acknowledgments

* **[Analog Devices Egypt](https://www.analog.com)** – For invaluable mentorship and technical support ([linkedin.com][1], [analog.com][2])
* **[Dr. Mohammed Sharaf (EJUST)](https://academic-profile.ejust.edu.eg/profile/M-Sharaf)** – For his guidance and dedicated supervision ([linkedin.com][1])
* [**Xilinx Vivado**](https://www.xilinx.com) – FPGA development tool suite
* [**Kaggle**](https://www.kaggle.com) – Dataset hosting and access platform
* [**Gradio**](https://www.gradio.app) – Framework for interactive ML user interfaces



## 📜 License

Licensed under the **MIT License**. See the [LICENSE](LICENSE) file for details.

---
