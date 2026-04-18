import asyncio
from motor.motor_asyncio import AsyncIOMotorClient

async def get_user_and_preds():
    client = AsyncIOMotorClient('mongodb://localhost:27017')
    db = client['plant_disease_db']
    
    user = await db['users'].find_one({"email": "bhosalemahadev9889@gmail.com"})
    if not user:
        print("User not found.")
        return
    
    user_id = str(user['_id'])
    print(f"DEBUG: Found user {user['email']} with ID: {user_id}")
    
    # Check predictions for this user
    preds = await db['predictions'].find({"user_id": user_id}).to_list(100)
    print(f"DEBUG: Found {len(preds)} predictions for user ID {user_id}")
    
    # Also check if any predictions have NO user_id or a different format
    all_preds = await db['predictions'].find().to_list(10)
    print(f"DEBUG: Sample predictions in DB:")
    for p in all_preds:
         print(f" - ID: {p['_id']}, UserID in DB: {p.get('user_id')} (Type: {type(p.get('user_id'))})")

if __name__ == "__main__":
    asyncio.run(get_user_and_preds())
