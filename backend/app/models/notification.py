import uuid
from datetime import datetime
from sqlalchemy import Column, String, Boolean, DateTime, ForeignKey
from app.database.base import Base


class Notification(Base):
    __tablename__ = "notifications"

    id         = Column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    user_id    = Column(String(36), ForeignKey("users.id", ondelete="CASCADE"), nullable=False, index=True)
    type       = Column(String, nullable=False)  # 'outbid' | 'auction_won' | 'auction_ended_seller' | 'new_bid_seller'
    title      = Column(String, nullable=False)
    body       = Column(String, nullable=False)
    item_id    = Column(String(36), ForeignKey("items.id", ondelete="SET NULL"), nullable=True)
    is_read    = Column(Boolean, default=False)
    created_at = Column(DateTime, default=datetime.utcnow)
