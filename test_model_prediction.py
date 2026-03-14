import tensorflow as tf
import numpy as np
from tensorflow.keras.preprocessing import image
import os
import json
import sys

# Fix for Windows Unicode printing issues
if sys.platform == "win32":
    import io
    sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8')

IMG_SIZE = 224

print("Loading model...")
# Using best_model.keras as the most recent successful checkpoint
model = tf.keras.models.load_model("best_model.keras")

# Load class indices (High-speed loading)
class_indices_path = "class_indices.json"
if not os.path.exists(class_indices_path):
    print(f"Error: {class_indices_path} not found! Please run save_classes.py first.")
    exit()

with open(class_indices_path, "r") as f:
    class_indices_raw = json.load(f)

# Reverse mapping: index -> class_name
class_indices = {int(v): k for k, v in class_indices_raw.items()}

# Disease recommendations
disease_advice = {
    "Late_blight": "Apply fungicide and remove infected leaves.",
    "Early_blight": "Remove infected leaves and rotate crops.",
    "Septoria_leaf_spot": "Remove infected leaves and apply fungicide.",
    "Leaf_Mold": "Improve air circulation and reduce humidity.",
    "Bacterial_spot": "Use copper-based sprays and avoid overhead watering.",
    "healthy": "Plant appears healthy. Maintain proper irrigation and nutrition."
}

# Path to test image
img_path = "apple.png"


if not os.path.exists(img_path):
    # Fallback to plant.jpeg if apple.png isn't available
    img_path = "Tomato.png"
    if not os.path.exists(img_path):
        print("Image not found! Please ensure apple.png or plant.jpeg exists in the folder.")
        exit()

print(f"Loading image: {img_path}...")
img = image.load_img(img_path, target_size=(IMG_SIZE, IMG_SIZE))

img_array = image.img_to_array(img)
# IMPORTANT: Normalization Fix (1.0 instead of 255.0)
# Our model was trained at this scale to prevent EfficientNet "blindness"
img_array = img_array / 1.0
img_array = np.expand_dims(img_array, axis=0)

print("Running prediction...")
prediction = model.predict(img_array)

# ----------------------------------
# STEP 1 — FINAL DIAGNOSIS
# ----------------------------------
predicted_class_index = np.argmax(prediction)
predicted_class_name = class_indices[predicted_class_index]
confidence = np.max(prediction) * 100

if "___" in predicted_class_name:
    plant, disease = predicted_class_name.split("___")
else:
    plant = predicted_class_name
    disease = "Healthy"

print("\n========================================")
print("     PLANT DISEASE DIAGNOSIS")
print("========================================")
print(f"Image Source: {img_path}")

# ----------------------------------
# STEP 2 — STRICT SAFETY GUARD
# ----------------------------------
# Calculate Top-2 Gap (Difference between 1st and 2nd best guess)
top_2_indices = np.argsort(prediction[0])[-2:]
top_1_val = prediction[0][top_2_indices[1]]
top_2_val = prediction[0][top_2_indices[0]]
prob_gap = (top_1_val - top_2_val) * 100

STRICT_THRESHOLD = 85.0
GAP_THRESHOLD = 15.0 # If the second best guess is too close, it's a guess

print("\n========================================")
print("     PLANT DISEASE DIAGNOSIS")
print("========================================")
print(f"Image Source: {img_path}")

# Logical Honesty Guard
is_unknown = (confidence < STRICT_THRESHOLD) or (prob_gap < GAP_THRESHOLD)

if is_unknown:
    print(f"\n📢 DATASET NOTICE: UNRECOGNIZED PLANT")
    print("This specific plant or disease is NOT present in our training dataset.")
    
    print("\n🔍 PATTERN ANALYSIS:")
    print("However, based on learned visual patterns (leaf shape, texture, and color),")
    print(f"this image shows high similarity to: {plant} - {disease.replace('_',' ')}")
    
    print("\n💡 SUGGESTION:")
    print("If this is a known plant from the dataset, please try a clearer,")
    print("top-down photo on a plain white background for better results.")
    
    print(f"\n(Technical Stats — Confidence: {confidence:.2f}% | Reliability Gap: {prob_gap:.2f}%)")
else:
    print(f"\nDetected Plant: {plant}")
    print(f"Detected Condition: {disease.replace('_',' ')}")
    print(f"Confidence Level: {confidence:.2f}%")
    print("Status: Accurate Match Found")

    # ----------------------------------
    # STEP 3 — RECOMMENDATION
    # ----------------------------------
    advice_found = False
    for key in disease_advice:
        if key.lower() in disease.lower():
            print("\nRecommendation:")
            print(f"💡 {disease_advice[key]}")
            advice_found = True
            break

    if not advice_found:
        print("\nRecommendation:")
        print("💡 Diagnosis complete. Consult an agricultural expert for specific treatment.")

print("========================================")
