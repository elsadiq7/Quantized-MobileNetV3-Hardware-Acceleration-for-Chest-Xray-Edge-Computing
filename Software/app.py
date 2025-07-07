import gradio as gr
import torch
import torch.nn as nn
from torchvision import transforms
from PIL import Image
import plotly.graph_objects as go
from utils.data_loaders import data_loaders
from utils.models import MobileNetV3_Small
import os
import cv2
import numpy as np
from torchvision.transforms import ToPILImage

# -------------------------
# Dummy NLP recommender
# -------------------------
def generate_patient_recommendation(label, confidence):
    recommendations = {
        'No Finding 🩺': "The X-ray appears normal. Continue regular health checkups.",
        'Infiltration 🌫️': "Possible fluid or infection in lungs. Consult a pulmonologist.",
        'Atelectasis 🫁': "Partial lung collapse suspected. Immediate evaluation is advised.",
        'Effusion 💧': "Fluid around lungs detected. You should see a physician promptly.",
        'Nodule 🔬': "A small spot was found. Further imaging or biopsy may be required.",
        'Pneumothorax 🫁❌': "Air in lung cavity. This could be urgent – seek ER care.",
        'Mass ⚪': "Abnormal tissue detected. Specialist referral is needed.",
        'Consolidation 🫁🩸': "Signs of infection or pneumonia. Medical evaluation required.",
        'Pleural Thickening 🧱': "Scarring detected. Monitor regularly with your doctor.",
        'Cardiomegaly ❤️': "Heart appears enlarged. Cardiologist follow-up recommended.",
        'Emphysema 💨': "Signs of chronic lung disease. Pulmonary care advised.",
        'Fibrosis 🧵': "Lung scarring seen. Long-term monitoring may be needed.",
        'Edema 🌊': "Fluid buildup in lungs. Heart function check is essential.",
        'Pneumonia 🤒': "Infection detected. Prompt antibiotic treatment recommended.",
        'Hernia 🩻': "Possible diaphragm hernia. Consult a surgeon for evaluation."
    }
    guidance = recommendations.get(label, "Please consult your healthcare provider.")
    return f"**Interpretation:** {label}\n**Confidence:** {confidence:.2f}\n**Recommendation:** {guidance}"

# -------------------------
# Grad-CAM dummy overlay
# -------------------------
def generate_gradcam(model, image_tensor, class_idx):
    heatmap = torch.rand(1, 224, 224)
    heatmap = heatmap.squeeze().cpu().numpy()
    heatmap = (heatmap - heatmap.min()) / (heatmap.max() - heatmap.min())
    heatmap = cv2.resize(heatmap, (224, 224))
    heatmap = np.uint8(255 * heatmap)
    heatmap_color = cv2.applyColorMap(heatmap, cv2.COLORMAP_JET)

    input_img = image_tensor.squeeze().cpu().numpy()
    input_img = (input_img * 0.229 + 0.485) * 255
    input_img = np.uint8(input_img)
    input_img = cv2.cvtColor(input_img, cv2.COLOR_GRAY2BGR)

    overlay = cv2.addWeighted(input_img, 0.6, heatmap_color, 0.4, 0)
    return ToPILImage()(torch.tensor(overlay).permute(2, 0, 1))

# -------------------------
# Load model
# -------------------------
device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
model = MobileNetV3_Small(in_channels=1, num_classes=15).to(device)
model.load_state_dict(torch.load("Software/models/mobilenetv3_small_best_v2_0.pth", map_location=device))
model.eval()

# -------------------------
# Transform
# -------------------------
transform = transforms.Compose([
    transforms.Resize((224, 224)),
    transforms.ToTensor(),
    transforms.Normalize(mean=[0.485], std=[0.229])
])

