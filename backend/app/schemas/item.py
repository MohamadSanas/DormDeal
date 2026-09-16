from pydantic import BaseModel, ConfigDict
from datetime import datetime
from typing import Optional


class ItemBase(BaseModel):
    title: str
    base_price: float
    description: Optional[str] = None
    whatsapp_number: str
    auction_ends_at: Optional[datetime] = None
    payment_method: str = "Cash on Delivery"
    category: Optional[str] = None


class ItemCreate(ItemBase):
    pass


class ItemOut(ItemBase):
    id: str
    owner_id: Optional[str] = None
    current_price: float
    image_url: Optional[str] = None
    current_bidder_name: Optional[str] = None
    current_bidder_whatsapp: Optional[str] = None
    current_bidder_id: Optional[str] = None
    bid_updated_at: Optional[datetime] = None
    is_finalized: bool = False
    bid_count: int = 0
    created_at: datetime

    model_config = ConfigDict(from_attributes=True)


class BidCreate(BaseModel):
    bidder_name: str
    bidder_whatsapp: str
    amount: float
