import pytest
from fastapi.testclient import TestClient
from app.main import app
import uuid

client = TestClient(app)

def test_health():
    res = client.get("/")
    assert res.status_code == 200
    assert res.json()["status"] == "ok"

def test_full_flow():
    rand_suffix = uuid.uuid4().hex[:6]
    seller_email = f"seller_{rand_suffix}@campus.edu"
    bidder_email = f"bidder_{rand_suffix}@campus.edu"
    password = "SecurePassword123!"

    # 1. Register Seller
    print("[1/12] Registering seller...")
    seller_reg = client.post("/api/v1/auth/signup", json={
        "name": "Test Seller",
        "email": seller_email,
        "password": password,
        "whatsapp_number": "+1234567890",
        "university": "Campus Univ"
    })
    assert seller_reg.status_code == 201, seller_reg.text
    seller_data = seller_reg.json()
    seller_token = seller_data["access_token"]
    seller_headers = {"Authorization": f"Bearer {seller_token}"}

    # 2. Register Bidder
    print("[2/12] Registering bidder...")
    bidder_reg = client.post("/api/v1/auth/signup", json={
        "name": "Test Bidder",
        "email": bidder_email,
        "password": password,
        "whatsapp_number": "+1987654321",
        "university": "Campus Univ"
    })
    assert bidder_reg.status_code == 201, bidder_reg.text
    bidder_token = bidder_reg.json()["access_token"]
    bidder_headers = {"Authorization": f"Bearer {bidder_token}"}

    # 3. Test /auth/me
    print("[3/12] Verifying /auth/me...")
    me_res = client.get("/api/v1/auth/me", headers=seller_headers)
    assert me_res.status_code == 200
    assert me_res.json()["email"] == seller_email

    # 4. Seller creates an auction item
    print("[4/12] Creating auction listing...")
    item_res = client.post(
        "/api/v1/items/",
        headers=seller_headers,
        data={
            "title": f"Calculus Textbook {rand_suffix}",
            "description": "Like new condition, 8th edition",
            "base_price": 25.0,
            "category": "Textbooks",
            "auction_hours": 24,
            "whatsapp_number": "+1234567890"
        }
    )
    assert item_res.status_code == 200, item_res.text
    item_data = item_res.json()
    item_id = item_data["id"]
    assert item_data["current_price"] == 25.0
    assert item_data["category"] == "Textbooks"

    # 5. List items and filter
    print("[5/12] Listing items...")
    list_res = client.get(f"/api/v1/items/?category=Textbooks&search={rand_suffix}")
    assert list_res.status_code == 200
    items = list_res.json()
    assert any(it["id"] == item_id for it in items)

    # 6. Seller views their listings (/mine)
    print("[6/12] Checking seller /mine listings...")
    mine_res = client.get("/api/v1/items/mine", headers=seller_headers)
    assert mine_res.status_code == 200
    assert any(it["id"] == item_id for it in mine_res.json())

    # 7. Bidder places a bid (higher than starting price)
    print("[7/12] Bidder placing bid...")
    bid_res = client.post(
        f"/api/v1/items/{item_id}/bids",
        headers=bidder_headers,
        json={
            "amount": 35.0,
            "bidder_name": "Test Bidder",
            "bidder_whatsapp": "+1987654321"
        }
    )
    assert bid_res.status_code == 200, bid_res.text
    updated_item = bid_res.json()
    assert updated_item["current_price"] == 35.0
    assert updated_item["bid_count"] == 1

    # 8. Seller should receive a notification about the new bid
    print("[8/12] Checking seller notifications...")
    seller_notifs = client.get("/api/v1/notifications/", headers=seller_headers)
    assert seller_notifs.status_code == 200
    notifs = seller_notifs.json()
    assert len(notifs) >= 1
    assert any("new_bid" in n["type"] for n in notifs)

    # 9. Unread count for seller
    print("[9/12] Checking unread notifications count...")
    unread_res = client.get("/api/v1/notifications/unread-count", headers=seller_headers)
    assert unread_res.status_code == 200
    assert unread_res.json()["count"] >= 1

    # 10. Bidder views their active bids
    print("[10/12] Checking bidder /mine bids...")
    bidder_bids = client.get("/api/v1/bids/mine", headers=bidder_headers)
    assert bidder_bids.status_code == 200
    assert any(b["item_id"] == item_id for b in bidder_bids.json())

    # 11. Mark notification as read
    print("[11/12] Marking notification as read...")
    notif_id = notifs[0]["id"]
    read_res = client.patch(f"/api/v1/notifications/{notif_id}/read", headers=seller_headers)
    assert read_res.status_code == 200
    assert read_res.json()["is_read"] is True

    # 12. Seller deletes their item
    print("[12/12] Seller deleting item...")
    del_res = client.delete(f"/api/v1/items/{item_id}", headers=seller_headers)
    assert del_res.status_code == 204

    print("\n--- ALL BACKEND TEST ASSERTIONS PASSED SUCCESSFULLY! ---")
