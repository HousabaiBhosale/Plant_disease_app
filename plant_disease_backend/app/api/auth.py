from fastapi import APIRouter, HTTPException, status, Depends
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from datetime import datetime, timedelta
from typing import Optional
from pydantic import BaseModel
from jose import jwt, JWTError
from passlib.context import CryptContext
import os

from app.database.mysql_db import get_db_session
from app.database.schema import User, TokenBlacklist as DBTokenBlacklist, UserLocation
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from app.database.models import (
    UserCreate, UserLogin, UserResponse, 
    TokenResponse, UserInDB, TokenBlacklist
)

router = APIRouter()
security = HTTPBearer()
pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

# JWT Configuration
SECRET_KEY = os.getenv("SECRET_KEY", "your-secret-key-change-this")
ALGORITHM = "HS256"
ACCESS_TOKEN_EXPIRE_MINUTES = 60 * 24 * 7  # 7 days


def verify_password(plain_password: str, hashed_password: str) -> bool:
    # bcrypt limit is 72 chars; truncate if somehow a longer one arrives
    return pwd_context.verify(plain_password[:72], hashed_password)


def get_password_hash(password: str) -> str:
    # bcrypt limit is 72 chars
    return pwd_context.hash(password[:72])


def create_access_token(data: dict) -> str:
    to_encode = data.copy()
    expire = datetime.utcnow() + timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
    to_encode.update({"exp": expire})
    return jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)


async def get_current_user(
    credentials: HTTPAuthorizationCredentials = Depends(security),
    db: AsyncSession = Depends(get_db_session)
) -> UserInDB:
    """Get current user from JWT token"""
    try:
        token = credentials.credentials
        
        # Check if token is blacklisted
        stmt = select(DBTokenBlacklist).filter(DBTokenBlacklist.token == token)
        result = await db.execute(stmt)
        blacklisted = result.scalars().first()
        if blacklisted:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Token has been revoked"
            )
        
        # Decode token
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        user_id = payload.get("sub")
        
        if not user_id:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Invalid token"
            )
        
        # Get user from database
        try:
            user_id_int = int(user_id)
        except ValueError:
            raise HTTPException(status_code=401, detail="Invalid token subject")
            
        stmt = select(User).filter(User.id == user_id_int)
        result = await db.execute(stmt)
        user_data = result.scalars().first()
        
        if not user_data:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="User not found"
            )
        
        return UserInDB(
            id=user_data.id,
            name=user_data.name,
            email=user_data.email,
            password_hash=user_data.password_hash,
            firebase_uid=user_data.firebase_uid,
            is_active=user_data.is_active,
            is_admin=user_data.is_admin,
            created_at=user_data.created_at,
            last_login=user_data.last_login
        )
        
    except JWTError:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Token has expired or is invalid"
        )


@router.post("/register", response_model=TokenResponse)
async def register(user_data: UserCreate, db: AsyncSession = Depends(get_db_session)):
    """Register a new user"""
    
    # Check if user exists
    stmt = select(User).filter(User.email == user_data.email)
    result = await db.execute(stmt)
    existing_user = result.scalars().first()
    
    if existing_user:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Email already registered"
        )
    
    # Create user
    user = User(
        name=user_data.name,
        email=user_data.email,
        password_hash=get_password_hash(user_data.password),
        is_active=True,
        is_admin=False,
    )
    
    db.add(user)
    await db.flush() # get ID
    await db.commit()
    await db.refresh(user)
    
    # Create token
    access_token = create_access_token({"sub": str(user.id)})
    
    return TokenResponse(
        access_token=access_token,
        token_type="bearer",
        user=UserResponse(
            id=str(user.id),
            name=user.name,
            email=user.email,
            is_admin=user.is_admin,
            created_at=user.created_at,
            last_login=None
        )
    )


