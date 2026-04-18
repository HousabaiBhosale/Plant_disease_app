import asyncio
from motor.motor_asyncio import AsyncIOMotorClient

async def list_predictions():
    client = AsyncIOMotorClient('mongodb://localhost:27017')
    db = client['plant_disease_db']
    predictions = await db['predictions'].find().to_list(20)
    print(f"Total predictions found: {len(predictions)}")
    for pred in predictions:
        print(f"ID: {pred.get('_id')}, UserID: {pred.get('user_id')}, Disease: {pred.get('predicted_disease')}")

if __name__ == "__main__":
    asyncio.run(list_predictions())
