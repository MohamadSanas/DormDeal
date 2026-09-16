from typing import List

from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from app.database.connection import get_db
from app.models.bid import Bid
from app.models.item import Item
from app.models.user import User
from app.schemas.bid import BidWithItem
from app.services.auth_service import get_current_user

router = APIRouter()


@router.get("/mine", response_model=List[BidWithItem])
def get_my_bids(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """
    Returns all bids placed by the current user, enriched with item metadata,
    ordered by most recent bid first.
    """
    bids = (
        db.query(Bid)
        .filter(Bid.bidder_id == current_user.id)
        .order_by(Bid.created_at.desc())
        .all()
    )

    result = []
    for bid in bids:
        item = db.query(Item).filter(Item.id == bid.item_id).first()
        entry = BidWithItem(
            id=bid.id,
            item_id=bid.item_id,
            bidder_id=bid.bidder_id,
            bidder_name=bid.bidder_name,
            bidder_whatsapp=bid.bidder_whatsapp,
            amount=bid.amount,
            created_at=bid.created_at,
            item_title=item.title if item else None,
            item_image_url=item.image_url if item else None,
            item_current_price=item.current_price if item else None,
            item_auction_ends_at=item.auction_ends_at if item else None,
            item_is_finalized=item.is_finalized if item else None,
        )
        result.append(entry)
    return result
