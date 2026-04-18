import asyncio
from motor.motor_asyncio import AsyncIOMotorClient
from passlib.context import CryptContext

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

async def reset_user_password(email, new_password):
    client = AsyncIOMotorClient('mongodb://localhost:27017')
    db = client['plant_disease_db']
    
    hashed_password = pwd_context.hash(new_password)
    
    result = await db['users'].update_one(
        {"email": email},
        {"$set": {"password_hash": hashed_password}}
    )
    
    if result.modified_count > 0:
        print(f"SUCCESS: Password for {email} has been reset to '{new_password}'.")
    else:
        print(f"FAILURE: Could not find user with email '{email}'.")

if __name__ == "__main__":
    # Email from database check
    target_email = "bhosalemahadev9889@gmail.com"
    asyncio.run(reset_user_password(target_email, "password123"))
