from sqlalchemy import Column, String, Float, create_engine, Boolean, ForeignKey, Integer
from sqlalchemy.orm import sessionmaker
from sqlalchemy.ext.declarative import declarative_base

Base = declarative_base()


class Prediction(Base):
    __tablename__ = "predictions"

    name = Column(String, primary_key=True)
    confidence_score = Column(Float)
    read_more_url = Column(String)


# Set up the database
engine = create_engine("postgresql://user:password@localhost:5432/mydatabase")
Base.metadata.create_all(engine)

# Create a session
Session = sessionmaker(bind=engine)
session = Session()

# # Example of how to add a new prediction
# new_prediction = Prediction(name="Example", confidence_score=0.95, read_more_url="http://example.com")
# session.add(new_prediction)
# session.commit()
