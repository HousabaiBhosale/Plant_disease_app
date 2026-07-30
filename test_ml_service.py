import sys
import os
sys.path.append(os.path.abspath("plant_disease_backend"))
os.chdir("plant_disease_backend")

from app.services.ml_service import ml_service

test_img = "../PlantVillage/val/Apple___Apple_scab/01a66316-0e98-4d3b-a56f-d78752cd043f___FREC_Scab 3003.JPG"

if os.path.exists(test_img):
    with open(test_img, "rb") as f:
        img_bytes = f.read()
    
    disease, conf, top3, ms = ml_service.predict(img_bytes)
    print(f"Prediction: {disease} ({conf:.4f})")
    print(f"Top 3: {top3}")
