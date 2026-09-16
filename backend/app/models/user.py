import uuid
from datetime import datetime
from sqlalchemy import Column, String, Boolean, DateTime
from app.database.base import Base


class User(Base):
    __tablename__ = "users"

    id              = Column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    name            = Column(String, nullable=False)
    email           = Column(String, unique=True, index=True, nullable=False)
    hashed_password = Column(String, nullable=False)
    whatsapp_number = Column(String, nullable=True)
    university      = Column(String, nullable=True)
    avatar_url      = Column(String, nullable=True)
    is_active       = Column(Boolean, default=True)
    created_at      = Column(DateTime, default=datetime.utcnow)
