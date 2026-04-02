from sqlalchemy import Column, Integer, String
from app.database.connection import Base

class Item(Base):
    __tablename__ = "items"

    id = Column(Integer, primary_key=True, index=True)
    title = Column(String, nullable=False)
    price = Column(Integer, nullable=False)
    description = Column(String, nullable=True)
    contact_number = Column(String, nullable=False)
    image_url = Column(String, nullable=True)
    location = Column(String, nullable=True)