import logging
from sqlalchemy.ext.asyncio import create_async_engine, async_sessionmaker, AsyncSession
from sqlalchemy.orm import declarative_base
from app.config import settings

logger = logging.getLogger(__name__)

# Base class for declarative class definitions
Base = declarative_base()

class MySQLDB:
    engine = None
    async_session_maker = None

    @classmethod
    async def connect_to_database(cls):
        """Connect to MySQL and initialize the session maker."""
        try:
            cls.engine = create_async_engine(
                settings.MYSQL_URL,
                echo=False,  # Set to True for SQL query logging
                pool_size=10,
                max_overflow=20,
            )
            cls.async_session_maker = async_sessionmaker(
                cls.engine, class_=AsyncSession, expire_on_commit=False
            )
            
            # Test connection
            async with cls.engine.begin() as conn:
                pass
                
            logger.info("Connected to MySQL: %s", settings.MYSQL_URL.split('@')[-1])
            
            # Create tables if they don't exist
            await cls.create_tables()
            
        except Exception as e:
            logger.error("Failed to connect to MySQL: %s", e)
            raise

    @classmethod
    async def create_tables(cls):
        """Create all tables defined in Base.metadata"""
        try:
            # We must import all models here so Base knows about them
            import app.database.schema
            async with cls.engine.begin() as conn:
                await conn.run_sync(Base.metadata.create_all)
            logger.info("Database tables verified/created")
        except Exception as e:
            logger.error("Failed to create tables: %s", e)
            raise

    @classmethod
    async def close_database_connection(cls):
        """Gracefully close the engine connection pool."""
        if cls.engine:
            await cls.engine.dispose()
            cls.engine = None
            cls.async_session_maker = None
            logger.info("Closed MySQL connection")

# Dependency for FastAPI
async def get_db_session() -> AsyncSession:
    """Dependency to get a DB session for requests."""
    if MySQLDB.async_session_maker is None:
        raise RuntimeError("Database not initialized")
    
    async with MySQLDB.async_session_maker() as session:
        yield session

def get_db_session_maker():
    if MySQLDB.async_session_maker is None:
        raise RuntimeError("Database not initialized")
    return MySQLDB.async_session_maker
