from datetime import datetime, timedelta
from typing import List, Optional

from fastapi import APIRouter, Depends, Form, File, UploadFile, HTTPException
from sqlalchemy.orm import Session

from app.database.connection import get_db
from app.models.item import Item
from app.models.bid import Bid
from app.models.user import User
from app.schemas.item import ItemOut, BidCreate
from app.services.cloudinary_service import upload_image
from app.services.auth_service import get_current_user, get_optional_user
from app.services import notification_service

router = APIRouter()


# ── Helper: attach bid_count to item ──────────────────────────────────────────
def _item_with_bid_count(item: Item, db: Session) -> dict:
    count = db.query(Bid).filter(Bid.item_id == item.id).count()
    data = {c.name: getattr(item, c.name) for c in item.__table__.columns}
    data["bid_count"] = count
    return data


# ── POST / — Create a listing ─────────────────────────────────────────────────
@router.post("/", response_model=ItemOut)
async def create_item(
    title: str = Form(...),
    base_price: float = Form(...),
    auction_hours: int = Form(24),
    whatsapp_number: str = Form(...),
    description: str = Form(None),
    category: str = Form(None),
    image: UploadFile = File(None),
    db: Session = Depends(get_db),
    current_user: Optional[User] = Depends(get_optional_user),
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
        owner_id=current_user.id if current_user else None,
        title=title,
        category=category,
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
    data = _item_with_bid_count(new_item, db)
    return data


# ── GET / — Browse all active listings ────────────────────────────────────────
@router.get("/", response_model=List[ItemOut])
def get_items(
    limit: int = 50,
    category: Optional[str] = None,
    search: Optional[str] = None,
    db: Session = Depends(get_db),
):
    query = db.query(Item).filter(Item.is_finalized == False)
    if category and category.lower() != "all items":
        query = query.filter(Item.category == category)
    if search:
        query = query.filter(Item.title.ilike(f"%{search}%"))
    items = query.order_by(Item.created_at.desc()).limit(limit).all()
    return [_item_with_bid_count(i, db) for i in items]


# ── GET /mine — My listings (auth required) ───────────────────────────────────
@router.get("/mine", response_model=List[ItemOut])
def get_my_items(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    items = (
        db.query(Item)
        .filter(Item.owner_id == current_user.id)
        .order_by(Item.created_at.desc())
        .all()
    )
    return [_item_with_bid_count(i, db) for i in items]


# ── GET /{item_id} — Item detail ──────────────────────────────────────────────
@router.get("/{item_id}", response_model=ItemOut)
def get_item(item_id: str, db: Session = Depends(get_db)):
    item = db.query(Item).filter(Item.id == item_id).first()
    if not item:
        raise HTTPException(status_code=404, detail="Item not found")
    return _item_with_bid_count(item, db)


# ── DELETE /{item_id} — Remove a listing (owner only) ────────────────────────
@router.delete("/{item_id}", status_code=204)
def delete_item(
    item_id: str,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    item = db.query(Item).filter(Item.id == item_id).first()
    if not item:
        raise HTTPException(status_code=404, detail="Item not found")
    if item.owner_id != current_user.id:
        raise HTTPException(status_code=403, detail="Not allowed")
    db.delete(item)
    db.commit()


# ── POST /{item_id}/bids — Place a bid ────────────────────────────────────────
@router.post("/{item_id}/bids", response_model=ItemOut)
def place_bid(
    item_id: str,
    payload: BidCreate,
    db: Session = Depends(get_db),
    current_user: Optional[User] = Depends(get_optional_user),
):
    item = db.query(Item).filter(Item.id == item_id).first()
    if not item:
        raise HTTPException(status_code=404, detail="Item not found")

    now = datetime.utcnow()
    if now >= item.auction_ends_at:
        raise HTTPException(status_code=400, detail="Auction already ended")
    if item.is_finalized:
        raise HTTPException(status_code=400, detail="Auction is finalized")
    if payload.amount <= item.current_price:
        raise HTTPException(status_code=400, detail="Bid must be higher than current price")

    # Capture outbid target before overwriting
    prev_bidder_id = item.current_bidder_id

    # Persist bid to history table
    bid = Bid(
        item_id=item.id,
        bidder_id=current_user.id if current_user else None,
        bidder_name=payload.bidder_name,
        bidder_whatsapp=payload.bidder_whatsapp,
        amount=payload.amount,
    )
    db.add(bid)

    # Update item's current highest bid snapshot
    item.current_price = payload.amount
    item.current_bidder_name = payload.bidder_name
    item.current_bidder_whatsapp = payload.bidder_whatsapp
    item.current_bidder_id = current_user.id if current_user else None
    item.bid_updated_at = now

    # Fire notifications
    if prev_bidder_id:
        notification_service.notify_outbid(
            db, prev_bidder_id, item.title, item.id, payload.amount
        )
    if item.owner_id:
        notification_service.notify_new_bid_to_seller(
            db, item.owner_id, item.title, item.id, payload.bidder_name, payload.amount
        )

    db.commit()
    db.refresh(item)
    return _item_with_bid_count(item, db)
