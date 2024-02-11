from typing import List
from pydantic import BaseModel

class Prediction(BaseModel):
    name: str
    confidence: float

class Predictions(BaseModel):
    predictions: List[Prediction]