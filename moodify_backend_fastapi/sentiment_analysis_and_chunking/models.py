from sqlalchemy import Column, Integer, String, Float, DateTime, ForeignKey
from sqlalchemy.dialects.postgresql import ARRAY
from sqlalchemy.sql import func
from pgvector.sqlalchemy import Vector
from sentiment_analysis_and_chunking.database import Base

class SentimentRecord(Base):
    __tablename__ = "sentiments"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, nullable=False)
    message = Column(String, nullable=False)
    sentiment_score = Column(Float, nullable=False)
    vector_embedding = Column(Vector(1024), nullable=False) 
    timestamp = Column(DateTime(timezone=True), server_default=func.now())