# -------------------------
# Labels
# -------------------------
label_mapping = {
    0: 'No Finding 🩺', 1: 'Infiltration 🌫️', 2: 'Atelectasis 🫁', 3: 'Effusion 💧',
    4: 'Nodule 🔬', 5: 'Pneumothorax 🫁❌', 6: 'Mass ⚪', 7: 'Consolidation 🫁🩸',
    8: 'Pleural Thickening 🧱', 9: 'Cardiomegaly ❤️', 10: 'Emphysema 💨',
    11: 'Fibrosis 🧵', 12: 'Edema 🌊', 13: 'Pneumonia 🤒', 14: 'Hernia 🩻'
}

# -------------------------
# Prediction logic
# -------------------------
def predict_with_explanation(image):
    gray_image = image.convert("L")
    image_tensor = transform(gray_image).unsqueeze(0).to(device)

    with torch.no_grad():
        output = model(image_tensor)
        probs = torch.nn.functional.softmax(output[0], dim=0)
        top5_prob, top5_classes = torch.topk(probs, 5)

    pred_class_idx = top5_classes[0].item()
    pred_label = label_mapping[pred_class_idx]
    confidence = top5_prob[0].item()

    explanation = generate_patient_recommendation(pred_label, confidence)

    labels = [label_mapping[i.item()] for i in top5_classes]
    confidences = [p.item() for p in top5_prob]
    bar_chart = go.Figure(data=[go.Bar(x=labels, y=confidences, text=[f"{c:.2f}" for c in confidences], textposition='auto')],
                          layout_title_text="Top 5 Predictions")
    bar_chart.update_layout(yaxis_title="Confidence", xaxis_title="Classes")

    gradcam_image = generate_gradcam(model, image_tensor, pred_class_idx)

    return explanation, bar_chart, gradcam_image

# -------------------------
# Clear UI
# -------------------------
def clear_all():
    return None, "", None, None

# -------------------------
# Export report
# -------------------------
def export_report(image, prediction_text):
    image.save("input_image.png")
    with open("report.txt", "w") as f:
        f.write(prediction_text)
    return "report.txt"

# -------------------------
# Enable Predict Button Logic
# -------------------------
def enable_predict_button(img):
    return gr.update(interactive=img is not None)

# -------------------------
# Gradio UI
# -------------------------
with gr.Blocks(theme=gr.themes.Base(primary_hue="blue"), css="""
#logo {
    position: absolute;
    top: 10px;
    right: 10px;
    width: 100px;
    height: 100px;
}
""") as demo:

    gr.Image("Software/utils/ADI_LOGO.png", elem_id="logo", show_label=False)
    gr.Markdown("# 🩻 Chest X-ray Classifier with Patient Guidance")
    gr.Markdown("Upload a chest X-ray. This model predicts 15 conditions and gives you a recommended action.")

    with gr.Row():
        with gr.Column():
            image_input = gr.Image(label="Upload Image", type="pil")
            predict_btn = gr.Button("Predict", interactive=True)
            clear_btn = gr.Button("Clear")
        with gr.Column():
            output_text = gr.Markdown()
            bar_output = gr.Plot()
            gradcam_output = gr.Image(label="Grad-CAM Explanation", type="pil")

    with gr.Row():
        download_btn = gr.Button("Download Report")
        file_output = gr.File()

    with gr.Accordion("📚 Class Label Descriptions", open=False):
        gr.Markdown("\n".join([f"**{i}**: {label}" for i, label in label_mapping.items()]))

    # Logic wiring
    image_input.change(fn=enable_predict_button, inputs=image_input, outputs=predict_btn)
    predict_btn.click(fn=predict_with_explanation, inputs=[image_input],
                      outputs=[output_text, bar_output, gradcam_output])
    clear_btn.click(fn=clear_all, outputs=[image_input, output_text, bar_output, gradcam_output])
    download_btn.click(fn=export_report, inputs=[image_input, output_text], outputs=[file_output])

# -------------------------
# Launch app
# -------------------------
demo.launch()
