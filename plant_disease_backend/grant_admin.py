import asyncio
from motor.motor_asyncio import AsyncIOMotorClient

async def grant_admin(email: str):
    client = AsyncIOMotorClient('mongodb://localhost:27017')
    db = client['plant_disease_db']
    
    result = await db['users'].update_one(
        {"email": email},
        {"$set": {"is_admin": True}}
    )
    
    if result.matched_count > 0:
        print(f"Successfully granted admin privileges to: {email}")
    else:
        print(f"User with email {email} not found.")

if __name__ == "__main__":
    email_to_promote = "bhosalemahadev9889@gmail.com"
    asyncio.run(grant_admin(email_to_promote))
