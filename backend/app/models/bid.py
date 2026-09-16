import uuid
from datetime import datetime
from sqlalchemy import Column, String, Float, DateTime, ForeignKey
from app.database.base import Base


class Bid(Base):
    __tablename__ = "bids"

    id               = Column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    item_id          = Column(String(36), ForeignKey("items.id", ondelete="CASCADE"), nullable=False, index=True)
    bidder_id        = Column(String(36), ForeignKey("users.id", ondelete="SET NULL"), nullable=True, index=True)
    bidder_name      = Column(String, nullable=False)
    bidder_whatsapp  = Column(String, nullable=False)
    amount           = Column(Float, nullable=False)
    created_at       = Column(DateTime, default=datetime.utcnow)
