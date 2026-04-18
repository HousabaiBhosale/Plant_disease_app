from datetime import datetime, timedelta
from typing import Optional, Dict
import logging
from app.database.mongodb import get_predictions_collection, get_feedback_collection, get_analytics_collection
from app.database.models import PredictionLog, UserFeedback

logger = logging.getLogger(__name__)

class LoggingService:
    
    @staticmethod
    async def log_prediction(
        user_id: Optional[str],
        image_name: str,
        predicted_disease: str,
        confidence: float,
        local_inference: bool,
        processing_time_ms: float,
        device_info: Dict
    ) -> Optional[str]:
        """Log a prediction"""
        try:
            prediction_log = PredictionLog(
                user_id=user_id,
                image_name=image_name,
                predicted_disease=predicted_disease,
                confidence=confidence,
                local_inference=local_inference,
                processing_time_ms=processing_time_ms,
                device_info=device_info
            )
            
            collection = get_predictions_collection()
            result = await collection.insert_one(prediction_log.dict())
            
            # Update daily analytics
            await LoggingService.update_daily_analytics(prediction_log)
            
            logger.info(f"Prediction logged: {result.inserted_id}")
            return str(result.inserted_id)
            
        except Exception as e:
            logger.error(f"Failed to log prediction: {e}")
            return None
    
    @staticmethod
    async def update_daily_analytics(prediction: PredictionLog):
        """Update daily analytics counts"""
        try:
            # Update daily analytics
            date_str = prediction.created_at.strftime("%Y-%m-%d")
            collection = get_analytics_collection()
            
            # Find current analytics for the day
            current = await collection.find_one({"date": date_str})
            
            if current:
                total = current.get("total_predictions", 0)
                old_avg = current.get("avg_confidence", 0)
                # Calculate running average
                new_avg = (old_avg * total + prediction.confidence) / (total + 1)
                
                await collection.update_one(
                    {"date": date_str},
                    {
                        "$inc": {
                            "total_predictions": 1,
                            "local_predictions": 1 if prediction.local_inference else 0,
                            "cloud_predictions": 0 if prediction.local_inference else 1
                        },
                        "$set": {"avg_confidence": new_avg}
                    }
                )
            else:
                # First prediction of the day
                await collection.insert_one({
                    "date": date_str,
                    "total_predictions": 1,
                    "local_predictions": 1 if prediction.local_inference else 0,
                    "cloud_predictions": 0 if prediction.local_inference else 1,
                    "avg_confidence": prediction.confidence
                })
        except Exception as e:
            logger.error(f"Failed to update analytics: {e}")
    
    @staticmethod
    async def log_feedback(
        prediction_id: str,
        user_id: Optional[str],
        was_correct: bool,
        actual_disease: Optional[str],
        comments: Optional[str]
    ):
        """Log user feedback"""
        try:
            feedback = UserFeedback(
                prediction_id=prediction_id,
                user_id=user_id,
                was_correct=was_correct,
                actual_disease=actual_disease,
                comments=comments
            )
            
            collection = get_feedback_collection()
            await collection.insert_one(feedback.dict())
            
            logger.info(f"Feedback logged for prediction: {prediction_id}")
            
        except Exception as e:
            logger.error(f"Failed to log feedback: {e}")
