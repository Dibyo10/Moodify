from sqlalchemy import Column, Integer, String, Text, TIMESTAMP
from backend.database import Base
from datetime import datetime

class ChatHistory(Base):
    __tablename__ = "chat_history"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(String, index=True)
    role = Column(String)
    content = Column(Text)
    timestamp = Column(TIMESTAMP, default=datetime.utcnow)
