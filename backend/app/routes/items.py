from fastapi import APIRouter

router = APIRouter(prefix="/items", tags=["Items"])

@router.get("/")
def get_items():
    return [
        {"id": 1, "title": "Fan", "price": 3000},
        {"id": 2, "title": "Table", "price": 5000}
    ]
    