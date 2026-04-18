import asyncio
from motor.motor_asyncio import AsyncIOMotorClient

async def list_users():
    client = AsyncIOMotorClient('mongodb://localhost:27017')
    db = client['plant_disease_db']
    users = await db['users'].find().to_list(10)
    print("Listing top 10 users in the database:")
    if not users:
        print("No users found in database.")
    for user in users:
        print(f"ID: {user.get('_id')}, Email: {user.get('email')}, Name: {user.get('name')}")

if __name__ == "__main__":
    asyncio.run(list_users())
