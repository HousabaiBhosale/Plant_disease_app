from fastapi import APIRouter, HTTPException, Depends, BackgroundTasks
from typing import List
from datetime import datetime
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, update
import logging

from app.database.mysql_db import get_db_session
from app.database.schema import ModelVersion, Dataset
from app.api.auth import get_current_user
from app.services.training_manager import TrainingManager

router = APIRouter()
logger = logging.getLogger(__name__)

from pydantic import BaseModel
class TrainRequest(BaseModel):
    dataset_ids: List[int]

@router.post("/train")
async def start_training(
    request: TrainRequest,
    background_tasks: BackgroundTasks,
    db: AsyncSession = Depends(get_db_session),
    current_user: dict = Depends(get_current_user)
):
    """
    Start model training using selected datasets
    """
    if not current_user.is_admin:
        raise HTTPException(status_code=403, detail="Only administrators can start training")

    if not request.dataset_ids:
        raise HTTPException(status_code=400, detail="No datasets selected for training.")

    # Validate datasets exist
    stmt = select(Dataset).filter(Dataset.id.in_(request.dataset_ids))
    res = await db.execute(stmt)
    datasets = res.scalars().all()
    if not datasets:
        raise HTTPException(status_code=404, detail="Selected datasets not found.")

    # Create new model version record
    version_name = f"v{datetime.utcnow().strftime('%Y.%m.%d.%H%M')}"
    new_model = ModelVersion(
        version_name=version_name,
        accuracy=0.0,
        loss=0.0,
        is_active=False,
        status="Training",
        dataset_ids=request.dataset_ids
    )
    db.add(new_model)
    await db.flush()
    model_id = new_model.id
    
    # Update status of datasets
    for ds in datasets:
        ds.status = "Training"
        
    await db.commit()

    # Background task for staging data and running pipeline
    async def training_task(m_id, d_ids):
        # We need a new session for the background task to prepare data
        from app.database.mysql_db import get_db_session_maker
        async_session = get_db_session_maker()
        try:
            async with async_session() as bdb:
                await TrainingManager.prepare_training_data(d_ids, bdb)
            
            # Run the actual training
            await TrainingManager.run_training_pipeline(m_id)
            
            # Once done, update dataset statuses back
            async with async_session() as bdb:
                d_stmt = select(Dataset).filter(Dataset.id.in_(d_ids))
                d_res = await bdb.execute(d_stmt)
                for ds in d_res.scalars().all():
                    ds.status = "Trained"
                await bdb.commit()
                
        except Exception as e:
            logger.error(f"Training task failed: {e}")
            async with async_session() as bdb:
                m_stmt = select(ModelVersion).filter(ModelVersion.id == m_id)
                m_res = await bdb.execute(m_stmt)
                mv = m_res.scalars().first()
                if mv:
                    mv.status = "Failed"
                
                d_stmt = select(Dataset).filter(Dataset.id.in_(d_ids))
                d_res = await bdb.execute(d_stmt)
                for ds in d_res.scalars().all():
                    ds.status = "Not Trained"
                await bdb.commit()

    background_tasks.add_task(training_task, model_id, request.dataset_ids)

    return {
        "success": True, 
        "message": "Training started in background.",
        "version": version_name
    }

@router.get("/models")
async def list_models(
    db: AsyncSession = Depends(get_db_session),
    current_user: dict = Depends(get_current_user)
):
    """
    List all trained model versions
    """
    if not current_user.is_admin:
        raise HTTPException(status_code=403, detail="Only administrators can view models")

    stmt = select(ModelVersion).order_by(ModelVersion.created_at.desc())
    res = await db.execute(stmt)
    models = res.scalars().all()
    
    return [
        {
            "id": m.id,
            "version_name": m.version_name,
            "accuracy": m.accuracy,
            "loss": m.loss,
            "created_at": m.created_at.isoformat() if m.created_at else None,
            "is_active": m.is_active,
            "status": m.status,
            "file_path": m.file_path,
            "dataset_ids": m.dataset_ids
        }
        for m in models
    ]

@router.post("/models/{model_id}/activate")
async def activate_model(
    model_id: int,
    db: AsyncSession = Depends(get_db_session),
    current_user: dict = Depends(get_current_user)
):
    """
    Activate a specific model version
    """
    if not current_user.is_admin:
        raise HTTPException(status_code=403, detail="Only administrators can activate models")

    stmt = select(ModelVersion).filter(ModelVersion.id == model_id)
    res = await db.execute(stmt)
    model = res.scalars().first()

    if not model:
        raise HTTPException(status_code=404, detail="Model not found")
        
    if model.status != "Completed":
        raise HTTPException(status_code=400, detail="Cannot activate incomplete model")

    # Set all other models to inactive
    await db.execute(update(ModelVersion).values(is_active=False))
    
    # Set this one to active
    model.is_active = True
    await db.commit()

    # The ML Service prediction loop must reload the active model.
    # We can handle this by reloading the ML Service or copying the file over to `data/best_model.keras`
    import os
    import shutil
    BASE_DIR = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
    source_model = os.path.join(BASE_DIR, "plant_disease_backend", "data", model.file_path)
    target_model = os.path.join(BASE_DIR, "plant_disease_backend", "data", "best_model.keras")
    
    if os.path.exists(source_model):
        shutil.copy2(source_model, target_model)
        
        # Reload ml_service
        from app.services.ml_service import ml_service
        ml_service.model = None # Force reload
        ml_service.load_model()
        
    return {"success": True, "message": f"Model {model.version_name} activated successfully."}
