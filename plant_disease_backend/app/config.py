import os
from pydantic_settings import BaseSettings
from dotenv import load_dotenv

load_dotenv()

class Settings(BaseSettings):
    # MongoDB
    MONGODB_URL: str = os.getenv("MONGODB_URL", "mongodb://localhost:27017")
    DATABASE_NAME: str = os.getenv("DATABASE_NAME", "plant_disease_db")
    
    # JWT Authentication
    SECRET_KEY: str = os.getenv("SECRET_KEY", "your-secret-key-change-this")
    ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 30
    
    # Model Settings
    MODEL_PATH: str = "data/best_model.keras"
    CLASS_INDICES_PATH: str = "data/class_indices.json"
    RECOMMENDATIONS_PATH: str = "data/recommendations.json"
    
    # API Settings
    API_VERSION: str = "v1"
    DEBUG: bool = True
    
    # Confidence Threshold
    MIN_CONFIDENCE: float = 0.85

settings = Settings()
