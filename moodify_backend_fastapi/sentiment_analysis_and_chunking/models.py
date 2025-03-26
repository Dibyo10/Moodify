from sqlalchemy import Column, Integer, String, Float, DateTime, ForeignKey
from sqlalchemy.dialects.postgresql import ARRAY
from sqlalchemy.sql import func
from pgvector.sqlalchemy import Vector
from app.database import Base

class SentimentRecord(Base):
    __tablename__ = "sentiments"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, nullable=False)
    message = Column(String, nullable=False)
    sentiment_score = Column(Float, nullable=False)
    vector_embedding = Column(Vector(1024), nullable=False)  # Assuming OpenAI's 1536-d embedding size
    timestamp = Column(DateTime(timezone=True), server_default=func.now())
