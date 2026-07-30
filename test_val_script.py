import tensorflow as tf
from tensorflow.keras.preprocessing import image
import numpy as np
import os, json

model = tf.keras.models.load_model("best_model.keras")

with open("class_indices.json", "r") as f:
    class_indices_raw = json.load(f)
class_indices = {int(v): k for k, v in class_indices_raw.items()}

def predict_image(img_path, rescale_type="none"):
    img = image.load_img(img_path, target_size=(224, 224))
    img_array = image.img_to_array(img)
    
    if rescale_type == "divide_255":
        img_array = img_array / 255.0
        
    img_array = np.expand_dims(img_array, axis=0)
    prediction = model.predict(img_array, verbose=0)
    idx = np.argmax(prediction)
    return class_indices[idx], np.max(prediction)

# Test an apple scab image from val
test_img = "PlantVillage/val/Apple___Apple_scab/01a66316-0e98-4d3b-a56f-d78752cd043f___FREC_Scab 3003.JPG"
if not os.path.exists(test_img):
    # just pick any file in the val/Apple___Apple_scab folder
    d = "PlantVillage/val/Apple___Apple_scab"
    if os.path.exists(d):
        test_img = os.path.join(d, os.listdir(d)[0])

if os.path.exists(test_img):
    print(f"Testing {test_img}")
    pred_1, conf_1 = predict_image(test_img, "none")
    print(f"Without rescale: {pred_1} ({conf_1:.2f})")
    
    pred_2, conf_2 = predict_image(test_img, "divide_255")
    print(f"With /255: {pred_2} ({conf_2:.2f})")
else:
    print("Test image not found!")
