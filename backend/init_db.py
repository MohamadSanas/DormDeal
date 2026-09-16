import sys
from app.database.connection import engine
from app.database.base import Base
from app.models import user, item, bid, notification
from sqlalchemy import inspect

def main():
    print("Creating tables in Neon PostgreSQL...")
    Base.metadata.create_all(bind=engine)
    inspector = inspect(engine)
    tables = inspector.get_table_names()
    print("Successfully created/verified tables:", tables)

if __name__ == "__main__":
    main()
