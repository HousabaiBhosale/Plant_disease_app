import asyncio
from motor.motor_asyncio import AsyncIOMotorClient

async def check_database():
    client = AsyncIOMotorClient("mongodb://localhost:27017")
    db = client["plant_disease_db"]
    
    print("=" * 50)
    print("Database Status")
    print("=" * 50)
    
    # Check collections
    collections = await db.list_collection_names()
    print(f"\nCollections: {collections}")
    
    # Check users
    user_count = await db.users.count_documents({})
    print(f"\nUsers: {user_count}")
    
    if user_count > 0:
        print("\nUser List:")
        async for user in db.users.find().limit(5):
            print(f"  - {user['email']} (Name: {user['name']})")
    
    # Check predictions
    pred_count = await db.predictions.count_documents({})
    print(f"\nPredictions: {pred_count}")
    
    # Check feedback
    feedback_count = await db.feedback.count_documents({})
    print(f"\nFeedback: {feedback_count}")
    
    print("\n" + "=" * 50)
    print("✅ Database check complete!")
    print("=" * 50)
    
    client.close()

if __name__ == "__main__":
    asyncio.run(check_database())
