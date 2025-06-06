from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
import asyncio  # ✅ Needed to gather async calls

from sentiment_analysis_and_chunking.database import SessionLocal
from sentiment_analysis_and_chunking.models import SentimentRecord
from sentiment_analysis_and_chunking.schemas import SentimentCreate
from sentiment_analysis_and_chunking.services.embedding import get_embedding
from sentiment_analysis_and_chunking.services.sentiment import analyze_sentiment
from sentiment_analysis_and_chunking.utils.text_processing import message

router = APIRouter()

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

@router.post("/sentiments")
async def create_sentiments(request: SentimentCreate, db: Session = Depends(get_db)):
    chunks=message(request.message)
    
    # ✅ Use asyncio.gather to handle multiple async calls
    embeddings = await asyncio.gather(*(get_embedding(chunk) for chunk in chunks))
    
    # If analyze_sentiment is async, also use await
    sentiments = await asyncio.gather(*(analyze_sentiment(chunk) for chunk in chunks))


    for chunk, sentiment, embedding in zip(chunks, sentiments, embeddings):
        sentiment_record = SentimentRecord(
            user_id=request.user_id,
            message=chunk,
            sentiment_score=sentiment,
            vector_embedding=embedding
        )
        db.add(sentiment_record)
    print(f"Inserting: user_id={request.user_id}, message='{chunk}', sentiment_score={sentiment}, vector_embedding={embedding}")

    db.commit()
    return {"message": "Sentiments processed successfully"}
