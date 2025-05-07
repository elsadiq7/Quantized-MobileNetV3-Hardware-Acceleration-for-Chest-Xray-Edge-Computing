import os
import json
import time
import logging
from tqdm import tqdm
import torch
import torch.optim as optim
from torch.utils.tensorboard import SummaryWriter
from torch.cuda.amp import autocast, GradScaler
from torch.optim.lr_scheduler import ReduceLROnPlateau
import torch
import numpy as np
from sklearn.metrics import accuracy_score, f1_score, classification_report
import matplotlib.pyplot as plt
import os
import time
import json
import logging
from tqdm import tqdm
from torch.optim import AdamW, SGD
from torch.optim.lr_scheduler import OneCycleLR
from torch.cuda.amp import GradScaler
from torch.utils.tensorboard import SummaryWriter
import torch


def train_and_save_models(
    initialized_models,
    train_loader,
    val_loader,
    version,
    histories=None,
    output_dir='models_sampled',
    plots_dir='plots_sampled',
    epochs=10,
    patience=5,
    learning_rate=1e-4,
    weight_decay=1e-2,
    histories_file='training_histories.json',
    device=None
):
    """
    Train models with TensorFlow-style single-line epoch reporting and tqdm batch progress.
    """
    # Setup directories and logging
    os.makedirs(output_dir, exist_ok=True)
    os.makedirs(plots_dir, exist_ok=True)
    
    logging.basicConfig(
        filename=os.path.join(output_dir, "training.log"),
        filemode='w',
        format='%(asctime)s - %(levelname)s - %(message)s',
        level=logging.INFO
    )
    
    if histories is None:
        histories = {}

    # Main training loop
    for model_name, model in initialized_models.items():
        print(f"\n\033[1mTraining {model_name}\033[0m")
        logging.info(f"\n{'='*50}\nTraining {model_name}\n{'='*50}")
        
        # Training setup
        optimizer = optim.AdamW(model.parameters(), lr=learning_rate, weight_decay=weight_decay)
        scheduler = ReduceLROnPlateau(optimizer, mode='min', factor=0.5, patience=2)
        criterion = torch.nn.CrossEntropyLoss()
        scaler = GradScaler()
        model.to(device)
        
        # History tracking
        history = {
            'train_loss': [], 'train_acc': [],
            'val_loss': [], 'val_acc': [],
            'epoch_times': [], 'lr_history': []
        }
        
        best_val_loss = float('inf')
        patience_counter = 0
        writer = SummaryWriter(log_dir=os.path.join(output_dir, f"tensorboard/{model_name}"))

        # Epoch loop
        for epoch in range(epochs):
            start_time = time.time()
            model.train()
            train_loss, correct, total = 0.0, 0, 0
            
            # Batch progress with tqdm
            batch_pbar = tqdm(
                train_loader,
                desc=f"Epoch {epoch+1}/{epochs}",
                leave=False,
                bar_format='{l_bar}{bar:20}{r_bar}{bar:-20b}'
            )
            
            for inputs, targets in batch_pbar:
                inputs, targets = inputs.to(device), targets.to(device)
                
                # Forward/backward pass
                optimizer.zero_grad()
                with torch.amp.autocast('cuda'):
                    outputs = model(inputs)
                    loss = criterion(outputs, targets)
                scaler.scale(loss).backward()
                scaler.step(optimizer)
                scaler.update()
                
                # Update metrics
                _, predicted = torch.max(outputs, 1)
                total += targets.size(0)
                correct += (predicted == targets).sum().item()
                train_loss += loss.item()
                
                # Update batch progress
                batch_pbar.set_postfix({
                    'loss': f"{loss.item():.4f}",
                    'acc': f"{100*correct/total:.1f}%"
                })

            # Calculate epoch metrics
            train_acc = 100 * correct / total
            avg_train_loss = train_loss / len(train_loader)
            
            # Validation
            val_loss, val_correct, val_total = 0.0, 0, 0
            model.eval()
            with torch.no_grad():
                for inputs, targets in val_loader:
                    inputs, targets = inputs.to(device), targets.to(device)
                    with torch.amp.autocast('cuda'):
                       outputs = model(inputs)
                       loss = criterion(outputs, targets)
                    _, predicted = torch.max(outputs, 1)
                    val_total += targets.size(0)
                    val_correct += (predicted == targets).sum().item()
                    val_loss += loss.item()
            
            val_acc = 100 * val_correct / val_total
            avg_val_loss = val_loss / len(val_loader)
            current_lr = optimizer.param_groups[0]['lr']
            epoch_time = time.time() - start_time
            
            # Update history
            history['train_loss'].append(avg_train_loss)
            history['train_acc'].append(train_acc)
            history['val_loss'].append(avg_val_loss)
            history['val_acc'].append(val_acc)
            history['epoch_times'].append(epoch_time)
            history['lr_history'].append(current_lr)
            
            # TensorFlow-style epoch reporting
            print(f"Epoch {epoch+1}/{epochs} "
                  f"[{int(epoch_time)//60}m {int(epoch_time)%60}s] "
                  f"loss: {avg_train_loss:.4f} - accuracy: {train_acc:.2f}% "
                  f"- val_loss: {avg_val_loss:.4f} - val_accuracy: {val_acc:.2f}% "
                  f"- lr: {current_lr:.2e}")
            
            # Logging and TensorBoard
            logging.info(
                f"Epoch {epoch+1}/{epochs} | "
                f"Train Loss: {avg_train_loss:.4f} | Train Acc: {train_acc:.2f}% | "
                f"Val Loss: {avg_val_loss:.4f} | Val Acc: {val_acc:.2f}% | "
                f"LR: {current_lr:.2e} | Time: {epoch_time:.2f}s"
            )
            writer.add_scalars('Loss', {'train': avg_train_loss, 'val': avg_val_loss}, epoch)
            writer.add_scalars('Accuracy', {'train': train_acc, 'val': val_acc}, epoch)
            writer.add_scalar('Learning Rate', current_lr, epoch)
            
            # Early stopping
            if avg_val_loss < best_val_loss:
                best_val_loss = avg_val_loss
                patience_counter = 0
                torch.save(
                    model.state_dict(),
                    os.path.join(output_dir, f'{model_name}_best_{version}_{epoch}.pth')
                )
            else:
                patience_counter += 1
                if patience_counter >= patience:
                    print(f"\nEarly stopping at epoch {epoch+1}")
                    logging.info(f"Early stopping triggered at epoch {epoch+1}")
                    break
            
            scheduler.step(avg_val_loss)
        
        # Save history
        histories[model_name] = history
        with open(histories_file, 'w') as f:
            json.dump(histories, f, indent=4)
        
        writer.close()
        print(f"\nFinished training {model_name}")
    
    return histories


