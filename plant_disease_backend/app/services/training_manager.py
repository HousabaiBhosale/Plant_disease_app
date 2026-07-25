import os
import shutil
import asyncio
import logging
from datetime import datetime
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select

from app.database.schema import Dataset, ModelVersion
from app.database.mysql_db import get_db_session_maker

logger = logging.getLogger(__name__)

# Base directories
BASE_DIR = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
DATASETS_DIR = os.path.join(BASE_DIR, "datasets")
TRAINING_DIR = os.path.join(BASE_DIR, "PlantVillage")
BACKUP_DIR = os.path.join(BASE_DIR, "PlantVillage_backup")
MODELS_DIR = os.path.join(BASE_DIR, "plant_disease_backend", "data")
SRC_DIR = os.path.join(BASE_DIR, "src")

class TrainingManager:
    """
    Manages the staging of datasets and execution of the ML pipeline
    without modifying the original train_enhanced.py
    """
    
    @staticmethod
    async def prepare_training_data(dataset_ids: list[int], db: AsyncSession):
        """
        Combines selected datasets into the expected folder structure for train_enhanced.py
        """
        logger.info(f"Preparing training data for datasets: {dataset_ids}")
        
        # 1. Backup existing PlantVillage directory if it exists
        if os.path.exists(TRAINING_DIR):
            if os.path.exists(BACKUP_DIR):
                shutil.rmtree(BACKUP_DIR)
            shutil.move(TRAINING_DIR, BACKUP_DIR)
            
        # 2. Create new expected structure
        train_dir = os.path.join(TRAINING_DIR, "train")
        val_dir = os.path.join(TRAINING_DIR, "val")
        os.makedirs(train_dir, exist_ok=True)
        os.makedirs(val_dir, exist_ok=True)
        
        # 3. Retrieve dataset paths
        stmt = select(Dataset).filter(Dataset.id.in_(dataset_ids))
        res = await db.execute(stmt)
        datasets = res.scalars().all()
        
        if not datasets:
            raise ValueError("No valid datasets found for training.")
            
        # 4. Merge datasets into PlantVillage structure
        # A simple 80-20 train-val split is performed per class across all datasets
        for dataset in datasets:
            ds_path = os.path.join(DATASETS_DIR, dataset.path)
            if not os.path.exists(ds_path):
                logger.warning(f"Dataset path {ds_path} not found. Skipping.")
                continue
                
            for root, dirs, files in os.walk(ds_path):
                # Only process directories that contain images (leaf classes)
                images = [f for f in files if f.lower().endswith(('.png', '.jpg', '.jpeg', '.bmp', '.gif'))]
                if not images:
                    continue
                    
                class_name = os.path.basename(root)
                
                # Create class directories in train and val
                os.makedirs(os.path.join(train_dir, class_name), exist_ok=True)
                os.makedirs(os.path.join(val_dir, class_name), exist_ok=True)
                
                # Split and copy
                import random
                random.shuffle(images)
                split_idx = int(len(images) * 0.8)
                
                train_images = images[:split_idx]
                val_images = images[split_idx:]
                
                for img in train_images:
                    shutil.copy2(os.path.join(root, img), os.path.join(train_dir, class_name, img))
                    
                for img in val_images:
                    shutil.copy2(os.path.join(root, img), os.path.join(val_dir, class_name, img))
                    
        logger.info("Training data preparation complete.")

    @staticmethod
    async def run_training_pipeline(model_version_id: int):
        """
        Executes train_enhanced.py as a subprocess and manages the output model
        """
        # We need a new session for the background task
        async_session = get_db_session_maker()
        
        try:
            # 1. Execute the training script
            logger.info("Starting training process...")
            
            # The script is expected to run from BASE_DIR so it can find PlantVillage
            process = await asyncio.create_subprocess_exec(
                "python", os.path.join(SRC_DIR, "train_enhanced.py"),
                cwd=BASE_DIR,
                stdout=asyncio.subprocess.PIPE,
                stderr=asyncio.subprocess.PIPE
            )
            
            stdout, stderr = await process.communicate()
            
            if process.returncode != 0:
                logger.error(f"Training failed. Stderr: {stderr.decode()}")
                async with async_session() as db:
                    stmt = select(ModelVersion).filter(ModelVersion.id == model_version_id)
                    res = await db.execute(stmt)
                    mv = res.scalars().first()
                    if mv:
                        mv.status = "Failed"
                        await db.commit()
                return False
                
            logger.info("Training script completed successfully.")
            
            # 2. Locate the output model
            output_model_path = os.path.join(BASE_DIR, "best_model_enhanced.keras")
            if not os.path.exists(output_model_path):
                logger.error("Expected output model not found.")
                return False
                
            # 3. Rename and move to models directory
            timestamp_str = datetime.utcnow().strftime("%Y%m%d_%H%M%S")
            new_model_filename = f"model_v{model_version_id}_{timestamp_str}.keras"
            os.makedirs(MODELS_DIR, exist_ok=True)
            final_model_path = os.path.join(MODELS_DIR, new_model_filename)
            
            shutil.move(output_model_path, final_model_path)
            
            # 4. Update Database
            async with async_session() as db:
                stmt = select(ModelVersion).filter(ModelVersion.id == model_version_id)
                res = await db.execute(stmt)
                mv = res.scalars().first()
                if mv:
                    mv.status = "Completed"
                    mv.file_path = new_model_filename
                    
                    # Read accuracy from stdout if possible, or leave as default
                    # For simplicity, we just mark it complete.
                    await db.commit()
                    
            return True
            
        except Exception as e:
            logger.error(f"Error during training pipeline: {e}")
            async with async_session() as db:
                stmt = select(ModelVersion).filter(ModelVersion.id == model_version_id)
                res = await db.execute(stmt)
                mv = res.scalars().first()
                if mv:
                    mv.status = "Failed"
                    await db.commit()
            return False
            
        finally:
            # 5. Cleanup and Restore
            if os.path.exists(TRAINING_DIR):
                shutil.rmtree(TRAINING_DIR)
                
            if os.path.exists(BACKUP_DIR):
                shutil.move(BACKUP_DIR, TRAINING_DIR)
