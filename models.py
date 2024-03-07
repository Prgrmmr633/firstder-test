from sqlalchemy import Column, String, Float, ForeignKey, Integer, DateTime
from sqlalchemy.orm import sessionmaker, relationship
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy import create_engine

Base = declarative_base()

class Prediction(Base):
    __tablename__ = "predictions"

    id = Column(Integer, primary_key=True)
    name = Column(String)
    confidence_score = Column(Float)
    read_more_url = Column(String)
    date_added = Column(DateTime)

    user_inputs = relationship("UserInput", back_populates="prediction")

class UserInput(Base):
    __tablename__ = "user_inputs"

    id = Column(Integer, primary_key=True)
    image = Column(String)
    prediction_id = Column(Integer, ForeignKey("predictions.id"))
    date_added = Column(DateTime)

    prediction = relationship("Prediction", back_populates="user_inputs")

# Set up the database (only create the engine here)
engine = create_engine("postgresql://postgres:admin123@localhost:5432/Dermafy")

# Create a session
Session = sessionmaker(bind=engine)
session = Session()
