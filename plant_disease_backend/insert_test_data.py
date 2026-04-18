import asyncio
from datetime import datetime, timedelta
import random
from motor.motor_asyncio import AsyncIOMotorClient

async def insert_test_data():
    # Connect to MongoDB
    client = AsyncIOMotorClient("mongodb://localhost:27017")
    db = client["plant_disease_db"]
    
    # Target User ID (Matching the one found in check_history.py)
    TARGET_USER_ID = "69cc0cc1def0caaadb1f8bf5"
    
    # Clear existing data
    await db.predictions.delete_many({})
    await db.feedback.delete_many({})
    await db.analytics.delete_many({})
    
    # Diseases list
    diseases = [
        "Tomato___Late_blight",
        "Tomato___Early_blight",
        "Apple___Apple_scab",
        "Apple___Black_rot",
        "Grape___Black_rot",
        "Grape___Esca_(Black_Measles)",
        "Potato___Late_blight",
        "Corn___Common_rust",
        "Corn___Northern_Leaf_Blight",
        "Tomato___healthy",
        "Apple___healthy",
        "Potato___healthy"
    ]
    
    devices = [
        {"model": "Pixel 7 Pro", "os": "Android 14"},
        {"model": "Samsung Galaxy S23", "os": "Android 13"},
        {"model": "iPhone 15", "os": "iOS 17"},
        {"model": "Redmi Note 12", "os": "Android 12"}
    ]
    
    # Insert 150 test predictions
    predictions = []
    print("⏳ Generating 150 realistic scan records...")
    for i in range(150):
        # 70% of scans belong to the primary user to show a rich history
        user_id = TARGET_USER_ID if random.random() < 0.7 else f"user_{random.randint(1, 10)}"
        
        days_ago = random.randint(0, 30)
        # Weight towards more recent days
        if random.random() < 0.4:
            days_ago = random.randint(0, 3)
            
        created_at = datetime.utcnow() - timedelta(days=days_ago, hours=random.randint(0, 23), minutes=random.randint(0, 59))
        
        is_local = random.choice([True, True, False]) # 66% local TFLite
        confidence = random.uniform(0.78, 0.99)
        
        disease = random.choice(diseases)
        # Ensure 'healthy' has high confidence
        if 'healthy' in disease:
            confidence = random.uniform(0.92, 0.99)
            
        predictions.append({
            "user_id": user_id,
            "image_name": f"scan_{int(created_at.timestamp())}_{i}.jpg",
            "predicted_disease": disease,
            "confidence": confidence,
            "local_inference": is_local,
            "processing_time_ms": random.uniform(80, 350) if is_local else random.uniform(800, 1500),
            "device_info": random.choice(devices),
            "created_at": created_at
        })
    
    # Sort by date for bulk insert
    predictions.sort(key=lambda x: x["created_at"])
    
    result = await db.predictions.insert_many(predictions)
    print(f"✅ Inserted {len(result.inserted_ids)} predictions")
    
    # Insert feedback for 40% of predictions
    feedbacks = []
    print("⏳ Generating user feedback...")
    for pred_doc in predictions:
        if random.random() < 0.4:
            was_correct = random.random() < 0.85 # 85% accuracy
            feedbacks.append({
                "prediction_id": str(pred_doc["_id"]),
                "user_id": pred_doc["user_id"],
                "was_correct": was_correct,
                "actual_disease": pred_doc["predicted_disease"] if was_correct else random.choice(diseases),
                "comments": "Matches my observation" if was_correct else "Looks like something else",
                "created_at": pred_doc["created_at"] + timedelta(minutes=random.randint(1, 10))
            })
    
    if feedbacks:
        await db.feedback.insert_many(feedbacks)
        print(f"✅ Inserted {len(feedbacks)} feedback entries")
    
    # Generate daily analytics with matching confidence/accuracy
    print("⏳ Calculating daily analytics...")
    analytics = []
    for day in range(31):
        date_dt = (datetime.utcnow() - timedelta(days=day))
        date_str = date_dt.strftime("%Y-%m-%d")
        
        # Filter predictions for this specific day
        day_preds = [p for p in predictions if p["created_at"].strftime("%Y-%m-%d") == date_str]
        
        if day_preds:
            total = len(day_preds)
            local = len([p for p in day_preds if p["local_inference"]])
            cloud = total - local
            avg_conf = sum(p["confidence"] for p in day_preds) / total
            
            analytics.append({
                "date": date_str,
                "total_predictions": total,
                "local_predictions": local,
                "cloud_predictions": cloud,
                "avg_confidence": avg_conf
            })
    
    if analytics:
        await db.analytics.insert_many(analytics)
        print(f"✅ Inserted {len(analytics)} daily analytic summaries")
    
    print("\n🎉 Database fully populated with 'Real' scan history!")
    print(f"User ID {TARGET_USER_ID} now has {len([p for p in predictions if p['user_id'] == TARGET_USER_ID])} scans.")

if __name__ == "__main__":
    asyncio.run(insert_test_data())
