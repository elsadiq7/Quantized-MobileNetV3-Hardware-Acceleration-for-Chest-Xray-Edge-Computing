import os
from concurrent.futures import ProcessPoolExecutor, as_completed

import cv2
import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
from sklearn.model_selection import train_test_split
from tensorflow.keras.preprocessing.image import ImageDataGenerator
from tqdm import tqdm
# Configuration
AUG_FOLDER = 'data/augmentation_photos'
CLASS_LIMIT = 6000  # Target samples per class
RANDOM_STATE = 42
LABEL_MAPPING = {
    'No Finding': 0, 'Infiltration': 1, 'Atelectasis': 2, 
    'Effusion': 3, 'Nodule': 4, 'Pneumothorax': 5, 'Mass': 6,
    'Consolidation': 7, 'Pleural_Thickening': 8, 'Cardiomegaly': 9,
    'Emphysema': 10, 'Fibrosis': 11, 'Edema': 12, 'Pneumonia': 13, 'Hernia': 14
}

def validate_dataframe(df, required_columns):
    """Ensure DataFrame contains required columns and data"""
    if not isinstance(df, pd.DataFrame) or df.empty:
        raise ValueError("Invalid or empty DataFrame")
    missing = set(required_columns) - set(df.columns)
    if missing:
        raise KeyError(f"Missing columns: {missing}")
    return df

def load_and_filter_data():
    """Load and balance dataset by sampling up to CLASS_LIMIT examples per class."""
    try:
        df = pd.read_csv('data/processed_entries.csv')
        df = validate_dataframe(df, ['Finding Labels', 'Image Path'])
        
        # Get all unique classes (including 'No Finding')
        unique_classes = df['Finding Labels'].unique()
        sampled_dfs = []
        
        for cls in unique_classes:
            cls_df = df[df['Finding Labels'] == cls]
            # Sample up to CLASS_LIMIT, but don't upsample if fewer samples exist
            n_samples = min(len(cls_df), CLASS_LIMIT)
            sampled_cls = cls_df.sample(n=n_samples, random_state=RANDOM_STATE)
            sampled_dfs.append(sampled_cls)
        
        # Combine and shuffle
        balanced_df = pd.concat(sampled_dfs, ignore_index=True)
        balanced_df = balanced_df.sample(frac=1, random_state=RANDOM_STATE)
        
        return balanced_df
    except Exception as e:
        print(f"Data loading failed: {str(e)}")
        raise

def create_augmenter():
    """Configure image augmentation pipeline"""
    return ImageDataGenerator(
        width_shift_range=0.05,
        height_shift_range=0.05,
        brightness_range=[0.8, 1.2],
        zoom_range=0.1,
        fill_mode='nearest'
    )

def apply_custom_augmentations(image):
    """Apply additional transformations to images"""
    if np.random.rand() > 0.7:
        image = cv2.GaussianBlur(image, (5, 5), 0)
    if np.random.rand() > 0.7:
        alpha = np.random.uniform(0.9, 1.1)
        beta = np.random.randint(-10, 10)
        image = cv2.convertScaleAbs(image, alpha=alpha, beta=beta)
    return image

def process_image(args):
    """Process single image augmentation with immediate saving"""
    label, path, save_prefix = args
    try:
        # Load image
        image = cv2.imread(path)
        if image is None:
            raise ValueError(f"Failed to read image: {path}")
        image = cv2.cvtColor(image, cv2.COLOR_BGR2RGB)
        
        # Initialize augmenter
        augmenter = create_augmenter()
        
        # Apply transformations and save
        augmented = augmenter.random_transform(image)
        augmented = apply_custom_augmentations(augmented)
        
        save_path = os.path.join(AUG_FOLDER, f"{save_prefix}.png")
        cv2.imwrite(save_path, cv2.cvtColor(augmented, cv2.COLOR_RGB2BGR))
        
        return [{
            'Image Index': save_prefix,
            'Finding Labels': label,
            'Image Path': save_path
        }]
    except Exception as e:
        print(f"Error processing {path}: {str(e)}")
        return []

