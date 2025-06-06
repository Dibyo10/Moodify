from fastapi import FastAPI
from sentiment_analysis_and_chunking.routes import sentiment_routes, search_routes
from sentiment_analysis_and_chunking.database import engine
from sentiment_analysis_and_chunking.models import Base
import nltk
import os

os.environ["TOKENIZERS_PARALLELISM"] = "false"

nltk.download("punkt")
nltk.download("punkt_tab")

app = FastAPI()

# Initialize database tables
Base.metadata.create_all(bind=engine)

# Include API routes
app.include_router(sentiment_routes.router, prefix="/sentiments", tags=["Sentiments"])
app.include_router(search_routes.router, prefix="/similar-sentiments", tags=["Similarity"])

@app.get("/")
def read_root():
    return {"message": "Moodify Sentiment Analysis API is running!"}