@router.post("/login", response_model=TokenResponse)
async def login(user_data: UserLogin, db: AsyncSession = Depends(get_db_session)):
    """Login user"""
    
    # Find user
    stmt = select(User).filter(User.email == user_data.email)
    result = await db.execute(stmt)
    user = result.scalars().first()
    
    if not user or not verify_password(user_data.password, user.password_hash):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid credentials"
        )
    
    if not user.is_active:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Account is disabled"
        )
    
    # Update last login
    user.last_login = datetime.utcnow()
    await db.commit()
    
    # Create token
    access_token = create_access_token({"sub": str(user.id)})
    
    return TokenResponse(
        access_token=access_token,
        token_type="bearer",
        user=UserResponse(
            id=str(user.id),
            name=user.name,
            email=user.email,
            is_admin=user.is_admin,
            created_at=user.created_at,
            last_login=user.last_login
        )
    )


@router.post("/logout")
async def logout(
    current_user: UserInDB = Depends(get_current_user),
    credentials: HTTPAuthorizationCredentials = Depends(security),
    db: AsyncSession = Depends(get_db_session)
):
    """Logout user - blacklist the token"""
    token = credentials.credentials
    
    # Decode token to get expiration
    payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
    expires_at = datetime.fromtimestamp(payload.get("exp"))
    
    # Add to blacklist
    blacklist_entry = DBTokenBlacklist(
        token=token,
        expires_at=expires_at
    )
    db.add(blacklist_entry)
    await db.commit()
    
    return {"message": "Successfully logged out"}


@router.get("/me", response_model=UserResponse)
async def get_me(current_user: UserInDB = Depends(get_current_user)):
    """Get current user info"""
    return UserResponse(
        id=str(current_user.id),
        name=current_user.name,
        email=current_user.email,
        is_admin=current_user.is_admin,
        created_at=current_user.created_at,
        last_login=current_user.last_login
    )


@router.post("/change-password")
async def change_password(
    old_password: str,
    new_password: str,
    current_user: UserInDB = Depends(get_current_user),
    db: AsyncSession = Depends(get_db_session)
):
    """Change user password"""
    if not verify_password(old_password, current_user.password_hash):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Incorrect current password"
        )
    
    # Update password
    stmt = select(User).filter(User.id == current_user.id)
    result = await db.execute(stmt)
    user = result.scalars().first()
    if user:
        user.password_hash = get_password_hash(new_password)
        await db.commit()
    
    return {"message": "Password changed successfully"}
    
@router.post("/update-profile")
async def update_profile(
    name: str,
    email: str,
    current_user: UserInDB = Depends(get_current_user),
    db: AsyncSession = Depends(get_db_session)
):
    """Update user profile info"""
    # Check if new email is taken by another user
    if email != current_user.email:
        stmt = select(User).filter(User.email == email)
        result = await db.execute(stmt)
        existing = result.scalars().first()
        if existing:
            raise HTTPException(status_code=400, detail="Email already taken")
            
    stmt = select(User).filter(User.id == current_user.id)
    result = await db.execute(stmt)
    user = result.scalars().first()
    if user:
        user.name = name
        user.email = email
        await db.commit()
    
    return {"message": "Profile updated successfully"}


class SaveLocationRequest(BaseModel):
    user_id: str
    latitude: str
    longitude: str
    city: Optional[str] = "Bagalkot"
    state: Optional[str] = "Karnataka"
    country: Optional[str] = "India"

@router.post("/save-location")
async def save_location(req: SaveLocationRequest, db: AsyncSession = Depends(get_db_session)):
    """Save user GPS coordinates and address (Swiggy/Uber style tracking) into MySQL"""
    try:
        user_id_int = None
        try:
            user_id_int = int(req.user_id)
            stmt = select(User).filter(User.id == user_id_int)
            result = await db.execute(stmt)
            user = result.scalars().first()
            if user:
                user.latitude = req.latitude
                user.longitude = req.longitude
                user.city = req.city
                user.state = req.state
                user.country = req.country
        except (ValueError, Exception):
            pass

        try:
            lat_f = float(req.latitude)
            lng_f = float(req.longitude)
        except:
            lat_f = 15.36472
            lng_f = 75.12452

        new_loc = UserLocation(
            user_id=user_id_int,
            latitude=lat_f,
            longitude=lng_f,
            city=req.city or "Bagalkot",
            state=req.state or "Karnataka",
            country=req.country or "India"
        )
        db.add(new_loc)
        await db.commit()
    except Exception as e:
        pass
    return {"status": "success", "location": f"{req.city}, {req.state}", "coordinates": f"{req.latitude}, {req.longitude}"}

