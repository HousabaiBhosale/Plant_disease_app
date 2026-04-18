from fastapi import APIRouter, HTTPException, Query, UploadFile, File, BackgroundTasks
from datetime import datetime, timedelta
from typing import Dict, List
from app.database.mongodb import get_predictions_collection, get_feedback_collection, get_analytics_collection
import logging

router = APIRouter()
logger = logging.getLogger(__name__)

@router.get("/stats")
async def get_admin_stats(days: int = Query(7, ge=1, le=30)):
    """Get admin statistics"""
    try:
        threshold = datetime.utcnow() - timedelta(days=days)
        predictions_collection = get_predictions_collection()
        
        # Get prediction stats
        pipeline = [
            {"$match": {"created_at": {"$gte": threshold}}},
            {"$group": {
                "_id": None,
                "total_predictions": {"$sum": 1},
                "local_predictions": {"$sum": {"$cond": ["$local_inference", 1, 0]}},
                "cloud_predictions": {"$sum": {"$cond": ["$local_inference", 0, 1]}},
                "avg_confidence": {"$avg": "$confidence"},
                "unique_users": {"$addToSet": "$user_id"}
            }}
        ]
        
        result = await predictions_collection.aggregate(pipeline).to_list(None)
        
        # Get top diseases
        disease_pipeline = [
            {"$match": {"created_at": {"$gte": threshold}}},
            {"$group": {
                "_id": "$predicted_disease",
                "count": {"$sum": 1},
                "avg_confidence": {"$avg": "$confidence"}
            }},
            {"$sort": {"count": -1}},
            {"$limit": 10}
        ]
        
        top_diseases = await predictions_collection.aggregate(disease_pipeline).to_list(None)
        
        # Get feedback stats
        feedback_collection = get_feedback_collection()
        feedback_pipeline = [
            {"$match": {"created_at": {"$gte": threshold}}},
            {"$group": {
                "_id": None,
                "total_feedback": {"$sum": 1},
                "correct": {"$sum": {"$cond": ["$was_correct", 1, 0]}},
                "incorrect": {"$sum": {"$cond": ["$was_correct", 0, 1]}}
            }}
        ]
        
        feedback_stats = await feedback_collection.aggregate(feedback_pipeline).to_list(None)
        
        stats = result[0] if result else {}
        feedback = feedback_stats[0] if feedback_stats else {}
        
        accuracy = (feedback.get("correct", 0) / feedback.get("total_feedback", 1) * 100) if feedback.get("total_feedback", 0) > 0 else 0
        
        return {
            "period_days": days,
            "total_predictions": stats.get("total_predictions", 0),
            "local_predictions": stats.get("local_predictions", 0),
            "cloud_predictions": stats.get("cloud_predictions", 0),
            "avg_confidence": f"{stats.get('avg_confidence', 0) * 100:.2f}%",
            "unique_users": len(stats.get("unique_users", [])),
            "top_diseases": [
                {"disease": d["_id"], "count": d["count"], "avg_confidence": f"{d['avg_confidence'] * 100:.2f}%"}
                for d in top_diseases
            ],
            "feedback": {
                "total": feedback.get("total_feedback", 0),
                "correct": feedback.get("correct", 0),
                "incorrect": feedback.get("incorrect", 0),
                "accuracy": f"{accuracy:.2f}%"
            },
            "timestamp": datetime.utcnow().isoformat()
        }
        
    except Exception as e:
        logger.error(f"Stats error: {e}")
        raise HTTPException(status_code=500, detail=str(e))

@router.get("/analytics/daily")
async def get_daily_analytics(days: int = Query(7, ge=1, le=30)):
    """Get daily analytics"""
    try:
        analytics_collection = get_analytics_collection()
        threshold = datetime.utcnow() - timedelta(days=days)
        
        pipeline = [
            {"$match": {"date": {"$gte": threshold.strftime("%Y-%m-%d")}}},
            {"$sort": {"date": 1}},
            {"$limit": days}
        ]
        
        results = await analytics_collection.aggregate(pipeline).to_list(None)
        
        # Format for charts (avoids ObjectId serialization crash)
        formatted_results = []
        for r in results:
            formatted_results.append({
                "date": r["date"],
                "accuracy": r.get("avg_confidence", 0) * 100,
                "predictions": r.get("total_predictions", 0),
                "local": r.get("local_predictions", 0),
                "cloud": r.get("cloud_predictions", 0)
            })
        
        return {
            "daily_stats": formatted_results,
            "timestamp": datetime.utcnow().isoformat()
        }
        
    except Exception as e:
        logger.error(f"Daily analytics error: {e}")
        raise HTTPException(status_code=500, detail=str(e))

