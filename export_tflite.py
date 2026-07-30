import tensorflow as tf

model = tf.keras.models.load_model('best_model.keras')

converter = tf.lite.TFLiteConverter.from_keras_model(model)
converter.optimizations = [] # NO quantization to preserve maximum accuracy
tflite_model = converter.convert()

with open('plant_disease_model_unquantized.tflite', 'wb') as f:
    f.write(tflite_model)

print("Saved unquantized tflite model!")
