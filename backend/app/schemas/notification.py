from pydantic import BaseModel, ConfigDict
from datetime import datetime
from typing import Optional


class NotificationOut(BaseModel):
    id: str
    user_id: str
    type: str
    title: str
    body: str
    item_id: Optional[str] = None
    is_read: bool
    created_at: datetime

    model_config = ConfigDict(from_attributes=True)


class UnreadCountOut(BaseModel):
    count: int
