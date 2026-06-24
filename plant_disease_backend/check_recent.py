import asyncio
from motor.motor_asyncio import AsyncIOMotorClient

async def run():
    client = AsyncIOMotorClient()
    db = client.plant_disease_db
    print(f'Total predictions: {await db.predictions.count_documents({})}')
    preds = await db.predictions.find().sort('created_at', -1).limit(5).to_list(5)
    print('Recent:')
    for p in preds:
        print(p.get('created_at'), p.get('user_id'), p.get('predicted_disease'))

if __name__ == '__main__':
    asyncio.run(run())
