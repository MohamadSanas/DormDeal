from pydantic import BaseModel, ConfigDict
from datetime import datetime
from typing import Optional


class BidOut(BaseModel):
    id: str
    item_id: str
    bidder_id: Optional[str] = None
    bidder_name: str
    bidder_whatsapp: str
    amount: float
    created_at: datetime

    model_config = ConfigDict(from_attributes=True)


class BidWithItem(BidOut):
    """Bid with item metadata — used for My Bids screen."""
    item_title: Optional[str] = None
    item_image_url: Optional[str] = None
    item_current_price: Optional[float] = None
    item_auction_ends_at: Optional[datetime] = None
    item_is_finalized: Optional[bool] = None
