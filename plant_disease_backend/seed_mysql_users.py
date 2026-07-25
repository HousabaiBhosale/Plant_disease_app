import pymysql
from passlib.context import CryptContext
from datetime import datetime

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

def seed_users():
    print("Connecting to MariaDB to seed users...")
    conn = pymysql.connect(
        host="127.0.0.1",
        user="root",
        password="",
        database="plant_disease_db"
    )
    cursor = conn.cursor()
    
    # Hash password
    password_hash = pwd_context.hash("admin123")
    
    users_to_seed = [
        ("Admin User", "admin@gmail.com", password_hash, True),
        ("Housa User", "housa@gmail.com", password_hash, True)
    ]
    
    for name, email, pw_hash, is_admin in users_to_seed:
        # Check if user exists
        cursor.execute("SELECT id FROM users WHERE email = %s", (email,))
        existing = cursor.fetchone()
        if existing:
            print(f"User {email} already exists.")
        else:
            cursor.execute(
                "INSERT INTO users (name, email, password_hash, is_active, is_admin, created_at) VALUES (%s, %s, %s, %s, %s, %s)",
                (name, email, pw_hash, True, is_admin, datetime.utcnow())
            )
            print(f"Created user {email} with password 'admin123'")
            
    conn.commit()
    conn.close()
    print("Seeding completed successfully!")

if __name__ == "__main__":
    seed_users()
