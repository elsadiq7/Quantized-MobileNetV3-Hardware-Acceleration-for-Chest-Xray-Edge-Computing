# 🔧 Project Overview

🚀 **Graduation Project** | FPGA-Based AI Accelerator for Medical Imaging  

Complete system integrating **FPGA hardware modules** and **Python-based software stack** for accelerating deep learning inference in **chest X-ray image classification**.  

> 🛠️ Developed under mentorship of **Analog Devices Digital Team – Cairo** and **Dr. Mohammed Sharaf**.

> [🔗 Project PPT](https://www.canva.com/design/DAGU_Fm6mp4/1G64pP4Juk6iQo0NkmAvOw/edit?utm_content=DAGU_Fm6mp4&utm_campaign=designshare&utm_medium=link2&utm_source=sharebutton)

---

## 📁 Repository Structure
```
├── Hardware/                     # Verilog modules for CNN acceleration
│   ├── Bottleneck_layer/         # MobileNet-style bottlenecks
│   ├── CONST_BOTTEL_FUNC/        # Constants & reusable parameters
│   ├── Final layer/              # Classification output stage
│   ├── First Layer/              # Input processing
│   ├── SE layer/                 # Squeeze-and-Excitation blocks
│   ├── SHORTCUT/                 # Residual connection logic
│   ├── Top module/               # System integration
│   ├── depthwise_conv/           # Depthwise convolution units
│   └── pointwise layer/          # Pointwise (1×1) convolution
│
├── Software/                     # Python tools stack
│   ├── app.py                    # Gradio inference interface
│   ├── memory_files/             # Quantized FPGA memory files
│   ├── models/                   # Trained models & configs
│   ├── utils/                    # Preprocessing & training helpers
│   ├── project_flow.ipynb        # End-to-end ML-to-FPGA pipeline
│   └── training_histories.json   # Training/validation metrics
│
├── README.md                     # Project documentation
└── .gitignore                    # Git exclusions
```

---

## 💻 Software Overview (`/Software`)
Full ML pipeline from data preparation to FPGA deployment.

### 📊 Dataset Preparation
- Downloads/cleans **NIH ChestX-ray14** dataset
- Train/val/test splitting
- Outlier removal & image augmentation

### 🧠 Model Training
- Lightweight **MobileNetV3-Small** based CNN
- Tracks training/validation performance
- Achieved an F1-score of 82% on the target dataset.
- Classifies **14 chest conditions** + **"No Finding"**

#### 🩺 Classification Labels
| Condition                | Medical Guidance                          |
|--------------------------|-------------------------------------------|
| **No Finding**           | Normal X-ray, continue checkups           |
| **Infiltration**         | Possible infection, see pulmonologist     |
| **Atelectasis**          | Partial lung collapse, urgent evaluation  |
| **Effusion**             | Lung fluid, physician visit needed        |
| **Nodule**               | Requires scan/biopsy                      |
| **Pneumothorax**         | **EMERGENCY CARE NEEDED**                 |
| **Mass**                 | Abnormal tissue, specialist consult       |
| **Consolidation**        | Possible pneumonia, doctor consultation   |
| **Pleural Thickening**   | Scarring, requires monitoring             |
| **Cardiomegaly**         | Enlarged heart, cardiologist follow-up    |
| **Emphysema**            | Chronic condition, pulmonary care         |
| **Fibrosis**             | Lung scarring, ongoing monitoring         |
| **Edema**                | Lung fluid, cardiac evaluation            |
| **Pneumonia**            | Infection, immediate antibiotics          |
| **Hernia**               | Possible diaphragm hernia, surgical review|

### ⚙️ Model Quantization & Export
- Applies **Q8.8 fixed-point quantization**
- Generates FPGA-ready **memory files**

### 🖥️ Gradio Interface
- Interactive UI for X-ray predictions

### 🔗 Kaggle Integration
- API access to datasets

---

## 🛠️ Hardware Modules (`/Hardware`)
**Verilog** implementations synthesized with **Xilinx Vivado**:

| Module                 | Functionality                               |
|------------------------|---------------------------------------------|
| **First Layer**        | Input image processing                      |
| **Bottleneck Layer**   | MobileNetV3-style depth reduction/expansion |
| **SE Layer**           | Channel-wise attention blocks               |
| **Depthwise Conv**     | Per-channel lightweight convolution         |
| **Pointwise Layer**    | 1×1 convolution for channel mixing          |
| **SHORTCUT**           | Residual connections                        |
| **Final Layer**        | Classification output                       |
| **CONST_BOTTEL_FUNC**  | Shared constants/parameters                 |
| **Top Module**         | Complete system integration                 |

---

## 📈 Performance Benchmarks
| Metric                       | Value                              |
|------------------------------|------------------------------------|
| **Model Architecture**       | MobileNetV3-Small                  |
| **Training Accuracy**        | 100%                               |
| **Testing Accuracy**         | 82%                                |
| **Quantization Format**      | Fixed-point Q8.8 (INT16)           |
| **Inference Latency (FPGA)** | ~100 ms per image                  |
| **Throughput**               | ~10 FPS                            |
| **Target Device**            | Xilinx FPGA (Vivado Synthesized)   |
| **Application**              | Chest X-ray Classification (NIH14) |

🧮 Quantization preserves performance while enabling **real-time edge inference** (~100ms/image).

---

## 🧠 Significance
Bridges **AI development** and **hardware deployment**:
- ✅ Full-stack from dataset to FPGA
- ✅ Real-time edge inference
- ✅ Quantization-aware for resource-limited devices
- ✅ Medical relevance with real-world data

---

## ⚙️ Getting Started
### ✅ Prerequisites
**Hardware Tools:**
- [Xilinx Vivado 2019.2+](https://www.xilinx.com/support/download)
- [QuestaSim](https://eda.sw.siemens.com/en-US/ic/questa/) 

**Software:**
```bash
pip install -r requirements.txt
```

### 📦 Setup
1. Clone repository:
   ```bash
   git clone <repository-url>
   cd <repo-directory>
   ```

2. Configure Kaggle:
   ```bash
   # Linux/Mac
   chmod 600 ~/.kaggle/kaggle.json
   ```

3. Run ML pipeline:
   ```bash
   jupyter notebook Software/project_flow.ipynb
   ```

4. Launch inference UI:
   ```bash
   python Software/app.py
   ```

5. FPGA workflows:
   ```bash
   # Vivado synthesis
   cd Hardware/Top\ module/
   # Open .xpr in Vivado
  
   # QuestaSim simulation
   cd Hardware/<Module_Name>/
   vsim -do <script_name>.do
   ```

---

## 📌 Future Work
- Extend hardware for broader neural architectures
- Improve cloud inference integration

---

## 🙏 Acknowledgments
- [Analog Devices Egypt](https://www.analog.com)
- [Dr. Mohammed Sharaf (EJUST)](https://academic-profile.ejust.edu.eg/profile/M-Sharaf)
- [Xilinx Vivado](https://www.xilinx.com) - FPGA tools
- [Kaggle](https://www.kaggle.com) - Dataset platform
- [Gradio](https://www.gradio.app) - ML UI framework

## 📜 License
**MIT License** - See [LICENSE](LICENSE)


