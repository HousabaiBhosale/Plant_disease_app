import os
import tensorflow as tf
from tensorflow.keras.preprocessing.image import ImageDataGenerator
from tensorflow.keras.applications import EfficientNetB0
from tensorflow.keras import layers, models
from tensorflow.keras.callbacks import EarlyStopping, ModelCheckpoint

# Enable XLA JIT compilation for faster CPU performance
tf.config.optimizer.set_jit(True)

# ==========================
# CONFIG
# ==========================
IMG_SIZE = 224
BATCH_SIZE = 32
INITIAL_EPOCHS = 5
FINE_TUNE_EPOCHS = 30

train_dir = "PlantVillage/train"
val_dir = "PlantVillage/val"

# ==========================
# DATA GENERATORS
# ==========================
train_datagen = ImageDataGenerator(
    rescale=1.0,  # Keeping this 1.0 as discussed to prevent "blindness" bug
    rotation_range=40,
    zoom_range=0.3,
    width_shift_range=0.2,
    height_shift_range=0.2,
    shear_range=0.2,
    brightness_range=[0.6, 1.4],
    horizontal_flip=True,
    fill_mode="nearest"
)

val_datagen = ImageDataGenerator(rescale=1.0)

train_data = train_datagen.flow_from_directory(
    train_dir,
    target_size=(IMG_SIZE, IMG_SIZE),
    batch_size=BATCH_SIZE,
    class_mode='categorical'
)

val_data = val_datagen.flow_from_directory(
    val_dir,
    target_size=(IMG_SIZE, IMG_SIZE),
    batch_size=BATCH_SIZE,
    class_mode='categorical'
)

# ==========================
# MODEL BUILDING
# ==========================
base_model = EfficientNetB0(
    weights='imagenet',
    include_top=False,
    input_shape=(IMG_SIZE, IMG_SIZE, 3)
)

base_model.trainable = False  # Freeze base model initially

model = models.Sequential([
    base_model,
    layers.GlobalAveragePooling2D(),
    layers.Dropout(0.3),
    layers.Dense(train_data.num_classes, activation='softmax')
])

model.compile(
    optimizer='adam',
    loss=tf.keras.losses.CategoricalCrossentropy(label_smoothing=0.1),
    metrics=['accuracy']
)

model.summary()

# ==========================
# CALLBACKS
# ==========================
early_stop = EarlyStopping(
    monitor='val_loss',
    patience=3,
    restore_best_weights=True
)

checkpoint = ModelCheckpoint(
    "best_model.keras",
    monitor="val_accuracy",
    save_best_only=True,
    mode="max",
    verbose=1
)

# ==========================
# INITIAL TRAINING (STAGE 1)
# ==========================
if os.path.exists("plant_disease_model_stage1.h5"):
    print("\n===== Stage 1 Model Found. Skipping Initial Training. =====\n")
    model = tf.keras.models.load_model("plant_disease_model_stage1.h5")
    # Need to re-extract base_model to handle fine-tuning layers correctly
    base_model = model.layers[0]
else:
    print("\n===== Starting Initial Training =====\n")

    history = model.fit(
        train_data,
        validation_data=val_data,
        epochs=INITIAL_EPOCHS,
        callbacks=[early_stop, checkpoint]
    )

    model.save("plant_disease_model_stage1.h5")

# ==========================
# FINE-TUNING
# ==========================
print("\n===== Starting Fine-Tuning =====\n")

base_model.trainable = True

# POWER TRAINING: unfreeze all layers for maximum accuracy
for layer in base_model.layers:
    layer.trainable = True

model.compile(
    optimizer=tf.keras.optimizers.Adam(learning_rate=1e-4),
    loss=tf.keras.losses.CategoricalCrossentropy(label_smoothing=0.1),
    metrics=['accuracy']
)

# ==========================
# CALLBACKS / BACKUP
# ==========================
backup_dir = "backup_checkpoint"
if not os.path.exists(backup_dir):
    os.makedirs(backup_dir)

backup_callback = tf.keras.callbacks.BackupAndRestore(backup_dir)

history_fine = model.fit(
    train_data,
    validation_data=val_data,
    epochs=FINE_TUNE_EPOCHS,
    callbacks=[early_stop, checkpoint, backup_callback]
)

model.save("plant_disease_model_finetuned.keras")

print("\n===== Training Completed Successfully =====")