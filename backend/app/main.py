from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from sqlalchemy import text
from app.database.connection import engine, settings
from app.database.base import Base
from app.routes import items
import logging

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

app = FastAPI(title="DormDeal API")

def _ensure_sqlite_auction_columns() -> None:
    if not settings.DATABASE_URL.startswith("sqlite"):
        return

    required_columns = {
        "base_price": "ALTER TABLE items ADD COLUMN base_price FLOAT DEFAULT 0 NOT NULL",
        "current_price": "ALTER TABLE items ADD COLUMN current_price FLOAT DEFAULT 0 NOT NULL",
        "auction_ends_at": "ALTER TABLE items ADD COLUMN auction_ends_at DATETIME",
        "payment_method": "ALTER TABLE items ADD COLUMN payment_method VARCHAR DEFAULT 'Cash on Delivery' NOT NULL",
        "current_bidder_name": "ALTER TABLE items ADD COLUMN current_bidder_name VARCHAR",
        "current_bidder_whatsapp": "ALTER TABLE items ADD COLUMN current_bidder_whatsapp VARCHAR",
        "bid_updated_at": "ALTER TABLE items ADD COLUMN bid_updated_at DATETIME",
    }

    with engine.connect() as conn:
        result = conn.execute(text("PRAGMA table_info(items)"))
        existing = {row[1] for row in result}
        for column_name, alter_sql in required_columns.items():
            if column_name not in existing:
                conn.execute(text(alter_sql))
        conn.commit()

@app.on_event("startup")
def on_startup():
    logger.info("Starting up and creating tables for DormDeal...")
    Base.metadata.create_all(bind=engine)
    _ensure_sqlite_auction_columns()

# Safe CORS handling
origins = settings.CORS_ORIGINS.split(",") if settings.CORS_ORIGINS else ["*"]

app.add_middleware(
    CORSMiddleware,
    allow_origins=[origin.strip() for origin in origins],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(items.router, prefix="/api/v1/items", tags=["Items"])

@app.get("/")
def health_check():
    return {"status": "ok", "message": "DormDeal API is running"}