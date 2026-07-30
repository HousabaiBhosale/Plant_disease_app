import tensorflow as tf
import numpy as np
from tensorflow.keras.preprocessing.image import ImageDataGenerator
import os, json

model = tf.keras.models.load_model('best_model.keras')

val_datagen = ImageDataGenerator(rescale=1.0)
val_generator = val_datagen.flow_from_directory(
    'PlantVillage/val',
    target_size=(224, 224),
    batch_size=1,
    class_mode='categorical',
    shuffle=False
)

filenames = val_generator.filenames
preds = model.predict(val_generator, verbose=1)

predicted_classes = np.argmax(preds, axis=1)
true_classes = val_generator.classes

class_labels = list(val_generator.class_indices.keys())

misclassified = []
for i in range(len(filenames)):
    if predicted_classes[i] != true_classes[i]:
        if "healthy" in class_labels[predicted_classes[i]] and "healthy" not in class_labels[true_classes[i]]:
            misclassified.append((filenames[i], class_labels[true_classes[i]], class_labels[predicted_classes[i]], preds[i][predicted_classes[i]]))

print(f"\nFound {len(misclassified)} times where a diseased leaf was classified as healthy.")
if len(misclassified) > 0:
    for f, true, pred, conf in misclassified[:10]:
        print(f"File: {f} | True: {true} | Pred: {pred} ({conf:.2f})")
