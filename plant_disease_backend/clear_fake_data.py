"""
Clear all fake/seeded data from MongoDB collections.
After running this, only real scans from the Flutter app will appear on the dashboard.
"""
import asyncio
from motor.motor_asyncio import AsyncIOMotorClient


async def clear_fake_data():
    client = AsyncIOMotorClient("mongodb://localhost:27017")
    db = client["plant_disease_db"]

    # Show current counts
    pred_count = await db.predictions.count_documents({})
    feed_count = await db.feedback.count_documents({})
    anal_count = await db.analytics.count_documents({})

    print("=" * 50)
    print("  CURRENT DATABASE STATE (Before Cleanup)")
    print("=" * 50)
    print(f"  Predictions : {pred_count}")
    print(f"  Feedback    : {feed_count}")
    print(f"  Analytics   : {anal_count}")
    print("=" * 50)

    if pred_count == 0:
        print("\n✅ Database is already clean — no data to remove.")
        return

    # Confirm
    confirm = input("\n⚠️  This will DELETE all predictions, feedback, and analytics.\n"
                    "   Only new scans from your Flutter app will appear after this.\n"
                    "   Type 'yes' to continue: ")

    if confirm.strip().lower() != "yes":
        print("❌ Aborted. No data was deleted.")
        return

    # Clear all three collections
    result_pred = await db.predictions.delete_many({})
    result_feed = await db.feedback.delete_many({})
    result_anal = await db.analytics.delete_many({})

    print(f"\n🗑️  Deleted {result_pred.deleted_count} predictions")
    print(f"🗑️  Deleted {result_feed.deleted_count} feedback entries")
    print(f"🗑️  Deleted {result_anal.deleted_count} analytics records")

    # Verify
    remaining = await db.predictions.count_documents({})
    print(f"\n✅ Database cleaned! Remaining predictions: {remaining}")
    print("\n📱 Now scan plants from your Flutter app — they will appear")
    print("   on the dashboard automatically at http://localhost:3000")


if __name__ == "__main__":
    asyncio.run(clear_fake_data())
