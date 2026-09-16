import logging
from datetime import datetime

from apscheduler.schedulers.asyncio import AsyncIOScheduler
from sqlalchemy.orm import Session

from app.database.connection import SessionLocal
from app.models.item import Item
from app.services import notification_service

logger = logging.getLogger(__name__)
scheduler = AsyncIOScheduler()


def finalize_expired_auctions():
    """
    Runs every minute. Finds all auctions that have expired but are not yet
    finalized, fires winner/seller notifications, and marks them finalized.
    """
    db: Session = SessionLocal()
    try:
        now = datetime.utcnow()
        expired_items = (
            db.query(Item)
            .filter(Item.auction_ends_at <= now, Item.is_finalized == False)
            .all()
        )

        for item in expired_items:
            logger.info(f"Finalizing auction for item {item.id} — '{item.title}'")
            item.is_finalized = True

            if item.current_bidder_id and item.owner_id:
                notification_service.notify_auction_won(
                    db,
                    winner_id=item.current_bidder_id,
                    item_title=item.title,
                    item_id=item.id,
                    amount=item.current_price,
                )
                notification_service.notify_auction_ended_seller(
                    db,
                    seller_id=item.owner_id,
                    item_title=item.title,
                    item_id=item.id,
                    winner_name=item.current_bidder_name,
                    amount=item.current_price,
                )
            elif item.owner_id:
                # No bids — notify seller auction ended with no bids
                notification_service.notify_auction_ended_seller(
                    db,
                    seller_id=item.owner_id,
                    item_title=item.title,
                    item_id=item.id,
                )

        if expired_items:
            db.commit()
            logger.info(f"Finalized {len(expired_items)} expired auction(s).")
    except Exception as e:
        logger.error(f"Error in finalize_expired_auctions: {e}")
        db.rollback()
    finally:
        db.close()


def start_scheduler():
    scheduler.add_job(finalize_expired_auctions, "interval", minutes=1, id="auction_finalizer")
    scheduler.start()
    logger.info("Auction scheduler started — checking every 60 seconds.")


def stop_scheduler():
    scheduler.shutdown()
    logger.info("Auction scheduler stopped.")
