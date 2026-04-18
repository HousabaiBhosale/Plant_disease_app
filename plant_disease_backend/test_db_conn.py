import asyncio
from motor.motor_asyncio import AsyncIOMotorClient

async def test_connection():
    print("Testing connection to mongodb://localhost:27017")
    client = AsyncIOMotorClient('mongodb://localhost:27017', serverSelectionTimeoutMS=2000)
    try:
        await client.admin.command('ping')
        print("SUCCESS: Connection to MongoDB is active.")
    except Exception as e:
        print(f"FAILURE: Could not connect to MongoDB: {e}")

if __name__ == "__main__":
    asyncio.run(test_connection())
