import os
import matplotlib.pyplot as plt
import seaborn as sns
import numpy as np
from tensorflow.keras.preprocessing import image
import random
import pandas as pd

# CONFIG
train_dir = "PlantVillage/train"
output_dir = "eda"
IMG_SIZE = 224

if not os.path.exists(output_dir):
    os.makedirs(output_dir)

print("🚀 Starting EDA Engine...")

# 1. Dataset Counts
print("📊 Analyzing dataset structure...")
classes = sorted(os.listdir(train_dir))
class_counts = []
plant_set = set()

for cls in classes:
    cls_path = os.path.join(train_dir, cls)
    if os.path.isdir(cls_path):
        count = len(os.listdir(cls_path))
        class_counts.append({"Class": cls, "Count": count})
        plant_set.add(cls.split("___")[0])

df = pd.DataFrame(class_counts)
total_images = df["Count"].sum()

print(f"✅ Summary: {total_images} images, {len(classes)} classes, {len(plant_set)} plants.")

# 2. Visualize Class Distribution
print("📉 Generating Class Distribution Chart...")
plt.figure(figsize=(15, 10))
sns.barplot(x="Count", y="Class", data=df.sort_values("Count", ascending=False), palette="viridis")
plt.title("Number of Images per Class (PlantVillage)", fontsize=16)
plt.xlabel("Count", fontsize=12)
plt.ylabel("Class Name", fontsize=12)
plt.tight_layout()
plt.savefig(os.path.join(output_dir, "class_distribution.png"))
plt.close()

# 3. Visualize Sample Images
print("🖼️ Generating Sample Grid...")
plt.figure(figsize=(12, 12))
random_classes = random.sample(classes, 16)

for i, cls in enumerate(random_classes):
    cls_path = os.path.join(train_dir, cls)
    img_name = random.choice(os.listdir(cls_path))
    img_path = os.path.join(cls_path, img_name)
    
    img = image.load_img(img_path, target_size=(224, 224))
    plt.subplot(4, 4, i + 1)
    plt.imshow(img)
    plt.title(cls.split("___")[-1].replace("_", " "), fontsize=8)
    plt.axis("off")

plt.suptitle("Random Samples from PlantVillage Dataset", fontsize=16)
plt.tight_layout()
plt.savefig(os.path.join(output_dir, "sample_grid.png"))
plt.close()

# 4. Pixel Intensity Analysis
print("🎨 Analyzing Pixel Distributions (Sampling 100 images)...")
pixel_samples = []
sample_files = []

for cls in classes:
    cls_path = os.path.join(train_dir, cls)
    sample_files.extend([os.path.join(cls_path, f) for f in os.listdir(cls_path)[:5]])

random.shuffle(sample_files)
selected_samples = sample_files[:100]

for img_path in selected_samples:
    img = image.load_img(img_path, target_size=(224, 224))
    img_array = image.img_to_array(img)
    pixel_samples.extend(img_array.flatten())

plt.figure(figsize=(10, 6))
plt.hist(pixel_samples, bins=50, color='green', alpha=0.7)
plt.title("Pixel Intensity Distribution (Sampleled)", fontsize=14)
plt.xlabel("Pixel Value (0-255)", fontsize=12)
plt.ylabel("Frequency", fontsize=12)
# 5. RGB Correlation Heatmap
print("🌡️ Generating RGB Correlation Heatmap...")
pixel_features = []
# Re-using some selected samples for efficiency
for img_path in selected_samples:
    img = image.load_img(img_path, target_size=(IMG_SIZE, IMG_SIZE))
    arr = image.img_to_array(img)
    
    r_mean = np.mean(arr[:,:,0])
    g_mean = np.mean(arr[:,:,1])
    b_mean = np.mean(arr[:,:,2])
    pixel_features.append([r_mean, g_mean, b_mean])

pixel_features = np.array(pixel_features)
corr = np.corrcoef(pixel_features.T)

plt.figure(figsize=(8, 6))
sns.heatmap(corr, annot=True, cmap="coolwarm",
            xticklabels=["Red", "Green", "Blue"],
            yticklabels=["Red", "Green", "Blue"])
plt.title("RGB Channel Correlation Heatmap", fontsize=14)
plt.savefig(os.path.join(output_dir, "rgb_correlation.png"))
plt.close()

# 6. Class-Level Similarity (The "Project-Specific" Heatmap)
print("🧬 Generating Class-Level Similarity Heatmap (38x38)...")
class_signatures = []

for cls in classes:
    cls_path = os.path.join(train_dir, cls)
    imgs = os.listdir(cls_path)[:20] # Sample 20 images per class for signature
    class_features = []
    
    for img_name in imgs:
        img_p = os.path.join(cls_path, img_name)
        img = image.load_img(img_p, target_size=(IMG_SIZE, IMG_SIZE))
        arr = image.img_to_array(img)
        
        # Features: Mean and Std Dev for each channel (helps capture color + texture)
        means = np.mean(arr, axis=(0, 1))
        stds = np.std(arr, axis=(0, 1))
        class_features.append(np.concatenate([means, stds]))
    
    # Representative "Signature" for this class
    class_signatures.append(np.mean(class_features, axis=0))

# Create Correlation Matrix between classes
class_signatures = np.array(class_signatures)
class_corr = np.corrcoef(class_signatures)

plt.figure(figsize=(22, 20))
sns.heatmap(class_corr, annot=False, cmap="YlGnBu",
            xticklabels=[c.split("___")[-1] for c in classes],
            yticklabels=[c.split("___")[-1] for c in classes])

plt.title("Class-Level Visual Similarity Heatmap (Based on RGB & Texture)", fontsize=22)
plt.xlabel("Plant Disease Classes", fontsize=14)
plt.ylabel("Plant Disease Classes", fontsize=14)
plt.xticks(rotation=90, fontsize=9)
plt.yticks(rotation=0, fontsize=9)
plt.tight_layout()
plt.savefig(os.path.join(output_dir, "class_correlation.png"))
plt.close()

print(f"✨ EDA Complete! Results saved to {output_dir}/ folder.")

# Generate summary data for report
df.to_csv(os.path.join(output_dir, "dataset_stats.csv"), index=False)
