from sqlalchemy.orm import Session
from backend.models import ChatHistory

def save_message(db: Session, user_id: str, role: str, content: str):
    message = ChatHistory(user_id=user_id, role=role, content=content)
    db.add(message)
    db.commit()

def get_recent_messages(db: Session, user_id: str, limit=10):
    return db.query(ChatHistory).filter(ChatHistory.user_id == user_id).order_by(ChatHistory.timestamp.desc()).limit(limit).all()
