import tensorflow as tf
from PIL import Image
import numpy as np
import json
import io

model = tf.keras.models.load_model('best_model.keras')

with open("class_indices.json", "r") as f:
    class_indices_raw = json.load(f)
class_indices = {int(v): k for k, v in class_indices_raw.items()}

def predict_pil(img):
    img = img.convert("RGB")
    width, height = img.size
    min_dim = min(width, height)
    left = (width - min_dim) // 2
    top = (height - min_dim) // 2
    right = (width + min_dim) // 2
    bottom = (height + min_dim) // 2
    img = img.crop((left, top, right, bottom))
    img = img.resize((224, 224), Image.Resampling.LANCZOS)
    img_array = np.array(img, dtype=np.float32)
    img_array = np.expand_dims(img_array, axis=0)
    
    preds = model.predict(img_array, verbose=0)[0]
    idx = np.argmax(preds)
    return class_indices[idx], preds[idx]

# Test on a specific image
import os
test_img = "PlantVillage/val/Apple___Apple_scab/01a66316-0e98-4d3b-a56f-d78752cd043f___FREC_Scab 3003.JPG"
if not os.path.exists(test_img):
    d = "PlantVillage/val/Apple___Apple_scab"
    if os.path.exists(d):
        test_img = os.path.join(d, os.listdir(d)[0])

if os.path.exists(test_img):
    original_img = Image.open(test_img)
    pred_orig, conf_orig = predict_pil(original_img)
    print(f"Original Prediction: {pred_orig} ({conf_orig:.2f})")
    
    # Simulate Flutter ImagePicker: resize to maxWidth=800, compress quality=70
    # (PlantVillage images are 256x256, so maxWidth=800 doesn't do anything, but quality=70 does)
    buffer = io.BytesIO()
    original_img.save(buffer, format="JPEG", quality=70)
    compressed_img = Image.open(io.BytesIO(buffer.getvalue()))
    pred_comp, conf_comp = predict_pil(compressed_img)
    print(f"Compressed Quality 70 Prediction: {pred_comp} ({conf_comp:.2f})")
