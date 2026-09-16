import logging

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.database.connection import engine, settings
from app.database.base import Base

# Import all models so Alembic / Base.metadata sees them
from app.models import user, item, bid, notification  # noqa: F401

from app.routes import items, auth, bids, notifications
from app.services.auction_scheduler import start_scheduler, stop_scheduler

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

app = FastAPI(
    title="DormDeal API",
    version="2.0.0",
    description="Campus auction marketplace for university students",
)

# ── CORS ───────────────────────────────────────────────────────────────────────
origins = [o.strip() for o in settings.CORS_ORIGINS.split(",")] if settings.CORS_ORIGINS else ["*"]
app.add_middleware(
    CORSMiddleware,
    allow_origins=origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# ── Routers ────────────────────────────────────────────────────────────────────
app.include_router(auth.router,          prefix="/api/v1/auth",          tags=["Auth"])
app.include_router(items.router,         prefix="/api/v1/items",         tags=["Items"])
app.include_router(bids.router,          prefix="/api/v1/bids",          tags=["Bids"])
app.include_router(notifications.router, prefix="/api/v1/notifications", tags=["Notifications"])


# ── Startup / Shutdown ─────────────────────────────────────────────────────────
@app.on_event("startup")
def on_startup():
    logger.info("DormDeal API starting up...")
    # Create any missing tables (safe for existing tables — does not drop)
    Base.metadata.create_all(bind=engine)
    # Start the auction expiry background job
    start_scheduler()
    logger.info("Startup complete.")


@app.on_event("shutdown")
def on_shutdown():
    stop_scheduler()
    logger.info("DormDeal API shut down.")


# ── Health check ───────────────────────────────────────────────────────────────
@app.get("/", tags=["Health"])
def health_check():
    return {"status": "ok", "message": "DormDeal API v2 is running"}