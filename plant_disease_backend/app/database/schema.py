from sqlalchemy import Column, Integer, String, Float, Boolean, DateTime, JSON, ForeignKey
from sqlalchemy.sql import func
from app.database.mysql_db import Base

class User(Base):
    __tablename__ = "users"
    
    id = Column(Integer, primary_key=True, index=True)
    name = Column(String(80), nullable=False)
    email = Column(String(120), unique=True, index=True, nullable=False)
    password_hash = Column(String(255), nullable=False)
    firebase_uid = Column(String(120), unique=True, index=True, nullable=True)
    is_active = Column(Boolean, default=True)
    is_admin = Column(Boolean, default=False)
    latitude = Column(String(50), nullable=True)
    longitude = Column(String(50), nullable=True)
    city = Column(String(100), nullable=True)
    state = Column(String(100), nullable=True)
    country = Column(String(100), nullable=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    last_login = Column(DateTime(timezone=True), nullable=True)

class PredictionLog(Base):
    __tablename__ = "prediction_logs"
    
    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(String(120), index=True, nullable=True)
    image_name = Column(String(255), nullable=False)
    predicted_disease = Column(String(120), index=True, nullable=False)
    plant_name = Column(String(120), nullable=False)
    confidence = Column(Float, nullable=False)
    top_predictions = Column(JSON, nullable=False)
    inference_mode = Column(String(50), nullable=False)
    processing_time_ms = Column(Float, nullable=False)
    status = Column(String(50), nullable=False)
    device_info = Column(JSON, nullable=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now(), index=True)

class UserFeedback(Base):
    __tablename__ = "user_feedback"
    
    id = Column(Integer, primary_key=True, index=True)
    prediction_id = Column(String(120), index=True, nullable=False)
    user_id = Column(String(120), index=True, nullable=True)
    was_correct = Column(Boolean, nullable=False)
    actual_disease = Column(String(120), nullable=True)
    comments = Column(String(500), nullable=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now())

class ModelAnalytics(Base):
    __tablename__ = "model_analytics"
    
    id = Column(Integer, primary_key=True, index=True)
    date = Column(String(50), unique=True, index=True, nullable=False)
    total_predictions = Column(Integer, default=0)
    local_predictions = Column(Integer, default=0)
    cloud_predictions = Column(Integer, default=0)
    avg_confidence = Column(Float, default=0.0)
    correct_predictions = Column(Integer, default=0)
    incorrect_predictions = Column(Integer, default=0)
    disease_counts = Column(JSON, nullable=False)

class TokenBlacklist(Base):
    __tablename__ = "token_blacklist"
    
    id = Column(Integer, primary_key=True, index=True)
    token = Column(String(500), unique=True, index=True, nullable=False)
    expires_at = Column(DateTime(timezone=True), nullable=False)
    created_at = Column(DateTime(timezone=True), server_default=func.now())

class UserLocation(Base):
    __tablename__ = "user_locations"
    
    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, nullable=True)
    latitude = Column(Float, nullable=True)
    longitude = Column(Float, nullable=True)
    city = Column(String(100), nullable=True)
    state = Column(String(100), nullable=True)
    country = Column(String(100), nullable=True)
    updated_at = Column(DateTime(timezone=True), server_default=func.now())

class Dataset(Base):
    __tablename__ = "datasets"
    
    id = Column(Integer, primary_key=True, index=True)
    name = Column(String(255), nullable=False)
    num_images = Column(Integer, default=0)
    num_classes = Column(Integer, default=0)
    storage_path = Column(String(255), nullable=False)
    status = Column(String(50), default="Not Trained") # Not Trained, Training, Trained
    upload_date = Column(DateTime(timezone=True), server_default=func.now())

class ModelVersion(Base):
    __tablename__ = "model_versions"
    
    id = Column(Integer, primary_key=True, index=True)
    name = Column(String(255), nullable=False)
    dataset_ids_used = Column(JSON, nullable=False)
    accuracy = Column(Float, nullable=True)
    file_path = Column(String(255), nullable=False)
    is_active = Column(Boolean, default=False)
    training_date = Column(DateTime(timezone=True), server_default=func.now())
