import tensorflow as tf
from tensorflow.keras.preprocessing.image import ImageDataGenerator
import os

model = tf.keras.models.load_model('best_model.keras')

val_datagen = ImageDataGenerator(rescale=1.0)
val_data = val_datagen.flow_from_directory(
    'PlantVillage/val',
    target_size=(224, 224),
    batch_size=32,
    class_mode='categorical'
)

loss, acc = model.evaluate(val_data)
print(f"Validation Accuracy: {acc*100:.2f}%")
