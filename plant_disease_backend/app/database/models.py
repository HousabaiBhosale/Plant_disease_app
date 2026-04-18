from datetime import datetime
from typing import Optional, Dict, Any
from enum import Enum

from pydantic import BaseModel, Field, field_validator, EmailStr, model_validator
from bson import ObjectId


# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

class PyObjectId(str):
    """Serialize MongoDB ObjectId as a plain string in JSON responses."""
    @classmethod
    def __get_validators__(cls):
        yield cls.validate

    @classmethod
    def validate(cls, v, *args):
        if isinstance(v, ObjectId):
            return str(v)
        if isinstance(v, str) and ObjectId.is_valid(v):
            return v
        raise ValueError(f"Invalid ObjectId: {v!r}")


# ---------------------------------------------------------------------------
# Enums  — avoids typos in disease/status strings scattered around the code
# ---------------------------------------------------------------------------

class InferenceMode(str, Enum):
    LOCAL = "local"       # TFLite on-device
    CLOUD = "cloud"       # Server-side model


class PredictionStatus(str, Enum):
    PENDING  = "pending"
    COMPLETE = "complete"
    FAILED   = "failed"


# ---------------------------------------------------------------------------
# Prediction
# ---------------------------------------------------------------------------

class PredictionLog(BaseModel):
    """
    Written to DB every time a disease scan is performed.
    Supports both on-device (TFLite) and cloud inference modes.
    """
    id: Optional[PyObjectId]    = Field(default=None, alias="_id")
    user_id: Optional[str]      = None   # None for anonymous scans
    image_name: str
    predicted_disease: str
    plant_name: str              = ""    # e.g. "Tomato" — split from class label
    confidence: float            = Field(..., ge=0.0, le=1.0)
    top_predictions: list[Dict[str, Any]] = []   # [{label, confidence}, ...] top-3
    inference_mode: InferenceMode = InferenceMode.LOCAL
    processing_time_ms: float    = Field(..., ge=0)
    status: PredictionStatus     = PredictionStatus.COMPLETE
    device_info: Dict[str, Any]  = {}
    created_at: datetime         = Field(default_factory=datetime.utcnow)

    @field_validator("confidence")
    @classmethod
    def round_confidence(cls, v: float) -> float:
        return round(v, 4)

    @field_validator("predicted_disease")
    @classmethod
    def non_empty_disease(cls, v: str) -> str:
        if not v.strip():
            raise ValueError("predicted_disease must not be empty")
        return v.strip()

    @model_validator(mode="after")
    def split_plant_name(self) -> "PredictionLog":
        """Auto-populate plant_name from 'Plant___Disease' class label format."""
        if not self.plant_name and "___" in self.predicted_disease:
            self.plant_name = self.predicted_disease.split("___")[0].replace("_", " ")
        return self

    model_config = {"populate_by_name": True}


class PredictionResponse(BaseModel):
    """Returned to the Flutter app / API consumers — never exposes raw DB fields."""
    id: str
    predicted_disease: str
    plant_name: str
    confidence: float
    top_predictions: list[Dict[str, Any]]
    inference_mode: InferenceMode
    processing_time_ms: float
    created_at: datetime
    recommendation: Optional[str] = None   # filled in by the recommendation service


# ---------------------------------------------------------------------------
# Feedback
# ---------------------------------------------------------------------------

class UserFeedback(BaseModel):
    """User correction / rating after a prediction."""
    id: Optional[PyObjectId]  = Field(default=None, alias="_id")
    prediction_id: str
    user_id: Optional[str]    = None
    was_correct: bool
    actual_disease: Optional[str] = None
    comments: Optional[str]       = Field(default=None, max_length=500)
    created_at: datetime           = Field(default_factory=datetime.utcnow)

    @model_validator(mode="after")
    def require_actual_if_wrong(self) -> "UserFeedback":
        """If the prediction was wrong, ask for the actual disease label."""
        if not self.was_correct and not self.actual_disease:
            raise ValueError(
                "actual_disease is required when was_correct is False"
            )
        return self

    model_config = {"populate_by_name": True}


# ---------------------------------------------------------------------------
# Analytics
# ---------------------------------------------------------------------------

class ModelAnalytics(BaseModel):
    """
    One document per calendar day (unique index on `date`).
    Upserted by the analytics worker, not created directly by user requests.
    """
    id: Optional[PyObjectId] = Field(default=None, alias="_id")
    date: str                  # ISO date "2025-03-27"
    total_predictions: int     = 0
    local_predictions: int     = 0
    cloud_predictions: int     = 0
    avg_confidence: float      = 0.0
    correct_predictions: int   = 0
    incorrect_predictions: int = 0
    # Per-disease breakdown — { "Tomato___Early_blight": 42, ... }
    disease_counts: Dict[str, int] = {}

    @field_validator("date")
    @classmethod
    def valid_iso_date(cls, v: str) -> str:
        try:
            datetime.strptime(v, "%Y-%m-%d")
        except ValueError:
            raise ValueError("date must be ISO format YYYY-MM-DD")
        return v

    model_config = {"populate_by_name": True}


class AnalyticsResponse(BaseModel):
    """Public-facing analytics payload (safe to return from /admin endpoints)."""
    date: str
    total_predictions: int
    avg_confidence: float
    accuracy_rate: Optional[float] = None  # correct / (correct + incorrect)
    top_diseases: list[Dict[str, Any]] = []  # [{"disease": ..., "count": ...}]


# ---------------------------------------------------------------------------
# Users
# ---------------------------------------------------------------------------

class UserCreate(BaseModel):
    name: str  = Field(..., min_length=2, max_length=80)
    email: EmailStr
    password: str = Field(..., min_length=6, max_length=72)

    @field_validator("name")
    @classmethod
    def strip_name(cls, v: str) -> str:
        return v.strip()


class UserLogin(BaseModel):
    email: EmailStr
    password: str = Field(..., min_length=1, max_length=72)


class UserInDB(BaseModel):
    """Internal representation — never serialise password_hash to responses."""
    id: Optional[PyObjectId] = Field(default=None, alias="_id")
    name: str
    email: str
    password_hash: str
    firebase_uid: Optional[str] = None   # set if user also authenticated via Firebase
    is_active: bool   = True
    is_admin: bool    = False
    created_at: datetime = Field(default_factory=datetime.utcnow)
    last_login: Optional[datetime] = None

    model_config = {"populate_by_name": True}


class UserResponse(BaseModel):
    """Safe public representation — no password_hash, no internal flags."""
    id: str
    name: str
    email: str
    is_admin: bool
    created_at: datetime
    last_login: Optional[datetime] = None


class TokenResponse(BaseModel):
    access_token: str
    token_type: str = "bearer"
    user: UserResponse


class TokenBlacklist(BaseModel):
    """Stores invalidated JWTs until they naturally expire."""
    id: Optional[PyObjectId] = Field(default=None, alias="_id")
    token: str
    expires_at: datetime

    model_config = {"populate_by_name": True}


# ---------------------------------------------------------------------------
# Pagination (needed by the admin dashboard listing endpoints)
# ---------------------------------------------------------------------------

class PaginatedResponse(BaseModel):
    items: list[Any]
    total: int
    page: int
    page_size: int
    total_pages: int

    @model_validator(mode="after")
    def compute_total_pages(self) -> "PaginatedResponse":
        if self.page_size > 0:
            import math
            self.total_pages = math.ceil(self.total / self.page_size)
        return self