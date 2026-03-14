import os
import tensorflow as tf
from tensorflow.keras.preprocessing.image import ImageDataGenerator
from tensorflow.keras.applications import EfficientNetB0
from tensorflow.keras import layers, models
from tensorflow.keras.callbacks import EarlyStopping, ModelCheckpoint, ReduceLROnPlateau
import numpy as np
from sklearn.utils.class_weight import compute_class_weight

# Enable XLA JIT compilation for faster CPU performance
tf.config.optimizer.set_jit(True)

# ==========================
# CONFIG
# ==========================
IMG_SIZE = 224
BATCH_SIZE = 32
INITIAL_EPOCHS = 5
FINE_TUNE_EPOCHS = 20

train_dir = "PlantVillage/train"
val_dir = "PlantVillage/val"

# ==========================
# ADVANCED DATA GENERATORS (FIELD-READY)
# ==========================
# We use more aggressive augmentation to simulate real-world conditions
train_datagen = ImageDataGenerator(
    rescale=1.0, # Target: 1.0 for EfficientNet
    rotation_range=45,
    width_shift_range=0.3,
    height_shift_range=0.3,
    shear_range=0.3,
    zoom_range=0.3,
    brightness_range=[0.5, 1.5], # Simulates sunlight/shadows
    channel_shift_range=40.0,    # Simulates different camera sensors
    horizontal_flip=True,
    vertical_flip=True,          # Leaves can be any orientation
    fill_mode="nearest"
)

val_datagen = ImageDataGenerator(rescale=1.0)

train_data = train_datagen.flow_from_directory(
    train_dir,
    target_size=(IMG_SIZE, IMG_SIZE),
    batch_size=BATCH_SIZE,
    class_mode='categorical',
    shuffle=True
)

val_data = val_datagen.flow_from_directory(
    val_dir,
    target_size=(IMG_SIZE, IMG_SIZE),
    batch_size=BATCH_SIZE,
    class_mode='categorical'
)

# ==========================
# STEP 1: CALCULATE CLASS WEIGHTS
# ==========================
# This helps the model treat Potato (small class) as importantly as Soybean (large class)
print("⚖️ Calculating automated class weights...")
labels = train_data.classes
class_weights_vals = compute_class_weight(
    class_weight='balanced',
    classes=np.unique(labels),
    y=labels
)
class_weights = dict(enumerate(class_weights_vals))
print("✅ Class weights calculated.")

# ==========================
# MODEL BUILDING
# ==========================
base_model = EfficientNetB0(
    weights='imagenet',
    include_top=False,
    input_shape=(IMG_SIZE, IMG_SIZE, 3)
)

base_model.trainable = False # Freeze initially for warm-up

model = models.Sequential([
    base_model,
    layers.GlobalAveragePooling2D(),
    layers.BatchNormalization(),
    layers.Dropout(0.4), # Increased dropout for better generalization
    layers.Dense(train_data.num_classes, activation='softmax')
])

model.compile(
    optimizer='adam',
    loss='categorical_crossentropy',
    metrics=['accuracy']
)

# ==========================
# CALLBACKS
# ==========================
early_stop = EarlyStopping(monitor='val_loss', patience=5, restore_best_weights=True)
reduce_lr = ReduceLROnPlateau(monitor='val_loss', factor=0.2, patience=3, min_lr=1e-7)
checkpoint = ModelCheckpoint(
    "best_model_enhanced.keras", 
    monitor="val_accuracy", 
    save_best_only=True, 
    mode="max", 
    verbose=1
)

# ==========================
# STAGE 1: WARM-UP (INITIAL TRAINING)
# ==========================
print("\n===== Starting Stage 1: Warm-up (Fixed Base) =====\n")
model.fit(
    train_data,
    validation_data=val_data,
    epochs=INITIAL_EPOCHS,
    class_weight=class_weights,
    callbacks=[early_stop, checkpoint, reduce_lr]
)

# ==========================
# STAGE 2: DEEP FINE-TUNING
# ==========================
print("\n===== Starting Stage 2: Deep Fine-Tuning (Unfreezing Top Layers) =====\n")

# Unfreeze the last 50 layers of EfficientNet for deeper pattern adaptation
base_model.trainable = True
for layer in base_model.layers[:-50]:
    layer.trainable = False

model.compile(
    optimizer=tf.keras.optimizers.Adam(learning_rate=1e-5), # Very low LR for fine-tuning
    loss='categorical_crossentropy',
    metrics=['accuracy']
)

history = model.fit(
    train_data,
    validation_data=val_data,
    epochs=FINE_TUNE_EPOCHS,
    class_weight=class_weights,
    callbacks=[early_stop, checkpoint, reduce_lr]
)

print("\n===== Enhanced Training Completed Successfully =====")
print("Best model saved as: best_model_enhanced.keras")
