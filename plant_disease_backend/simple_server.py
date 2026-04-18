from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from datetime import datetime

app = FastAPI()

# Enable CORS for dashboard
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.get("/")
def root():
    return {
        "name": "Plant Disease API",
        "status": "running",
        "timestamp": datetime.now().isoformat()
    }

@app.get("/health")
def health():
    return {"status": "healthy"}

@app.get("/api/admin/stats")
def get_stats():
    return {
        "total_predictions": 1247,
        "local_predictions": 812,
        "cloud_predictions": 435,
        "avg_confidence": "87.3%",
        "unique_users": 342,
        "top_diseases": [
            {"disease": "Tomato Late Blight", "count": 156},
            {"disease": "Apple Scab", "count": 98},
            {"disease": "Potato Early Blight", "count": 76},
        ],
        "feedback": {
            "total": 342,
            "correct": 298,
            "incorrect": 44,
            "accuracy": "87.1%"
        }
    }

@app.get("/api/admin/analytics/daily")
def get_daily_analytics():
    return {
        "daily_stats": [
            {"date": "2024-03-25", "accuracy": 86.5, "predictions": 45},
            {"date": "2024-03-26", "accuracy": 87.2, "predictions": 52},
            {"date": "2024-03-27", "accuracy": 88.1, "predictions": 48},
            {"date": "2024-03-28", "accuracy": 87.8, "predictions": 56},
            {"date": "2024-03-29", "accuracy": 89.0, "predictions": 61},
            {"date": "2024-03-30", "accuracy": 88.5, "predictions": 53},
            {"date": "2024-03-31", "accuracy": 89.2, "predictions": 59},
        ]
    }

@app.get("/api/admin/model-metrics")
def get_model_metrics():
    return {
        "accuracy": "87.3%",
        "precision": "85.6%",
        "recall": "88.1%",
        "f1_score": "86.8%",
        "last_trained": "2024-03-15",
        "training_samples": 54303,
        "num_classes": 38
    }

@app.get("/api/admin/model-versions")
def get_model_versions():
    return [
        {"version": "v3.0", "trained_date": "2024-03-15", "accuracy": "87.3%", "is_active": True},
        {"version": "v2.0", "trained_date": "2024-02-01", "accuracy": "84.2%", "is_active": False},
        {"version": "v1.0", "trained_date": "2024-01-01", "accuracy": "79.8%", "is_active": False},
    ]

@app.get("/api/admin/dataset-info")
def get_dataset_info():
    return {
        "total_images": 54303,
        "classes": 38,
        "last_updated": "2024-03-15",
        "new_samples": 1247,
        "status": "up_to_date"
    }

if __name__ == "__main__":
    import uvicorn
    print("=" * 50)
    print("🌱 Plant Disease Detection API - Simple Server")
    print("=" * 50)
    print("Server running at: http://localhost:8000")
    print("Dashboard URL: http://localhost:3000")
    print("=" * 50)
    uvicorn.run(app, host="127.0.0.1", port=8000)