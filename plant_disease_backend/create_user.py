import asyncio
from motor.motor_asyncio import AsyncIOMotorClient
from passlib.context import CryptContext
from datetime import datetime
from bson import ObjectId

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

async def create_user():
    # Connect to MongoDB
    client = AsyncIOMotorClient("mongodb://localhost:27017")
    db = client["plant_disease_db"]
    
    # Check if user already exists
    existing = await db.users.find_one({"email": "admin@gmail.com"})
    if existing:
        print("✅ Admin user already exists!")
        print(f"   Email: admin@gmail.com")
        print(f"   Password: admin123")
        return
    
    # Create admin user
    user = {
        "_id": str(ObjectId()),
        "name": "Admin User",
        "email": "admin@gmail.com",
        "password_hash": pwd_context.hash("admin123"),
        "is_active": True,
        "is_admin": True,
        "created_at": datetime.utcnow(),
        "last_login": None
    }
    
    await db.users.insert_one(user)
    print("✅ Admin user created successfully!")
    print("   Email: admin@gmail.com")
    print("   Password: admin123")
    
    # Create test user
    test_user = {
        "_id": str(ObjectId()),
        "name": "Test User",
        "email": "test@example.com",
        "password_hash": pwd_context.hash("Test123!"),
        "is_active": True,
        "is_admin": False,
        "created_at": datetime.utcnow(),
        "last_login": None
    }
    
    await db.users.insert_one(test_user)
    print("✅ Test user created successfully!")
    print("   Email: test@example.com")
    print("   Password: Test123!")
    
    # List all users
    print("\n📊 All Users:")
    async for user in db.users.find():
        print(f"   - {user['email']} (Name: {user['name']})")
    
    client.close()

if __name__ == "__main__":
    asyncio.run(create_user())
