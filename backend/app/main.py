from fastapi import FastAPI
from app.routes import items
from app.database.connection import engine, Base

app = FastAPI()

# Create tables
Base.metadata.create_all(bind=engine)

# Include routes
app.include_router(items.router)


@app.get("/")
def root():
    return {"message": "API is running"}