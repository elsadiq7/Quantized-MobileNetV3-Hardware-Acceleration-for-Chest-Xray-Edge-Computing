
# 🔧 Project Overview

This repository presents a complete system integrating **FPGA-based hardware modules** and **Python-based software utilities** to accelerate and interact with deep learning models—specifically for tasks like image classification.

---

## 📁 Repository Structure

### 🛠️ Hardware (`/Hardware`)
FPGA-centric modules, implemented using Verilog and synthesized with **Xilinx Vivado**.

- **Bottleneck Layer** – Efficient bottleneck modules for deep networks.
- **Depthwise Convolution** – Optimized using Winograd algorithms.
- **SE Layer** – Implements Squeeze-and-Excitation mechanisms.
- **Top Module** – Top-level integration with synthesis/configuration scripts.
- **Vivado Projects** – Project files and logs for FPGA synthesis.

### 💻 Software (`/Software`)
Python tools for data pipelines and user interaction.

- **Gradio UI** – Interactive interface for predictions and explanations.
- **Dataset Management** – Scripts to download and prepare datasets.
- **Kaggle Integration** – Automated dataset access from Kaggle.

---

## 🚀 Key Features

### 🔩 Hardware
- **FPGA Implementation** with Xilinx Vivado (tested on **2019.2**).
- **Optimized Layers**: Depthwise convolution, bottleneck, and SE modules.

### 🧰 Software
- **Automated Dataset Handling**: Download, extract, and preprocess datasets.
- **Gradio Interface**: Simple web UI for model inference and visualization.

---

## ⚙️ Getting Started

### ✅ Prerequisites

- **Hardware**: Xilinx Vivado (2019.2 or compatible)
- **Software**: Python 3.x  
  Install required packages:
  ```bash
  pip install -r requirements.txt ````

---

### 📦 Setup Instructions

1. **Clone the repository**:

   ```bash
   git clone <repository-url>
   cd <repository-directory>
   ```

2. **Install dependencies**:

   ```bash
   pip install -r requirements.txt
   ```

3. **Kaggle credentials setup**:

   * Place `kaggle.json` in:

     * Linux/Mac: `~/.kaggle/`
     * Windows: `C:\Users\<User>\.kaggle\`
   * Set permissions:

     ```bash
     chmod 600 ~/.kaggle/kaggle.json
     ```

4. **Download dataset**:

   ```bash
   python Software/download_dataset.py
   ```

5. **Open Vivado project**:

   * Navigate to:

     ```bash
     cd Hardware/project_1/
     ```
   * Launch `.xpr` file in Vivado and follow synthesis flow.

6. **Run the Gradio UI**:

   ```bash
   python Software/app.py
   ```

---

## 📄 Logs and Outputs

* **Vivado Logs** – Found in each Vivado project directory (e.g., `vivado.log`)
* **Dataset Logs** – Output printed during data handling steps

---

## 📌 Future Work

* Extend hardware modules for broader neural architectures
* Improve software integration with cloud inference services

---

## 📜 License

Licensed under the **MIT License**. See the [LICENSE](LICENSE) file for details.

---

## 🙏 Acknowledgments

* [Xilinx Vivado](https://www.xilinx.com) – FPGA development tools
* [Kaggle](https://www.kaggle.com) – Dataset hosting
* [Gradio](https://www.gradio.app) – Interactive ML UI framework
