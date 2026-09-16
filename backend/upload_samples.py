from datetime import datetime, timedelta
from app.services.cloudinary_service import upload_image
from app.database.connection import SessionLocal
from app.models.item import Item
from app.models.user import User

db = SessionLocal()
seller = db.query(User).filter(User.email.like("seller%")).first()
seller_id = seller.id if seller else None

sample_items = [
    {
        "title": "LED Study Desk Lamp",
        "category": "Furniture",
        "base_price": 15.0,
        "description": "Adjustable brightness LED desk lamp with USB charging port. Perfect for dorm night study.",
        "img_src": "https://images.unsplash.com/photo-1507473885765-e6ed057f782c?w=600",
    },
    {
        "title": "Wireless Noise-Canceling Headphones",
        "category": "Electronics",
        "base_price": 45.0,
        "description": "Over-ear Bluetooth headphones with active noise cancellation, ideal for quiet studying.",
        "img_src": "https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=600",
    },
    {
        "title": "Casio FX-991EX Scientific Calculator",
        "category": "Electronics",
        "base_price": 20.0,
        "description": "Approved for engineering and math university exams. Flawless condition.",
        "img_src": "https://images.unsplash.com/photo-1611162617213-7d7a39e9b1d7?w=600",
    },
]

for s in sample_items:
    c_url = upload_image(s["img_src"])
    print(f"Uploaded {s['title']} -> {c_url}")
    item = Item(
        owner_id=seller_id,
        title=s["title"],
        category=s["category"],
        base_price=s["base_price"],
        current_price=s["base_price"],
        description=s["description"],
        whatsapp_number="+1234567890",
        image_url=c_url,
        auction_ends_at=datetime.utcnow() + timedelta(days=3),
        is_finalized=False,
    )
    db.add(item)

db.commit()
db.close()
print("All sample items created and uploaded successfully!")
