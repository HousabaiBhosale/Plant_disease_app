from fastapi import APIRouter, File, UploadFile, HTTPException, Header, Depends, Query
from typing import Optional, List
import uuid
import logging
from datetime import datetime

from app.database.mysql_db import get_db_session
from app.api.auth import get_current_user
from app.database.models import PredictionResponse
from app.database.schema import PredictionLog
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select

from app.services.ml_service import ml_service
from app.services.recommendation_service import recommendation_service
from app.services.logging_service import LoggingService
from pydantic import BaseModel

class LocalPredictionRequest(BaseModel):
    disease_code: str
    confidence: float
    image_name: str
    processing_time_ms: float

router = APIRouter()
logger = logging.getLogger(__name__)

@router.post("/")
async def predict_disease(
    file: UploadFile = File(...),
    user_id: Optional[str] = Header(None, alias="X-User-ID"),
    device_info: Optional[str] = Header(None, alias="X-Device-Info"),
    db: AsyncSession = Depends(get_db_session)
):
    """
    Predict disease from leaf image (Cloud inference)
    This is for fallback or heavy models
    """
    try:
        if not file.content_type.startswith("image/"):
            raise HTTPException(status_code=400, detail="File must be an image")
        
        image_bytes = await file.read()
        
        # Run prediction
        disease_name, confidence, top_3, processing_time = ml_service.predict(image_bytes)
        
        # Parse device info
        device_dict = {}
        if device_info:
            try:
                import json
                device_dict = json.loads(device_info)
            except:
                device_dict = {"raw": device_info}
        
        # Log prediction (cloud inference = False for local_inference flag)
        prediction_id = await LoggingService.log_prediction(
            db=db,
            user_id=user_id,
            image_name=file.filename,
            predicted_disease=disease_name,
            confidence=confidence,
            local_inference=False,  # This is cloud inference
            processing_time_ms=processing_time,
            device_info=device_dict
        )
        
        # Get recommendations
        recommendations = recommendation_service.get_recommendations(disease_name)
        
        # Parse disease name
        if "___" in disease_name:
            plant, condition = disease_name.split("___")
            display_name = condition.replace("_", " ")
            plant_name = plant.replace("_", " ")
        else:
            display_name = disease_name.replace("_", " ")
            plant_name = "Unknown"
        
        response = {
            "prediction_id": prediction_id,
            "disease_code": disease_name,
            "disease_name": display_name,
            "plant_type": plant_name,
            "confidence": confidence,
            "confidence_percentage": f"{confidence * 100:.2f}%",
            "is_confident": confidence >= 0.85,
            "top_3_predictions": top_3,
            "recommendations": recommendations,
            "processing_time_ms": processing_time,
            "timestamp": datetime.utcnow().isoformat()
        }
        
        return response
        
    except Exception as e:
        logger.error(f"Prediction error: {e}")
        raise HTTPException(status_code=500, detail=str(e))

@router.post("/log-local")
async def log_local_prediction(
    request: LocalPredictionRequest,
    user_id: Optional[str] = Header(None, alias="X-User-ID"),
    authorization: Optional[str] = Header(None, alias="Authorization"),
    device_info: Optional[str] = Header(None, alias="X-Device-Info"),
    db: AsyncSession = Depends(get_db_session)
):
    """
    Endpoint for Flutter app to log TFLite predictions
    This is the key hybrid endpoint - logs local inferences
    """
    try:
        if not user_id and authorization and authorization.startswith("Bearer "):
            try:
                from jose import jwt
                import os
                token = authorization.split(" ")[1]
                secret = os.getenv("SECRET_KEY", "your-secret-key-change-this")
                payload = jwt.decode(token, secret, algorithms=["HS256"])
                user_id = payload.get("sub")
            except Exception as e:
                logger.warning(f"Could not decode Authorization token in log-local: {e}")

        device_dict = {}
        if device_info:
            try:
                import json
                device_dict = json.loads(device_info)
            except:
                device_dict = {"raw": device_info}
        
        # Log the local TFLite prediction
        prediction_id = await LoggingService.log_prediction(
            db=db,
            user_id=user_id,
            image_name=request.image_name,
            predicted_disease=request.disease_code,
            confidence=request.confidence,
            local_inference=True,  # This is local TFLite
            processing_time_ms=request.processing_time_ms,
            device_info=device_dict
        )
        
        # Get recommendations (optional, can be used to update UI)
        recommendations = recommendation_service.get_recommendations(request.disease_code)
        
        return {
            "status": "logged",
            "prediction_id": prediction_id,
            "recommendations": recommendations
        }
        
    except Exception as e:
        logger.error(f"Logging error: {e}")
        raise HTTPException(status_code=500, detail=str(e))

