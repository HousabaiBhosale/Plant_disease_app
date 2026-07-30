import asyncio
from sqlalchemy import text
from app.database.mysql_db import MySQLDB

async def fix_schema():
    await MySQLDB.connect_to_database()
    async with MySQLDB.engine.begin() as conn:
        try:
            await conn.execute(text("DROP TABLE IF EXISTS model_versions;"))
            print("Dropped old model_versions table")
        except Exception as e:
            print("Could not drop table:", e)
    
    # recreate
    await MySQLDB.create_tables()
    print("Recreated tables")
    await MySQLDB.close_database_connection()

if __name__ == "__main__":
    asyncio.run(fix_schema())
