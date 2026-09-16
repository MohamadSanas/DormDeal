from sqlalchemy.orm import Session

from app.models.notification import Notification


def _create(db: Session, user_id: str, type_: str, title: str, body: str, item_id: str = None):
    notif = Notification(
        user_id=user_id,
        type=type_,
        title=title,
        body=body,
        item_id=item_id,
    )
    db.add(notif)
    # Note: caller is responsible for db.commit()


def notify_outbid(db: Session, previous_bidder_id: str, item_title: str, item_id: str, new_amount: float):
    """Tell the previous top bidder they've been outbid."""
    _create(
        db, previous_bidder_id,
        type_="outbid",
        title="You've been outbid!",
        body=f'Someone placed a higher bid of ${new_amount:.2f} on "{item_title}".',
        item_id=item_id,
    )


def notify_new_bid_to_seller(db: Session, seller_id: str, item_title: str, item_id: str, bidder_name: str, amount: float):
    """Tell the seller that a new bid arrived on their item."""
    _create(
        db, seller_id,
        type_="new_bid_seller",
        title="New bid on your listing!",
        body=f'{bidder_name} placed a bid of ${amount:.2f} on "{item_title}".',
        item_id=item_id,
    )


def notify_auction_won(db: Session, winner_id: str, item_title: str, item_id: str, amount: float):
    """Tell the winning bidder they won."""
    _create(
        db, winner_id,
        type_="auction_won",
        title="🎉 You won the auction!",
        body=f'Congratulations! You won "{item_title}" for ${amount:.2f}. Contact the seller via WhatsApp.',
        item_id=item_id,
    )


def notify_auction_ended_seller(db: Session, seller_id: str, item_title: str, item_id: str, winner_name: str = None, amount: float = None):
    """Tell the seller their auction ended."""
    if winner_name and amount:
        body = f'Your listing "{item_title}" sold to {winner_name} for ${amount:.2f}.'
    else:
        body = f'Your listing "{item_title}" ended with no bids.'
    _create(
        db, seller_id,
        type_="auction_ended_seller",
        title="Your auction has ended",
        body=body,
        item_id=item_id,
    )