class FeedbackRequest(BaseModel):
    prediction_id: str
    was_correct: bool
    actual_disease: Optional[str] = None
    comments: Optional[str] = None

@router.post("/feedback")
async def submit_feedback(
    request: FeedbackRequest,
    user_id: Optional[str] = Header(None, alias="X-User-ID"),
    db: AsyncSession = Depends(get_db_session)
):
    """Submit feedback on prediction accuracy"""
    try:
        await LoggingService.log_feedback(
            db=db,
            prediction_id=request.prediction_id,
            user_id=user_id,
            was_correct=request.was_correct,
            actual_disease=request.actual_disease,
            comments=request.comments
        )
        
        return {
            "status": "success",
            "message": "Thank you for your feedback!"
        }
        
    except Exception as e:
        logger.error(f"Feedback error: {e}")
        raise HTTPException(status_code=500, detail=str(e))

@router.get("/history", response_model=List[PredictionResponse])
async def get_prediction_history(
    limit: int = Query(20, ge=1, le=100),
    skip: int = Query(0, ge=0),
    current_user: dict = Depends(get_current_user),
    x_user_id: Optional[str] = Header(None, alias="X-User-ID"),
    db: AsyncSession = Depends(get_db_session)
):
    """
    Get prediction history for the logged-in user.
    Queries by BOTH the JWT user_id AND the X-User-ID header value
    to cover the case where the header user_id is used during logging.
    """
    try:
        # Build user_id from JWT token
        jwt_user_id = str(current_user.id) if hasattr(current_user, "id") else str(current_user.get("id") or current_user.get("_id", ""))
        
        logger.info(f"📋 History Request: JWT_UID={jwt_user_id}, Header_UID={x_user_id}")
        
        # Include both jwt_user_id and X-User-ID header to catch all stored formats
        user_ids = list({uid for uid in [jwt_user_id, x_user_id] if uid and uid.strip()})
        logger.info(f"📋 Searching for user_ids: {user_ids}")
        
        if not user_ids:
            return []
        
        stmt = select(PredictionLog).filter(PredictionLog.user_id.in_(user_ids)).order_by(PredictionLog.created_at.desc()).offset(skip).limit(limit)
        result = await db.execute(stmt)
        preds = result.scalars().all()
        
        predictions = []
        for pred in preds:
            predictions.append(PredictionResponse(
                id=str(pred.id),
                predicted_disease=pred.predicted_disease,
                plant_name=pred.plant_name,
                confidence=pred.confidence,
                top_predictions=pred.top_predictions,
                inference_mode=pred.inference_mode,
                processing_time_ms=pred.processing_time_ms,
                created_at=pred.created_at,
                recommendation=None
            ))
        
        return predictions
        
    except Exception as e:
        logger.error(f"Error getting history: {e}")
        raise HTTPException(status_code=500, detail=str(e))

@router.get("/history/count")
async def get_prediction_count(
    current_user: dict = Depends(get_current_user),
    db: AsyncSession = Depends(get_db_session)
):
    """
    Get total prediction count for the user
    """
    try:
        from sqlalchemy import func
        user_id_str = str(current_user.id) if hasattr(current_user, "id") else str(current_user.get("id") or current_user.get("_id", ""))
        
        stmt = select(func.count(PredictionLog.id)).filter(PredictionLog.user_id == user_id_str)
        result = await db.execute(stmt)
        count = result.scalar()
        
        return {"total": count}
    except Exception as e:
        logger.error(f"Error getting count: {e}")
        raise HTTPException(status_code=500, detail=str(e))

@router.delete("/history/{prediction_id}")
async def delete_prediction(
    prediction_id: str,
    current_user: dict = Depends(get_current_user),
    db: AsyncSession = Depends(get_db_session)
):
    """
    Delete a specific prediction from history
    """
    try:
        user_id_str = str(current_user.id) if hasattr(current_user, "id") else str(current_user.get("id") or current_user.get("_id", ""))
        
        try:
            pred_id_int = int(prediction_id)
        except ValueError:
            raise HTTPException(status_code=400, detail="Invalid prediction ID format")

        stmt = select(PredictionLog).filter(PredictionLog.id == pred_id_int, PredictionLog.user_id == user_id_str)
        result = await db.execute(stmt)
        pred = result.scalars().first()
        
        if not pred:
            raise HTTPException(status_code=404, detail="Prediction not found")
            
        await db.delete(pred)
        await db.commit()
        
        return {"message": "Prediction deleted successfully"}
        
    except Exception as e:
        logger.error(f"Error deleting history: {e}")
        raise HTTPException(status_code=500, detail=str(e))
