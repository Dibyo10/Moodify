from pydantic import BaseModel
from typing import List
from datetime import datetime

class SentimentCreate(BaseModel):
    user_id: int
    message: str
    sentiment_score: float
    vector_embedding: List[float]

class SentimentResponse(SentimentCreate):
    id: int
    timestamp: datetime

    class Config:
        from_attributes = True
