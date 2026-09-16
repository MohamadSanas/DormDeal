from app.database.connection import SessionLocal, engine
from app.models.user import User
from app.services.auth_service import hash_password, create_access_token
import time

print("1. Testing hash_password...")
t0 = time.time()
hp = hash_password("SecurePassword123!")
print(f"Hashed in {time.time()-t0:.2f}s: {hp}")

print("2. Testing DB session write...")
t0 = time.time()
db = SessionLocal()
u = db.query(User).first()
print(f"Queried user in {time.time()-t0:.2f}s: {u}")
db.close()
