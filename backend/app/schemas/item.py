from pydantic import BaseModel

class ItemCreate(BaseModel):
    title: str
    price: int
    description: str | None = None
    contact_number: str
    image_url: str | None = None
    location: str | None = None


class ItemResponse(ItemCreate):
    id: int

    class Config:
        from_attributes = True