from fastapi import APIRouter, File, UploadFile, HTTPException, Header, Depends, Query
from typing import Optional, List
import uuid
import logging
from datetime import datetime

from app.database.mongodb import get_predictions_collection
from app.api.auth import get_current_user
from app.database.models import PredictionResponse

from app.services.ml_service import ml_service
from app.services.recommendation_service import recommendation_service
from app.services.logging_service import LoggingService

router = APIRouter()
logger = logging.getLogger(__name__)

@router.post("/")
async def predict_disease(
    file: UploadFile = File(...),
    user_id: Optional[str] = Header(None, alias="X-User-ID"),
    device_info: Optional[str] = Header(None, alias="X-Device-Info")
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
    disease_code: str,
    confidence: float,
    image_name: str,
    processing_time_ms: float,
    user_id: Optional[str] = Header(None, alias="X-User-ID"),
    device_info: Optional[str] = Header(None, alias="X-Device-Info")
):
    """
    Endpoint for Flutter app to log TFLite predictions
    This is the key hybrid endpoint - logs local inferences
    """
    try:
        device_dict = {}
        if device_info:
            try:
                import json
                device_dict = json.loads(device_info)
            except:
                device_dict = {"raw": device_info}
        
        # Log the local TFLite prediction
        prediction_id = await LoggingService.log_prediction(
            user_id=user_id,
            image_name=image_name,
            predicted_disease=disease_code,
            confidence=confidence,
            local_inference=True,  # This is local TFLite
            processing_time_ms=processing_time_ms,
            device_info=device_dict
        )
        
        # Get recommendations (optional, can be used to update UI)
        recommendations = recommendation_service.get_recommendations(disease_code)
        
        return {
            "status": "logged",
            "prediction_id": prediction_id,
            "recommendations": recommendations
        }
        
    except Exception as e:
        logger.error(f"Logging error: {e}")
        raise HTTPException(status_code=500, detail=str(e))

@router.post("/feedback")
async def submit_feedback(
    prediction_id: str,
    was_correct: bool,
    actual_disease: Optional[str] = None,
    comments: Optional[str] = None,
    user_id: Optional[str] = Header(None, alias="X-User-ID")
):
    """Submit feedback on prediction accuracy"""
    try:
        await LoggingService.log_feedback(
            prediction_id=prediction_id,
            user_id=user_id,
            was_correct=was_correct,
            actual_disease=actual_disease,
            comments=comments
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
    current_user: dict = Depends(get_current_user)
):
    """
    Get prediction history for the logged-in user
    This replaces SQLite local storage with cloud storage
    """
    try:
        predictions_collection = get_predictions_collection()
        
        # Get predictions for this user only
        user_id_str = str(current_user.id) if hasattr(current_user, "id") else str(current_user.get("id") or current_user.get("_id", ""))
        cursor = predictions_collection.find(
            {"user_id": user_id_str}
        ).sort(
            "created_at", -1  # Most recent first
        ).skip(skip).limit(limit)
        
        predictions = []
        async for pred in cursor:
            predictions.append(PredictionResponse(
                id=str(pred["_id"]),
                predicted_disease=pred["predicted_disease"],
                plant_name=pred.get("plant_name", ""),
                confidence=pred["confidence"],
                top_predictions=pred.get("top_predictions", []),
                inference_mode=pred.get("inference_mode", "local"),
                processing_time_ms=pred.get("processing_time_ms", 0.0),
                created_at=pred["created_at"],
                recommendation=None  # Can add recommendation here
            ))
        
        return predictions
        
    except Exception as e:
        logger.error(f"Error getting history: {e}")
        raise HTTPException(status_code=500, detail=str(e))

@router.get("/history/count")
async def get_prediction_count(
    current_user: dict = Depends(get_current_user)
):
    """
    Get total prediction count for the user
    """
    try:
        predictions_collection = get_predictions_collection()
        user_id_str = str(current_user.id) if hasattr(current_user, "id") else str(current_user.get("id") or current_user.get("_id", ""))
        count = await predictions_collection.count_documents(
            {"user_id": user_id_str}
        )
        return {"total": count}
    except Exception as e:
        logger.error(f"Error getting count: {e}")
        raise HTTPException(status_code=500, detail=str(e))

@router.delete("/history/{prediction_id}")
async def delete_prediction(
    prediction_id: str,
    current_user: dict = Depends(get_current_user)
):
    """
    Delete a specific prediction from history
    """
    try:
        from bson import ObjectId
        
        predictions_collection = get_predictions_collection()
        user_id_str = str(current_user.id) if hasattr(current_user, "id") else str(current_user.get("id") or current_user.get("_id", ""))
        
        result = await predictions_collection.delete_one({
            "_id": ObjectId(prediction_id),
            "user_id": user_id_str  # Ensure user owns this prediction
        })
        
        if result.deleted_count == 0:
            # Maybe the user id is stored as ObjectId fallback check
            result = await predictions_collection.delete_one({
                "_id": ObjectId(prediction_id)
            })
            if result.deleted_count == 0:
                raise HTTPException(status_code=404, detail="Prediction not found")
        
        return {"message": "Prediction deleted successfully"}
        
    except Exception as e:
        logger.error(f"Error deleting history: {e}")
        raise HTTPException(status_code=500, detail=str(e))
