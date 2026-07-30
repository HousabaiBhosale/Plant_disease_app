import asyncio
from sqlalchemy import text
from app.database.mysql_db import MySQLDB

async def fix_token_blacklist_schema():
    await MySQLDB.connect_to_database()
    async with MySQLDB.engine.begin() as conn:
        try:
            await conn.execute(text("DROP TABLE IF EXISTS token_blacklist;"))
            print("Dropped old token_blacklist table")
        except Exception as e:
            print("Could not drop table:", e)
    
    # recreate all missing tables including token_blacklist
    await MySQLDB.create_tables()
    print("Recreated tables")
    await MySQLDB.close_database_connection()

if __name__ == "__main__":
    asyncio.run(fix_token_blacklist_schema())
