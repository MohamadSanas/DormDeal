from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from app.database.connection import SessionLocal
from app.models.item import Item
from app.schemas.item import ItemCreate, ItemResponse

router = APIRouter(prefix="/items", tags=["Items"])


# DB Dependency
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()


# CREATE ITEM
@router.post("/", response_model=ItemResponse)
def create_item(item: ItemCreate, db: Session = Depends(get_db)):
    new_item = Item(**item.dict())
    db.add(new_item)
    db.commit()
    db.refresh(new_item)
    return new_item


# GET ALL ITEMS
@router.get("/", response_model=list[ItemResponse])
def get_items(db: Session = Depends(get_db)):
    return db.query(Item).all()