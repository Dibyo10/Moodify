from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from sqlalchemy.sql import text
from sentiment_analysis_and_chunking.database import SessionLocal

router = APIRouter()

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

@router.get("/similar-sentiments/{id}")
def get_similar_sentiments(id: int, db: Session = Depends(get_db), top_n: int = 5):
    query = text("""
    SELECT id, user_id, message, sentiment_score, timestamp, 
        (vector_embedding <=> (SELECT vector_embedding FROM sentiments WHERE id = :id)) AS cosine_similarity
    FROM sentiments
    WHERE id != :id
    ORDER BY cosine_similarity ASC
    LIMIT :top_n;
    """)

    results = db.execute(query, {"id": id, "top_n": top_n}).mappings().all()
    return {"similar_sentiments": [row for row in results]}