def augment_data(final_df):
    """Perform parallel data augmentation with per-image processing"""
    os.makedirs(AUG_FOLDER, exist_ok=True)
    class_counts = final_df['Finding Labels'].value_counts()
    tasks = []
    augmented_count = {}

    # Prepare tasks for each needed augmentation
    for label, count in class_counts.items():
        if count < CLASS_LIMIT:
            needed = CLASS_LIMIT - count
            class_data = final_df[final_df['Finding Labels'] == label]
            total_original = len(class_data)
            
            # Distribute augmentations evenly across original images
            per_image = max(1, needed // total_original)
            remainder = needed % total_original
            
            for idx, (_, row) in enumerate(class_data.iterrows()):
                extra = 1 if idx < remainder else 0
                total_aug = per_image + extra
                for aug_num in range(total_aug):
                    tasks.append((
                        label,
                        row['Image Path'],
                        f"aug_{label}_{idx}_{aug_num}"
                    ))

    # Execute tasks in parallel
    augmented = []
    with ProcessPoolExecutor(max_workers=os.cpu_count()) as executor:
        futures = [executor.submit(process_image, task) for task in tasks]
        for future in tqdm(as_completed(futures), total=len(futures), desc="Augmenting"):
            result = future.result()
            if result:
                augmented.extend(result)
    
    return pd.DataFrame(augmented)

def visualize_distribution(df, title):
    """Plot class distribution with styling"""
    counts = df['Finding Labels'].value_counts()
    plt.figure(figsize=(12, 6))
    ax = counts.plot(kind='bar', color='skyblue')
    plt.title(title, fontsize=14)
    plt.xlabel('Diagnosis', fontsize=12)
    plt.ylabel('Count', fontsize=12)
    plt.xticks(rotation=45, ha='right', fontsize=10)
    
    # Add data labels
    for p in ax.patches:
        ax.annotate(f"{p.get_height():,}", 
                   (p.get_x() + p.get_width() / 2., p.get_height()),
                   ha='center', va='center', 
                   xytext=(0, 5), textcoords='offset points',
                   fontsize=8)
    plt.tight_layout()
    plt.show()

def main_pipeline():
    try:
        # Data loading and balancing
        final_df = load_and_filter_data()
        visualize_distribution(final_df, "Initial Class Distribution")

        # Data augmentation
        augmented_df = augment_data(final_df)
        if not augmented_df.empty:
            final_df = pd.concat([final_df, augmented_df], ignore_index=True).sample(frac=1, random_state=RANDOM_STATE)
        
        # Final balancing
        final_df = final_df.groupby('Finding Labels').apply(lambda x: x.sample(CLASS_LIMIT, replace=True,          random_state=RANDOM_STATE)).reset_index(drop=True)
        final_df.to_csv('data/entry_balanced.csv', index=False)
        visualize_distribution(final_df, "Balanced Class Distribution")

        # Data splitting
        final_df['Encoded'] = final_df['Finding Labels'].map(LABEL_MAPPING)
        train, test_val = train_test_split(final_df, test_size=0.2, stratify=final_df['Encoded'], random_state=RANDOM_STATE)
        val, test = train_test_split(test_val, test_size=0.5, stratify=test_val['Encoded'], random_state=RANDOM_STATE)

        # Save splits
        for name, df in [('train', train), ('val', val), ('test', test)]:
            df[['Image Path', 'Encoded']].to_csv(f'data/{name}_full.txt', index=False, header=False, sep=' ')
            df.sample(frac=0.3, random_state=RANDOM_STATE)[['Image Path', 'Encoded']].to_csv(f'data/{name}_sampled.txt', index=False, header=False, sep=' ')

        print("Pipeline completed successfully!")
        return True

    except Exception as e:
        print(f"Pipeline failed: {str(e)}")
        return False


def plot_image_samples(df, sample_size=10):
    """
    Display a 2D grid of sample images from the DataFrame with their labels.
    
    Parameters:
    - df (pd.DataFrame): DataFrame containing image paths and labels.
    - sample_size (int): Number of images to display in the grid.
    """
    # Randomly select a sample from the DataFrame
    sample_df = df.sample(n=sample_size, random_state=42)
    
    # Calculate the number of rows and columns for the 2D grid
    cols = int(np.ceil(np.sqrt(sample_size)))  # Number of columns
    rows = int(np.ceil(sample_size / cols))    # Number of rows
    
    # Set up the plot with the calculated rows and columns
    fig, axes = plt.subplots(rows, cols, figsize=(15, 15))
    axes = axes.ravel()  # Flatten axes array to simplify indexing
    
    for i, (idx, row) in enumerate(sample_df.iterrows()):
        # Load and convert the image to RGB
        image = cv2.imread(row['Image Path'])
        if image is not None:
            image = cv2.cvtColor(image, cv2.COLOR_BGR2RGB)
        else:
            image = np.zeros((64, 64, 3), dtype=np.uint8)  # Placeholder if image not found
        
        # Plot image in the grid
        axes[i].imshow(image)
        axes[i].axis('off')
        axes[i].set_title(row['Finding Labels'])
    
    # Hide any unused axes in the grid
    for j in range(i + 1, len(axes)):
        axes[j].axis('off')
    
    plt.tight_layout()
    plt.show()



def augmentation_spiliting():
    if main_pipeline():
         df = pd.read_csv('data/entry_balanced.csv')
         plot_image_samples(df, 20)
    else:
        print("Pipeline execution failed. Check error messages.")