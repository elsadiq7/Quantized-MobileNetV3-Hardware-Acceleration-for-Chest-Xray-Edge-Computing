import os
import torch
from torch.utils.data import Dataset, DataLoader
from torchvision import transforms
from PIL import Image
import numpy as np
from typing import Tuple

class ImageLabelDataset(Dataset):
    def __init__(self, file_path: str, target_size: Tuple[int, int] = (224, 224), 
                 transform: transforms.Compose = None):
        """
        PyTorch Dataset for loading images and labels from a file.
        
        Args:
            file_path: Path to text file containing image paths and labels
            target_size: Target resolution for image resizing
            transform: Optional torchvision transforms
        """
        self.file_path = file_path
        self.target_size = target_size
        self.transform = transform
        self.image_paths, self.labels = self._load_data()

    def _load_data(self) -> Tuple[list, np.ndarray]:
        """Load and validate image paths and labels"""
        image_paths = []
        labels = []
        
        try:
            with open(self.file_path, 'r') as f:
                for line in f:
                    try:
                        path, label = line.strip().split()
                        if not os.path.exists(path):
                            raise FileNotFoundError(f"Image {path} not found")
                        image_paths.append(path)
                        labels.append(int(label))
                    except ValueError as e:
                        print(f"Skipping malformed line: {line.strip()} | Error: {e}")
                        
            if not image_paths:
                raise ValueError(f"No valid data found in {self.file_path}")
                
        except Exception as e:
            raise RuntimeError(f"Failed to load data from {self.file_path}: {str(e)}")
            
        return image_paths, np.array(labels, dtype=np.int64)

    def __len__(self) -> int:
        return len(self.image_paths)

    def __getitem__(self, idx: int) -> Tuple[torch.Tensor, int]:
        """Load, transform and return image-label pair"""
        try:
            img_path = self.image_paths[idx]
            label = self.labels[idx]
            
            # Load and convert to grayscale
            image = Image.open(img_path).convert("L")
            
            # Resize if target size specified
            if self.target_size:
                image = image.resize(self.target_size)
            
            # Apply transforms
            if self.transform:
                image = self.transform(image)
                
            # Convert to FP16 if CUDA available
            if torch.cuda.is_available():
                image = image.half()  # FP16
                
            return image, label
            
        except Exception as e:
            print(f"Error loading {img_path}: {str(e)}")
            # Return random tensor as fallback
            return torch.randn(1, *self.target_size), -1


def get_optimal_workers(max_workers: int = 8) -> int:
    """
    Determine optimal number of workers for DataLoader
    
    Args:
        max_workers: Maximum allowed workers (to avoid overloading)
    Returns:
        Optimal worker count (at least 1)
    """
    num_cpus = os.cpu_count() or 1
    if torch.cuda.is_available():
        # Leave some CPU cores for GPU ops
        return min(num_cpus , max_workers)
    return min(num_cpus, max_workers)


def create_dataloaders(
    train_path: str,
    val_path: str,
    test_path: str,
    batch_size: int = 64,
    target_size: Tuple[int, int] = (224, 224),
    max_workers: int = 8,
    shuffle_train=True
) -> Tuple[DataLoader, DataLoader, DataLoader]:
    """
    Create train/val/test dataloaders with automatic worker configuration
    
    Args:
        train_path: Path to training data file
        val_path: Path to validation data file
        test_path: Path to test data file
        batch_size: Batch size for all loaders
        target_size: Image target size
        max_workers: Maximum workers to use
        
    Returns:
        Tuple of (train_loader, val_loader, test_loader)
    """
    # Define transforms
    transform = transforms.Compose([
        transforms.Resize(target_size),
        transforms.ToTensor(),
        transforms.Normalize(mean=[0.485], std=[0.229])  # Grayscale stats
    ])
    
    # Create datasets
    train_set = ImageLabelDataset(train_path, target_size, transform)
    val_set = ImageLabelDataset(val_path, target_size, transform)
    test_set = ImageLabelDataset(test_path, target_size, transform)
    
    # Get optimal worker count
    num_workers = get_optimal_workers(max_workers)
    print(f"Using {num_workers} workers per DataLoader")
    
    # Common DataLoader kwargs
    loader_kwargs = {
        'batch_size': batch_size,
        'num_workers': num_workers,
        'pin_memory': torch.cuda.is_available(),
        'persistent_workers': num_workers > 0
    }
    
    # Create loaders
    train_loader = DataLoader(
        train_set,
        shuffle=shuffle_train,
        **loader_kwargs
    )
    val_loader = DataLoader(
        val_set,
        shuffle=False,
        **loader_kwargs
    )
    test_loader = DataLoader(
        test_set,
        shuffle=False,
        **loader_kwargs
    )
    
    return train_loader, val_loader, test_loader


# Example usage
def data_loaders(shuffle_train1=True):
    try:
        train_loader, val_loader, test_loader = create_dataloaders(
            train_path="data/train_full.txt",
            val_path="data/val_full.txt",
            test_path="data/test_full.txt",
            batch_size=64,
            max_workers=32,
            shuffle_train=shuffle_train1
        )
        
        print(f"Train batches: {len(train_loader)}")
        print(f"Validation batches: {len(val_loader)}")
        print(f"Test batches: {len(test_loader)}")
        return train_loader, val_loader, test_loader
        
    except Exception as e:
        print(f"Failed to create dataloaders: {str(e)}")