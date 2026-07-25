import numpy as np
from PIL import Image
import io
import json
import time
import os
from typing import Tuple, Dict
import logging

logger = logging.getLogger(__name__)


class MLService:
    def __init__(self):
        self.model = None
        self.interpreter = None  # TFLite interpreter
        self.input_details = None
        self.output_details = None
        self.class_indices = None
        self.idx_to_class = None
        self.model_version = "1.0.0"
        self._use_tflite = False
        self.load_model()

    def load_model(self):
        """Load TFLite model (fast) or fall back to Keras model."""
        # Try TFLite first (much faster, no TF import delay)
        tflite_path = "data/plant_disease_model.tflite"
        keras_path = "data/best_model.keras"
        class_indices_path = "data/class_indices.json"

        # Load class indices first
        try:
            with open(class_indices_path, "r") as f:
                self.class_indices = json.load(f)
            self.idx_to_class = {int(v): k for k, v in self.class_indices.items()}
            logger.info(f"Loaded {len(self.idx_to_class)} classes from class_indices.json")
        except Exception as e:
            logger.error(f"Failed to load class indices: {e}")
            raise

        # Try Keras model first for maximum accuracy (17.6 MB full precision model)
        if os.path.exists(keras_path):
            try:
                import tensorflow as tf
                self.model = tf.keras.models.load_model(keras_path)
                self._use_tflite = False
                logger.info(f"Keras high-accuracy model loaded from {keras_path}")
                return
            except Exception as e:
                logger.warning(f"Keras model load failed ({e}), falling back to TFLite...")

        # Fall back to TFLite interpreter
        if os.path.exists(tflite_path):
            try:
                try:
                    import tflite_runtime.interpreter as tflite
                    self.interpreter = tflite.Interpreter(model_path=tflite_path)
                    logger.info("Using tflite_runtime interpreter")
                except ImportError:
                    import tensorflow.lite as tflite
                    self.interpreter = tflite.Interpreter(model_path=tflite_path)
                    logger.info("Using tensorflow.lite interpreter")

                self.interpreter.allocate_tensors()
                self.input_details = self.interpreter.get_input_details()
                self.output_details = self.interpreter.get_output_details()
                self._use_tflite = True
                self.model = "tflite"
                logger.info(f"TFLite model loaded from {tflite_path}")
                return
            except Exception as e:
                logger.error(f"TFLite load failed: {e}")
                raise
        else:
            raise FileNotFoundError(
                f"No model found at {tflite_path} or {keras_path}"
            )

    def preprocess_image(self, image_bytes: bytes) -> np.ndarray:
        """Preprocess image for model input (224x224 RGB, normalized 0-255)."""
        img = Image.open(io.BytesIO(image_bytes))
        if img.mode != "RGB":
            img = img.convert("RGB")
        # Center crop to square first to avoid aspect ratio distortion!
        width, height = img.size
        min_dim = min(width, height)
        left = (width - min_dim) // 2
        top = (height - min_dim) // 2
        right = (width + min_dim) // 2
        bottom = (height + min_dim) // 2
        img = img.crop((left, top, right, bottom))
        img = img.resize((224, 224), Image.Resampling.LANCZOS)
        img_array = np.array(img, dtype=np.float32)  # keep 0-255 range
        img_array = np.expand_dims(img_array, axis=0)
        return img_array

    def predict(self, image_bytes: bytes) -> Tuple[str, float, Dict, float]:
        """Run prediction on image bytes. Returns (class_name, confidence, top3, ms)."""
        start_time = time.time()

        try:
            img_array = self.preprocess_image(image_bytes)

            if self._use_tflite:
                # TFLite inference
                self.interpreter.set_tensor(self.input_details[0]["index"], img_array)
                self.interpreter.invoke()
                predictions = self.interpreter.get_tensor(self.output_details[0]["index"])
            else:
                # Keras inference
                predictions = self.model.predict(img_array, verbose=0)

            preds = predictions[0]
            predicted_class_idx = int(np.argmax(preds))
            confidence = float(preds[predicted_class_idx])
            disease_name = self.idx_to_class[predicted_class_idx]

            top_3_indices = np.argsort(preds)[-3:][::-1]
            top_3_predictions = {
                self.idx_to_class[int(idx)]: float(preds[idx])
                for idx in top_3_indices
            }

            processing_time = (time.time() - start_time) * 1000  # ms
            return disease_name, confidence, top_3_predictions, processing_time

        except Exception as e:
            logger.error(f"Prediction failed: {e}")
            raise


# Singleton instance
ml_service = MLService()
