import os
import json
import zipfile

def install_kaggle():
    """Install Kaggle API if not already installed"""
    os.system('pip install kaggle')

def configure_kaggle_credentials(credentials_path='kaggle_credentials.json'):
    """
    Configure Kaggle API credentials from external file
    Returns True if successful, False otherwise
    """
    try:
        with open(credentials_path) as f:
            credentials = json.load(f)
            
        kaggle_dir = os.path.expanduser('~/.kaggle')
        os.makedirs(kaggle_dir, exist_ok=True)
        
        with open(os.path.join(kaggle_dir, 'kaggle.json'), 'w') as f:
            json.dump(credentials, f)
            
        os.chmod(os.path.join(kaggle_dir, 'kaggle.json'), 0o600)
        return True
    except Exception as e:
        print(f"Error configuring credentials: {str(e)}")
        return False

def download_dataset(dataset='nih-chest-xrays/data', download_path='./'):
    """Download dataset using Kaggle API"""
    command = f'kaggle datasets download -d {dataset} -p {download_path} --force'
    exit_code = os.system(command)
    return exit_code == 0

def extract_dataset(zip_path='./data.zip', extract_dir='./data/'):
    """Extract dataset and clean up"""
    try:
        os.makedirs(extract_dir, exist_ok=True)
        with zipfile.ZipFile(zip_path, 'r') as zip_ref:
            zip_ref.extractall(extract_dir)
        os.remove(zip_path)
        return True
    except Exception as e:
        print(f"Error extracting dataset: {str(e)}")
        return False

def download_extract_data():
    # Install dependencies
    #install_kaggle()
    
    # Configure credentials
    if not configure_kaggle_credentials():
        return
    
    # Download dataset
    if not download_dataset():
        print("Failed to download dataset")
        return
    
    # Extract and clean up
    if extract_dataset():
        print("Dataset successfully downloaded and extracted!")
    else:
        print("Failed to extract dataset")

