from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
import logging
from datetime import datetime

from app.config import settings
from app.database.mongodb import MongoDB
from app.services.ml_service import ml_service
from app.api import predictions, admin, auth

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

# Create FastAPI app
app = FastAPI(
    title="Plant Disease Detection API",
    description="Backend API for Plant Disease Detection App - Hybrid Architecture",
    version=settings.API_VERSION
)

# Configure CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=[
        "http://localhost:3000",
        "http://127.0.0.1:3000",
        "http://0.0.0.0:3000",
    ],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Include routers
app.include_router(auth.router, prefix="/api/auth", tags=["Authentication"])
app.include_router(predictions.router, prefix="/api/predict", tags=["Predictions"])
app.include_router(admin.router, prefix="/api/admin", tags=["Admin"])

@app.on_event("startup")
async def startup_event():
    """Connect to database on startup"""
    await MongoDB.connect_to_database()
    logger.info(f"Model loaded with {len(ml_service.idx_to_class)} classes")
    logger.info("Application startup complete")

@app.on_event("shutdown")
async def shutdown_event():
    """Close database connection on shutdown"""
    await MongoDB.close_database_connection()
    logger.info("Application shutdown complete")

@app.get("/")
async def root():
    """Root endpoint"""
    return {
        "name": "Plant Disease Detection API",
        "version": settings.API_VERSION,
        "status": "running",
        "architecture": "Hybrid (TFLite + Cloud)",
        "model_loaded": ml_service.model is not None,
        "classes_count": len(ml_service.idx_to_class) if ml_service.idx_to_class else 0,
        "timestamp": datetime.utcnow().isoformat()
    }

@app.get("/health")
async def health_check():
    """Health check endpoint"""
    return {
        "status": "healthy",
        "database": "connected" if MongoDB.database else "disconnected",
        "model": "loaded" if ml_service.model else "not_loaded",
        "timestamp": datetime.utcnow().isoformat()
    }
