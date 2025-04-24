import os
import openai
import asyncio
from dotenv import load_dotenv

load_dotenv()

client = openai.AsyncOpenAI(api_key=os.getenv("OPENAI_API_KEY"))

async def analyze_sentiment(text: str):
    try:
        response = await client.chat.completions.create(
            model="gpt-4",
            messages=[
                {"role": "system", "content": "You are a sentiment analysis assistant."},
                {"role": "user", "content": f"Analyze this text and return a sentiment score between -1 (negative) and 1 (positive): {text}"}
            ]
        )
        result = response.choices[0].message.content.strip()
        sentiment_score = float(result)
    except (ValueError, AttributeError, IndexError):
        sentiment_score = 0.0  # Default to neutral on error
    return sentiment_score
