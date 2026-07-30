import asyncio
from app.database.mysql_db import MySQLDB, get_db_session_maker
from sqlalchemy import select, func
from app.database.schema import PredictionLog

async def main():
    await MySQLDB.connect_to_database()
    session_maker = get_db_session_maker()
    async with session_maker() as session:
        stmt = select(func.count(PredictionLog.id))
        res = await session.execute(stmt)
        print(f"Total rows in prediction_logs: {res.scalar()}")

        stmt = select(PredictionLog).order_by(PredictionLog.created_at.desc()).limit(5)
        res = await session.execute(stmt)
        for log in res.scalars().all():
            print(f"ID: {log.id}, Created At: {log.created_at}, Mode: {log.inference_mode}, Disease: {log.predicted_disease}")
    
    await MySQLDB.close_database_connection()

asyncio.run(main())
