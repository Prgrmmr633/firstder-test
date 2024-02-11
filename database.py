from sqlalchemy import create_engine
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker

# SQLALCHEMY_DATABASE_URL = "https://autoderm.ai/v1/query?model=autoderm_v2_2&language=en"

URL_DATABASE = "postgresql://admin:admin@localhost:5432/Dermafy"

# engine = create_engine(SQLALCHEMY_DATABASE_URL)
engine = create_engine(URL_DATABASE)

SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

Base = declarative_base()

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()