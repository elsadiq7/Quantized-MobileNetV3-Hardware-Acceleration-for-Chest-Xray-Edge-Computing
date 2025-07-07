import gradio as gr
import torch
import torch.nn as nn
from torchvision import transforms
from PIL import Image
import plotly.graph_objects as go
from utils.data_loaders import data_loaders
from utils.models import MobileNetV3_Small

train_loader, val_loader, test_loader=data_loaders()
device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
print(f"Using device: {device}")
model = MobileNetV3_Small(in_channels=1, num_classes=15)
model.load_state_dict(torch.load("models/mobilenetv3_small_best_v2_0.pth"))

# Define image transformation
transform = transforms.Compose([
        transforms.Resize(target_size),
        transforms.ToTensor(),
        transforms.Normalize(mean=[0.485], std=[0.229])  # Grayscale stats
    ])

# Label mapping with emojis
label_mapping = {
    0: 'No Finding 🩺',
    1: 'Infiltration 🌫️',
    2: 'Atelectasis 🫁',
    3: 'Effusion 💧',
    4: 'Nodule 🔬',
    5: 'Pneumothorax 🫁❌',
    6: 'Mass ⚪',
    7: 'Consolidation 🫁🩸',
    8: 'Pleural Thickening 🧱',
    9: 'Cardiomegaly ❤️',
    10: 'Emphysema 💨',
    11: 'Fibrosis 🧵',
    12: 'Edema 🌊',
    13: 'Pneumonia 🤒',
    14: 'Hernia 🩻'
}


# Define prediction function
def predict(image):
    image = transform(image).unsqueeze(0).to(device)  # Add batch dimension
    with torch.no_grad():
        output = model(image)
        probabilities = torch.nn.functional.softmax(output[0], dim=0)
    top5_prob, top5_classes = torch.topk(probabilities, 5)

    # Generate text output with bolded predicted class
    predicted_class = label_mapping[top5_classes[0].item()]
    predicted_confidence = top5_prob[0].item()
    text_output = f"Predicted Class: {predicted_class}\nConfidence: {predicted_confidence:.2f}\n\n"

    # Bar chart data
    labels = [label_mapping[top5_classes[i].item()] for i in range(5)]
    confidences = [top5_prob[i].item() for i in range(5)]
    bar_chart = go.Figure(
        data=[go.Bar(x=labels, y=confidences, text=[f"{c:.2f}" for c in confidences], textposition='auto')],
        layout_title_text="Top 5 Predictions"
    )
    bar_chart.update_layout(yaxis_title="Confidence", xaxis_title="Classes")

    return text_output, bar_chart


# Define function to clear input and predictions
def clear_all():
    return None, "", None


import gradio as gr

with gr.Blocks() as demo:
    # Add Analog Devices Logo with custom styling
    gr.Image("ADI_LOGO.png", elem_id="logo", show_label=False)

    # Add title and dataset info
    gr.Markdown("# Enhanced MobileNet Image Classifier")
    gr.Markdown("""  
    **This model uses the NIH Chest X-ray dataset to classify chest X-ray images.**  
    """)

    with gr.Row():
        with gr.Column():
            image_input = gr.Image(label="Upload Image", type="pil", interactive=True)
        with gr.Column():
            output_text = gr.Text(label="Prediction Output", interactive=False)
            bar_chart_output = gr.Plot(label="Top 5 Predictions Chart")

    with gr.Row():
        predict_button = gr.Button("Predict", interactive=False)  # Initially disabled
        clear_button = gr.Button("Clear")

    # Enable the Predict button only when an image is uploaded
    image_input.change(fn=lambda x: gr.update(interactive=True) if x else gr.update(interactive=False), inputs=[image_input], outputs=[predict_button])

    # Define button interactions
    predict_button.click(fn=predict, inputs=[image_input], outputs=[output_text, bar_chart_output])
    clear_button.click(fn=clear_all, inputs=[], outputs=[image_input, output_text, bar_chart_output])

    # Custom CSS for logo positioning and size
    demo.css = """
    #logo {
        position: absolute;
        top: 10px;
        right: 10px;
        width: 100px;
        height: 100px;
    }
    """

# Launch the app
demo.launch()