def plot_training_metrics(metrics_dict, model_name='mobilenetv3_small'):
    data = metrics_dict[model_name]
    epochs = list(range(1, len(data['train_loss']) + 1))

    # Plot Loss
    plt.figure(figsize=(12, 5))
    plt.subplot(1, 2, 1)
    plt.plot(epochs, data['train_loss'], label='Train Loss')
    plt.plot(epochs, data['val_loss'], label='Validation Loss')
    plt.xlabel('Epoch')
    plt.ylabel('Loss')
    plt.title(f'{model_name} - Loss per Epoch')
    plt.legend()
    plt.grid(True)

    # Plot Accuracy
    plt.subplot(1, 2, 2)
    plt.plot(epochs, data['train_acc'], label='Train Accuracy')
    plt.plot(epochs, data['val_acc'], label='Validation Accuracy')
    plt.xlabel('Epoch')
    plt.ylabel('Accuracy (%)')
    plt.title(f'{model_name} - Accuracy per Epoch')
    plt.legend()
    plt.grid(True)

    plt.tight_layout()
    plt.show()

    # Optional: Plot Learning Rate and Epoch Times
    plt.figure(figsize=(12, 4))
    plt.subplot(1, 2, 1)
    plt.plot(epochs, data['lr_history'], label='Learning Rate', color='purple')
    plt.xlabel('Epoch')
    plt.ylabel('LR')
    plt.title(f'{model_name} - Learning Rate per Epoch')
    plt.grid(True)

    plt.subplot(1, 2, 2)
    plt.plot(epochs, data['epoch_times'], label='Epoch Time (s)', color='orange')
    plt.xlabel('Epoch')
    plt.ylabel('Time (seconds)')
    plt.title(f'{model_name} - Epoch Duration')
    plt.grid(True)

    plt.tight_layout()
    plt.show()

def evaluate_model(model, test_loader, device='cuda'):
    model.eval()  # Set the model to evaluation mode
    
    all_preds = []
    all_labels = []

    # Loop over the test data batches
    with torch.no_grad():
        for images, labels in test_loader:
            images, labels = images.to(device), labels.to(device)

            # Ensure input is in float32 to match the model's bias type
            with torch.amp.autocast(device_type='cuda'):
              images = images.float()

              # Forward pass
              outputs = model(images)

            # Get the predicted class labels (argmax)
            _, predicted_classes = torch.max(outputs, 1)

            all_preds.append(predicted_classes.cpu().numpy())
            all_labels.append(labels.cpu().numpy())

    # Convert predictions and labels to numpy arrays
    all_preds = np.concatenate(all_preds, axis=0)
    all_labels = np.concatenate(all_labels, axis=0)

    # Calculate accuracy
    accuracy = accuracy_score(all_labels, all_preds)

    # Calculate F1 score
    f1 = f1_score(all_labels, all_preds, average='weighted')

    # Generate classification report
    report = classification_report(all_labels, all_preds)

    return accuracy, f1, report
