from datetime import datetime, timedelta
from fastapi import APIRouter, Depends, Form, File, UploadFile, HTTPException
from sqlalchemy.orm import Session
from typing import List
from app.database.connection import get_db
from app.models.item import Item
from app.schemas.item import ItemOut, BidCreate
from app.services.cloudinary_service import upload_image

router = APIRouter()

@router.post("/", response_model=ItemOut)
async def create_item(
    title: str = Form(...),
    base_price: float = Form(...),
    auction_hours: int = Form(24),
    whatsapp_number: str = Form(...),
    description: str = Form(None),
    image: UploadFile = File(None),
    db: Session = Depends(get_db)
):
    if base_price <= 0:
        raise HTTPException(status_code=400, detail="Base price must be positive")
    if auction_hours < 1:
        raise HTTPException(status_code=400, detail="Auction duration must be at least 1 hour")

    image_url = None
    if image:
        contents = await image.read()
        image_url = upload_image(contents)

    auction_ends_at = datetime.utcnow() + timedelta(hours=auction_hours)
    new_item = Item(
        title=title,
        base_price=base_price,
        current_price=base_price,
        description=description,
        whatsapp_number=whatsapp_number,
        image_url=image_url,
        auction_ends_at=auction_ends_at,
        payment_method="Cash on Delivery",
    )

    db.add(new_item)
    db.commit()
    db.refresh(new_item)
    return new_item

@router.get("/", response_model=List[ItemOut])
def get_items(limit: int = 50, db: Session = Depends(get_db)):
    items = db.query(Item).order_by(Item.created_at.desc()).limit(limit).all()
    return items

@router.get("/{item_id}", response_model=ItemOut)
def get_item(item_id: str, db: Session = Depends(get_db)):
    item = db.query(Item).filter(Item.id == item_id).first()
    if not item:
        raise HTTPException(status_code=404, detail="Item not found")
    return item


@router.post("/{item_id}/bids", response_model=ItemOut)
def place_bid(item_id: str, payload: BidCreate, db: Session = Depends(get_db)):
    item = db.query(Item).filter(Item.id == item_id).first()
    if not item:
        raise HTTPException(status_code=404, detail="Item not found")

    now = datetime.utcnow()
    if now >= item.auction_ends_at:
        raise HTTPException(status_code=400, detail="Auction already ended")

    if payload.amount <= item.current_price:
        raise HTTPException(status_code=400, detail="Bid must be higher than current price")

    item.current_price = payload.amount
    item.current_bidder_name = payload.bidder_name
    item.current_bidder_whatsapp = payload.bidder_whatsapp
    item.bid_updated_at = now
    db.commit()
    db.refresh(item)
    return item
