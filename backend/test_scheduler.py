import uuid
from datetime import datetime, timedelta
from app.database.connection import SessionLocal
from app.models.user import User
from app.models.item import Item
from app.models.bid import Bid
from app.models.notification import Notification
from app.services.auction_scheduler import finalize_expired_auctions

def test_auction_expiry_job():
    db = SessionLocal()
    try:
        rand_id = uuid.uuid4().hex[:6]
        # 1. Create seller and bidder
        seller = User(name=f"Seller {rand_id}", email=f"seller_{rand_id}@test.edu", hashed_password="pw")
        bidder = User(name=f"Bidder {rand_id}", email=f"bidder_{rand_id}@test.edu", hashed_password="pw")
        db.add_all([seller, bidder])
        db.commit()
        db.refresh(seller)
        db.refresh(bidder)

        # 2. Create an already expired auction item
        expired_time = datetime.utcnow() - timedelta(minutes=5)
        item = Item(
            owner_id=seller.id,
            title=f"Expired Item {rand_id}",
            base_price=10.0,
            current_price=20.0,
            current_bidder_id=bidder.id,
            current_bidder_name=bidder.name,
            auction_ends_at=expired_time,
            is_finalized=False,
            whatsapp_number="+1000000000"
        )
        db.add(item)
        db.commit()
        db.refresh(item)

        # 3. Run finalize_expired_auctions
        finalize_expired_auctions()

        # 4. Verify item is finalized
        db.refresh(item)
        assert item.is_finalized is True, "Item should be marked finalized"

        # 5. Verify winner notification was created
        winner_notif = db.query(Notification).filter(
            Notification.user_id == bidder.id,
            Notification.type == "auction_won"
        ).first()
        assert winner_notif is not None, "Winner should receive auction_won notification"
        assert f"Expired Item {rand_id}" in winner_notif.body

        # 6. Verify seller notification was created
        seller_notif = db.query(Notification).filter(
            Notification.user_id == seller.id,
            Notification.type == "auction_ended_seller"
        ).first()
        assert seller_notif is not None, "Seller should receive auction_ended_seller notification"

        # Clean up
        db.delete(winner_notif)
        db.delete(seller_notif)
        db.delete(item)
        db.delete(seller)
        db.delete(bidder)
        db.commit()
        print("\n--- AUCTION EXPIRY SCHEDULER TEST PASSED! ---")
    finally:
        db.close()
