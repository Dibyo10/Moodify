import openai
import asyncio

client = openai.AsyncOpenAI(api_key="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")  # Create an OpenAI client

async def analyze_sentiment(text: str):
    response = await client.chat.completions.create( 
        model="gpt-4",
        messages=[{"role": "system", "content": f"Analyze sentiment: {text}. Return a sentiment score between -1 (negative) and 1 (positive)."}]
    )

    try:
        sentiment_score = float(response.choices[0].message.content.strip())
    except ValueError:
        sentiment_score = 0.0 

    return sentiment_score
