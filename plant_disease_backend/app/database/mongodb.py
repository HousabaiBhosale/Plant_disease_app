from motor.motor_asyncio import AsyncIOMotorClient, AsyncIOMotorDatabase
from pymongo import IndexModel, ASCENDING, DESCENDING
from app.config import settings
import logging

logger = logging.getLogger(__name__)


class MongoDB:
    client: AsyncIOMotorClient = None
    database: AsyncIOMotorDatabase = None

    @classmethod
    async def connect_to_database(cls):
        """Connect to MongoDB and initialise indexes."""
        try:
            cls.client = AsyncIOMotorClient(
                settings.MONGODB_URL,
                serverSelectionTimeoutMS=5000,   # fail fast on bad URL
                maxPoolSize=10,
                minPoolSize=1,
            )
            # Force an actual connection check
            await cls.client.admin.command("ping")
            cls.database = cls.client[settings.DATABASE_NAME]
            logger.info("Connected to MongoDB: %s", settings.DATABASE_NAME)
            await cls.create_indexes()
        except Exception as e:
            logger.error("Failed to connect to MongoDB: %s", e)
            raise

    @classmethod
    async def close_database_connection(cls):
        """Gracefully close the connection pool."""
        if cls.client:
            cls.client.close()
            cls.client = None
            cls.database = None
            logger.info("Closed MongoDB connection")

    @classmethod
    def get_database(cls) -> AsyncIOMotorDatabase:
        """Return the active database, raising clearly if not connected."""
        if cls.database is None:
            raise RuntimeError(
                "MongoDB is not connected. "
                "Call connect_to_database() during app startup."
            )
        return cls.database

    @classmethod
    async def create_indexes(cls):
        """
        Declare all indexes in one place.
        Using IndexModel keeps options (unique, sparse, TTL) explicit and readable.
        """
        db = cls.database

        # --- predictions ---
        await db.predictions.create_indexes([
            IndexModel([("user_id", ASCENDING)]),
            IndexModel([("created_at", DESCENDING)]),          # most-recent-first queries
            IndexModel([("predicted_disease", ASCENDING)]),    # analytics grouping
        ])

        # --- feedback ---
        await db.feedback.create_indexes([
            IndexModel([("prediction_id", ASCENDING)]),
            IndexModel([("user_id", ASCENDING)]),
        ])

        # --- analytics ---
        # Compound unique index prevents duplicate daily records
        await db.analytics.create_indexes([
            IndexModel([("date", ASCENDING)], unique=True),
        ])

        # --- users ---
        await db.users.create_indexes([
            IndexModel([("email", ASCENDING)], unique=True),
            IndexModel([("firebase_uid", ASCENDING)], unique=True, sparse=True),
        ])

        logger.info("Database indexes created / verified")


# ---------------------------------------------------------------------------
# Collection accessors — always go through get_database() so a missing
# connection surfaces as a clear RuntimeError, not an AttributeError on None.
# ---------------------------------------------------------------------------

def get_predictions_collection():
    return MongoDB.get_database().predictions

def get_feedback_collection():
    return MongoDB.get_database().feedback

def get_analytics_collection():
    return MongoDB.get_database().analytics

def get_users_collection():
    return MongoDB.get_database().users