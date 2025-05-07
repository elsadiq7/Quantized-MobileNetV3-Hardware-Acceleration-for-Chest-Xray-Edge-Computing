import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
import os
import glob
from textwrap import wrap

# ---------------------------
# Formatting Utilities
# ---------------------------

def print_header(title, width=60):
    print(f"\n{'=' * width}")
    print(f"{title.upper():^{width}}")
    print(f"{'=' * width}")

def print_step(message, emoji="➡️"):
    print(f"\n{emoji} {message}...")

def format_number(number):
    return f"{number:,}"

# ---------------------------
# Data Processing Pipeline
# ---------------------------

def load_and_process_data(data_dir="data"):
    print_header("Data Loading & Preparation")
    
    print_step("Loading raw datasets")
    try:
        df_bbox = pd.read_csv(f"{data_dir}/BBox_List_2017.csv")
        df_entry = pd.read_csv(f"{data_dir}/Data_Entry_2017.csv")
        
        print("\n📂 Dataset Summary:")
        print(f"- Bounding Box Data: {format_number(len(df_bbox))} rows")
        print(f"- Main Entries Data: {format_number(len(df_entry))} rows")
        print(f"- Original Columns:\n  {df_entry.columns.tolist()}")
        
        return df_bbox, df_entry
    except Exception as e:
        print(f"\n❌ Loading Error: {str(e)}")
        return None, None

def clean_and_filter_data(df_entry):
    print_step("Cleaning and filtering data", "🧹")
    
    # Clean data
    df_clean = df_entry.iloc[:, :-1]
    filtered = df_clean[~df_clean["Finding Labels"].str.contains("\|")]
    filtered.reset_index(drop=True, inplace=True)
    
    # Print cleaning report
    print("\n🧼 Cleaning Report:")
    print(f"- Original entries: {format_number(len(df_entry))}")
    print(f"- Final entries:    {format_number(len(filtered))}")
    print(f"- Removed entries:  {format_number(len(df_entry) - len(filtered))}")
    print(f"- Removed columns:  {df_entry.columns[-1]}")
    
    return filtered

def map_image_paths(df, data_dir="data"):
    print_step("Mapping image paths", "🖼️")
    
    all_images = glob.glob(os.path.join(data_dir, "**", "*.png"), recursive=True)
    path_dict = {os.path.basename(p): p for p in all_images}
    
    df["Image Path"] = df["Image Index"].map(path_dict)
    
    # Print mapping statistics
    print("\n📷 Image Mapping Report:")
    print(f"- Total images found:  {format_number(len(all_images))}")
    print(f"- Successfully mapped: {format_number(df['Image Path'].notnull().sum())}")
    print(f"- Missing images:      {format_number(df['Image Path'].isnull().sum())}")
    
    return df

# ---------------------------
# Visualization
# ---------------------------

def visualize_distribution(df):
    print_header("Data Visualization")
    
    value_counts = df["Finding Labels"].value_counts()
    
    plt.figure(figsize=(14, 7))
    ax = sns.barplot(x=value_counts.index, y=value_counts.values, palette="mako")
    
    # Formatting
    plt.title("\n".join(wrap("Distribution of Medical Findings in Chest X-ray Images", 60)), 
             fontsize=14, pad=20)
    plt.xlabel("Medical Findings", fontsize=12)
    plt.ylabel("Number of Cases", fontsize=12)
    plt.xticks(rotation=45, ha='right', fontsize=10)
    plt.yticks(fontsize=10)
    
    # Add value labels
    for p in ax.patches:
        ax.annotate(f'{format_number(int(p.get_height()))}', 
                    (p.get_x() + p.get_width() / 2., p.get_height()),
                    ha='center', va='center', 
                    xytext=(0, 7), 
                    textcoords='offset points',
                    fontsize=9)

    plt.tight_layout()
    
    # Print distribution summary
    print("\n📈 Distribution Summary:")
    print(f"{'Diagnosis':<25} {'Cases':>10}")
    print("-" * 36)
    for idx, (label, count) in enumerate(value_counts.items()):
        if idx < 5 or idx == len(value_counts)-1:
            print(f"{label:<25} {format_number(count):>10}")
        elif idx == 5:
            print(f"...{'':<21} {'...':>10}")
    
    plt.show()
    return value_counts

# ---------------------------
# Data Saving
# ---------------------------

def save_processed_data(df_entry, df_bbox, output_dir="data"):
    print_header("Data Export")
    
    os.makedirs(output_dir, exist_ok=True)
    entry_path = os.path.join(output_dir, "processed_entries.csv")
    bbox_path = os.path.join(output_dir, "processed_bboxes.csv")
    
    try:
        df_entry.to_csv(entry_path, index=False)
        print(f"\n✅ Entry Data Saved Successfully")
        print(f"   Path: {os.path.abspath(entry_path)}")
        print(f"   Shape: {df_entry.shape[0]} rows x {df_entry.shape[1]} columns")
    except Exception as e:
        print(f"\n❌ Entry Save Error: {str(e)}")
    
    try:
        df_bbox.to_csv(bbox_path, index=False)
        print(f"\n✅ BBox Data Saved Successfully")
        print(f"   Path: {os.path.abspath(bbox_path)}")
        print(f"   Shape: {df_bbox.shape[0]} rows x {df_bbox.shape[1]} columns")
    except Exception as e:
        print(f"\n❌ BBox Save Error: {str(e)}")

# ---------------------------
# Main Execution
# ---------------------------

def dataset_preprocessing():
    print_header("Chest X-ray Analysis Pipeline", 70)
    
    # Load data
    df_bbox, df_entry = load_and_process_data()
    if df_entry is None:
        return
    
    # Process data
    df_filtered = clean_and_filter_data(df_entry)
    df_final = map_image_paths(df_filtered)
    
    # Visualize
    value_counts = visualize_distribution(df_final)
    
    # Save results
    save_processed_data(df_final, df_bbox)
    
    print_header("Pipeline Complete", 70)

