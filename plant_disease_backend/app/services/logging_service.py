from datetime import datetime, timedelta
from typing import Optional, Dict
import logging
from app.database.schema import PredictionLog, UserFeedback, ModelAnalytics
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, update

logger = logging.getLogger(__name__)

class LoggingService:
    
    @staticmethod
    async def log_prediction(
        db: AsyncSession,
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
            # Set inference_mode correctly based on local_inference boolean flag
            # Assuming 'local_inference' means 'local' and False means 'cloud' based on usage
            inference_mode = "local" if local_inference else "cloud"
            
            # Auto-populate plant_name
            plant_name = ""
            if "___" in predicted_disease:
                plant_name = predicted_disease.split("___")[0].replace("_", " ")

            prediction_log = PredictionLog(
                user_id=user_id,
                image_name=image_name,
                predicted_disease=predicted_disease,
                plant_name=plant_name,
                confidence=confidence,
                inference_mode=inference_mode,
                top_predictions={},  # Or pass from caller
                status="complete",
                processing_time_ms=processing_time_ms,
                device_info=device_info
            )
            
            db.add(prediction_log)
            await db.flush() # To get the ID
            
            # Update daily analytics
            await LoggingService.update_daily_analytics(db, prediction_log, local_inference)
            
            await db.commit()
            
            logger.info(f"Prediction logged: {prediction_log.id}")
            return str(prediction_log.id)
            
        except Exception as e:
            await db.rollback()
            logger.error(f"Failed to log prediction: {e}")
            return None
    
    @staticmethod
    async def update_daily_analytics(db: AsyncSession, prediction: PredictionLog, local_inference: bool):
        """Update daily analytics counts"""
        try:
            # Update daily analytics
            date_str = prediction.created_at.strftime("%Y-%m-%d") if prediction.created_at else datetime.utcnow().strftime("%Y-%m-%d")
            
            # Find current analytics for the day
            result = await db.execute(select(ModelAnalytics).filter(ModelAnalytics.date == date_str))
            current = result.scalars().first()
            
            if current:
                total = current.total_predictions
                old_avg = current.avg_confidence
                # Calculate running average
                new_avg = (old_avg * total + prediction.confidence) / (total + 1)
                
                current.total_predictions += 1
                if local_inference:
                    current.local_predictions += 1
                else:
                    current.cloud_predictions += 1
                current.avg_confidence = new_avg
            else:
                # First prediction of the day
                new_analytics = ModelAnalytics(
                    date=date_str,
                    total_predictions=1,
                    local_predictions=1 if local_inference else 0,
                    cloud_predictions=0 if local_inference else 1,
                    avg_confidence=prediction.confidence,
                    disease_counts={}
                )
                db.add(new_analytics)
        except Exception as e:
            logger.error(f"Failed to update analytics: {e}")
    
    @staticmethod
    async def log_feedback(
        db: AsyncSession,
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
            
            db.add(feedback)
            await db.commit()
            
            logger.info(f"Feedback logged for prediction: {prediction_id}")
            
        except Exception as e:
            logger.error(f"Failed to log feedback: {e}")
