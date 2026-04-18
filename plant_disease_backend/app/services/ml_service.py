import tensorflow as tf
import numpy as np
from PIL import Image
import io
import json
import time
from typing import Tuple, Dict
import logging

logger = logging.getLogger(__name__)

class MLService:
    def __init__(self):
        self.model = None
        self.class_indices = None
        self.idx_to_class = None
        self.model_version = "1.0.0"
        self.load_model()
    
    def load_model(self):
        """Load TensorFlow model and class indices"""
        try:
            # Load model
            self.model = tf.keras.models.load_model("data/best_model.keras")
            logger.info("Model loaded successfully")
            
            # Load class indices
            with open("data/class_indices.json", 'r') as f:
                self.class_indices = json.load(f)
            
            # Reverse mapping
            self.idx_to_class = {int(v): k for k, v in self.class_indices.items()}
            logger.info(f"Loaded {len(self.idx_to_class)} classes")
            
        except Exception as e:
            logger.error(f"Failed to load model: {e}")
            raise
    
    def preprocess_image(self, image_bytes: bytes) -> np.ndarray:
        """Preprocess image for model input"""
        img = Image.open(io.BytesIO(image_bytes))
        
        # Convert RGBA to RGB
        if img.mode == 'RGBA':
            img = img.convert('RGB')
        
        # Resize
        img = img.resize((224, 224))
        
        # Convert to array and normalize
        img_array = np.array(img) / 1.0  # As per your training
        img_array = np.expand_dims(img_array, axis=0)
        
        return img_array
    
    def predict(self, image_bytes: bytes) -> Tuple[str, float, Dict, float]:
        """Run prediction on image"""
        start_time = time.time()
        
        try:
            # Preprocess
            img_array = self.preprocess_image(image_bytes)
            
            # Predict
            predictions = self.model.predict(img_array, verbose=0)
            
            # Get top prediction
            predicted_class_idx = np.argmax(predictions[0])
            confidence = float(predictions[0][predicted_class_idx])
            
            # Get disease name
            disease_name = self.idx_to_class[predicted_class_idx]
            
            # Get top 3 predictions
            top_3_indices = np.argsort(predictions[0])[-3:][::-1]
            top_3_predictions = {
                self.idx_to_class[idx]: float(predictions[0][idx])
                for idx in top_3_indices
            }
            
            processing_time = (time.time() - start_time) * 1000  # ms
            
            return disease_name, confidence, top_3_predictions, processing_time
            
        except Exception as e:
            logger.error(f"Prediction failed: {e}")
            raise

# Singleton instance
ml_service = MLService()
