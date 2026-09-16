import uuid
from datetime import datetime
from sqlalchemy import Column, String, Float, Text, DateTime, Boolean, ForeignKey
from app.database.base import Base


class Item(Base):
    __tablename__ = "items"

    id                      = Column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    owner_id                = Column(String(36), ForeignKey("users.id", ondelete="SET NULL"), nullable=True, index=True)
    title                   = Column(String, nullable=False)
    category                = Column(String, nullable=True)   # e.g. "Electronics", "Furniture"
    base_price              = Column(Float, nullable=False)
    current_price           = Column(Float, nullable=False)
    description             = Column(Text, nullable=True)
    image_url               = Column(String, nullable=True)
    whatsapp_number         = Column(String, nullable=False)
    auction_ends_at         = Column(DateTime, nullable=False)
    payment_method          = Column(String, nullable=False, default="Cash on Delivery")
    current_bidder_name     = Column(String, nullable=True)
    current_bidder_whatsapp = Column(String, nullable=True)
    current_bidder_id       = Column(String(36), ForeignKey("users.id", ondelete="SET NULL"), nullable=True)
    bid_updated_at          = Column(DateTime, nullable=True)
    is_finalized            = Column(Boolean, default=False)
    created_at              = Column(DateTime, default=datetime.utcnow)
