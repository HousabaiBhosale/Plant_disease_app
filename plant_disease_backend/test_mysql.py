import asyncio
import sys
from sqlalchemy.ext.asyncio import create_async_engine

async def test_url(url):
    print(f"Testing {url}...", flush=True)
    try:
        engine = create_async_engine(url, connect_args={"connect_timeout": 5})
        async with engine.begin() as conn:
            print(f"SUCCESS connecting to {url}!", flush=True)
            res = await conn.execute("SELECT 1")
            print("Result:", res.scalar(), flush=True)
        await engine.dispose()
    except Exception as e:
        print(f"FAILED connecting to {url}: {e}", flush=True)

async def main():
    urls = [
        "mysql+aiomysql://root:@127.0.0.1:3306/plant_disease_db",
        "mysql+aiomysql://root:password@127.0.0.1:3306/plant_disease_db",
        "mysql+aiomysql://root:@[::1]:3306/plant_disease_db",
        "mysql+aiomysql://root:@localhost:3306/plant_disease_db",
    ]
    for url in urls:
        await test_url(url)

if __name__ == "__main__":
    asyncio.run(main())
