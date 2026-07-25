import os
import shutil
import zipfile
from fastapi import APIRouter, UploadFile, File, HTTPException, Depends, Form
from typing import Optional
from datetime import datetime
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select

from app.database.mysql_db import get_db_session
from app.database.schema import Dataset
from app.api.auth import get_current_user

router = APIRouter()

DATASETS_DIR = os.path.join(
    os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__)))),
    "datasets"
)

os.makedirs(DATASETS_DIR, exist_ok=True)


@router.post("/upload")
async def upload_dataset(
    file: UploadFile = File(...),
    dataset_name: str = Form(...),
    description: Optional[str] = Form(""),
    db: AsyncSession = Depends(get_db_session),
    current_user: dict = Depends(get_current_user)
):
    if not current_user.is_admin:
        raise HTTPException(
            status_code=403,
            detail="Only administrators can upload datasets"
        )

    if not file.filename.endswith(".zip"):
        raise HTTPException(
            status_code=400,
            detail="Only ZIP files are allowed."
        )

    stmt = select(Dataset).where(Dataset.name == dataset_name)
    result = await db.execute(stmt)
    existing = result.scalars().first()

    if existing:
        raise HTTPException(
            status_code=400,
            detail="Dataset already exists."
        )

    timestamp = datetime.utcnow().strftime("%Y%m%d_%H%M%S")
    folder_name = f"{dataset_name.replace(' ','_')}_{timestamp}"
    dataset_path = os.path.join(DATASETS_DIR, folder_name)

    os.makedirs(dataset_path, exist_ok=True)

    zip_path = os.path.join(dataset_path, file.filename)

    try:

        with open(zip_path, "wb") as buffer:
            shutil.copyfileobj(file.file, buffer)

        with zipfile.ZipFile(zip_path, "r") as zip_ref:
            zip_ref.extractall(dataset_path)

        os.remove(zip_path)

        image_count = 0
        classes = set()

        for root, dirs, files in os.walk(dataset_path):
            for filename in files:
                if filename.lower().endswith(
                    (".png", ".jpg", ".jpeg", ".bmp", ".gif")
                ):
                    image_count += 1
                    classes.add(os.path.basename(root))

        class_count = len(classes)

        new_dataset = Dataset(
            name=dataset_name,
            num_images=image_count,
            num_classes=class_count,
            storage_path=folder_name,
            status="Not Trained"
        )

        db.add(new_dataset)
        await db.commit()
        await db.refresh(new_dataset)

        return {
            "success": True,
            "message": "Dataset uploaded successfully.",
            "dataset": {
                "id": new_dataset.id,
                "name": new_dataset.name,
                "image_count": new_dataset.num_images,
                "class_count": new_dataset.num_classes,
                "status": new_dataset.status,
                "upload_date": (
                    new_dataset.upload_date.isoformat()
                    if new_dataset.upload_date
                    else None
                )
            }
        }

    except Exception as e:

        await db.rollback()

        if os.path.exists(dataset_path):
            shutil.rmtree(dataset_path)

        raise HTTPException(
            status_code=500,
            detail=str(e)
        )


@router.get("/")
async def list_datasets(
    db: AsyncSession = Depends(get_db_session),
    current_user: dict = Depends(get_current_user)
):

    if not current_user.is_admin:
        raise HTTPException(
            status_code=403,
            detail="Only administrators can view datasets"
        )

    stmt = select(Dataset).order_by(Dataset.upload_date.desc())

    result = await db.execute(stmt)

    datasets = result.scalars().all()

    return [
        {
            "id": d.id,
            "name": d.name,
            "image_count": d.num_images,
            "class_count": d.num_classes,
            "status": d.status,
            "upload_date": (
                d.upload_date.isoformat()
                if d.upload_date
                else None
            ),
            "path": d.storage_path
        }
        for d in datasets
    ]