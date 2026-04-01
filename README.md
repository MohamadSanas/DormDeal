# Campus Marketplace

A simple, fast marketplace for university students to buy and sell used items within their campus.

---

## 🚀 Problem

Students living in private boarding houses struggle to sell items (fans, tables, chairs, etc.) when moving out.
Current solutions (WhatsApp groups, Facebook posts) are messy, unstructured, and inefficient.

---

## 💡 Solution

Campus Marketplace provides a **minimal, fast, and structured platform** where students can:

* Post items in seconds
* Browse available listings
* Contact sellers directly via WhatsApp

---

## 🧱 Tech Stack

### Frontend

* Flutter (Mobile App)

### Backend

* FastAPI (Python)

### Database

* SQLite (MVP stage)
* PostgreSQL (future scaling)

### Storage

* Cloudinary / Firebase Storage (for images)

---

## ⚙️ Features (MVP)

* 📦 Post an item (title, price, image, contact)
* 📃 Browse listings
* 🔍 View item details
* 📱 Contact seller via WhatsApp

---

## 📁 Project Structure

```
campus-marketplace/
│
├── backend/
│   ├── app/
│   │   ├── main.py
│   │   ├── routes/
│   │   ├── models/
│   │   ├── schemas/
│   │   └── database/
│   ├── requirements.txt
│   └── .env
│
├── frontend/
│   ├── lib/
│   └── pubspec.yaml
│
├── README.md
└── .gitignore
```

---

## 🛠️ Setup Instructions

### Backend (FastAPI)

```bash
cd backend
python -m venv venv
venv\Scripts\activate   # Windows
pip install -r requirements.txt
uvicorn app.main:app --reload
```

API will run at:

```
http://127.0.0.1:8000
```

Swagger docs:

```
http://127.0.0.1:8000/docs
```

---

### Frontend (Flutter)

```bash
cd frontend
flutter pub get
flutter run
```

---

## 🎯 MVP Goal

Launch a working product within **2–3 weeks** for students moving out of boarding.

Focus:

* Speed
* Simplicity
* Real usage (not perfect UI)

---

## ⚠️ Current Limitations

* No authentication
* No in-app chat (uses WhatsApp)
* No payment system
* Basic UI

---

## 🔮 Future Improvements

* User accounts
* In-app messaging
* Search & filters
* Location-based listings
* Ratings & reviews

---

## 🤝 Contribution

This is an early-stage project. Contributions, ideas, and feedback are welcome.

---

## 📌 Status

🚧 MVP in development — rapid iteration phase