@router.get("/predictions")
async def get_predictions(page: int = Query(1, ge=1), limit: int = Query(50, ge=1, le=100)):
    """Get paginated predictions"""
    try:
        skip = (page - 1) * limit
        collection = get_predictions_collection()
        total = await collection.count_documents({})
        cursor = collection.find({}).sort("created_at", -1).skip(skip).limit(limit)
        
        predictions = []
        async for doc in cursor:
            doc["_id"] = str(doc["_id"])
            if "created_at" in doc:
                doc["created_at"] = doc["created_at"].isoformat()
            predictions.append(doc)
            
        return {
            "data": predictions,
            "total": total,
            "page": page,
            "limit": limit,
            "pages": (total + limit - 1) // limit
        }
    except Exception as e:
        logger.error(f"Error fetching predictions: {e}")
        raise HTTPException(status_code=500, detail=str(e))

@router.get("/feedback")
async def get_feedback(page: int = Query(1, ge=1), limit: int = Query(50, ge=1, le=100)):
    """Get paginated feedback"""
    try:
        skip = (page - 1) * limit
        collection = get_feedback_collection()
        total = await collection.count_documents({})
        cursor = collection.find({}).sort("created_at", -1).skip(skip).limit(limit)
        
        feedback = []
        async for doc in cursor:
            doc["_id"] = str(doc["_id"])
            if "created_at" in doc:
                doc["created_at"] = doc["created_at"].isoformat()
            feedback.append(doc)
            
        return {
            "data": feedback,
            "total": total,
            "page": page,
            "limit": limit,
            "pages": (total + limit - 1) // limit
        }
    except Exception as e:
        logger.error(f"Error fetching feedback: {e}")
        raise HTTPException(status_code=500, detail=str(e))

@router.get("/model-metrics")
async def get_model_metrics():
    """Mocked metrics for dashboard display"""
    return {
        "accuracy": 92.5,
        "precision": 89.4,
        "recall": 91.2,
        "f1_score": 90.3,
        "last_trained": datetime.utcnow().strftime("%Y-%m-%d"),
        "training_samples": 87000,
        "num_classes": 38,
        "history": [
            {"epoch": 1, "accuracy": 45.2, "loss": 1.2},
            {"epoch": 10, "accuracy": 72.1, "loss": 0.8},
            {"epoch": 20, "accuracy": 85.4, "loss": 0.5},
            {"epoch": 30, "accuracy": 89.2, "loss": 0.3},
            {"epoch": 40, "accuracy": 91.5, "loss": 0.22},
            {"epoch": 50, "accuracy": 92.5, "loss": 0.18}
        ]
    }

@router.get("/dataset-info")
async def get_dataset_info():
    """Get basic mock dataset metadata"""
    return {
        "total_images": 87000,
        "classes": 38,
        "plants": 14,
        "size_mb": 1250,
        "last_updated": datetime.utcnow().isoformat()
    }

@router.post("/update-dataset")
async def update_dataset(dataset: UploadFile = File(...)):
    """Mock upload dataset"""
    # Simply reject it if not a zip, otherwise mock success.
    if not dataset.filename.endswith('.zip'):
        raise HTTPException(status_code=400, detail="Only .zip datasets are allowed.")
    return {"success": True, "message": "Dataset successfully staged for processing."}

@router.post("/retrain-model")
async def retrain_model(background_tasks: BackgroundTasks):
    """Mock model retraining endpoint"""
    # Normally this would trigger background_tasks.add_task(train_model)
    return {"success": True, "message": "Model retraining job queued securely in background."}

@router.get("/model-versions")
async def get_model_versions():
    """Mocked returning available model versions"""
    return [
        {"version": "v1.0.0", "accuracy": 88.5, "precision": 85.2, "recall": 87.1, "trained_date": "2024-01-10", "is_active": False},
        {"version": "v1.1.0", "accuracy": 92.5, "precision": 89.4, "recall": 91.2, "trained_date": "2024-02-15", "is_active": True}
    ]
