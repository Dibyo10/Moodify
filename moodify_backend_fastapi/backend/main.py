from fastapi import FastAPI, Depends, Request
from sqlalchemy.orm import Session
import openai
import twilio
import os
from twilio.rest import Client
from backend.database import SessionLocal
from backend.crud import save_message, get_recent_messages
from backend.config import TWILIO_ACCOUNT_SID, TWILIO_AUTH_TOKEN, TWILIO_WHATSAPP_NUMBER, OPENAI_API_KEY

app = FastAPI()

client = Client(TWILIO_ACCOUNT_SID, TWILIO_AUTH_TOKEN)
openai_client = openai.OpenAI(api_key="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"
 ) 

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

async def get_ai_response(db: Session, user_id: str, user_message: str):
    messages = get_recent_messages(db, user_id)
    chat_history = [{"role": msg.role, "content": msg.content} for msg in messages]

    chat_history.insert(0, {"role": "system", "content": "You are a therapist named Lily. Speak like a therapist. But, dont always talk like a therapist on normal messages like hi hello and stuff..be patient and supportive"})
    chat_history.append({"role": "user", "content": user_message})
    
    response = openai_client.chat.completions.create(  # ✅ Use the initialized OpenAI client
        model="gpt-4",
        messages=chat_history
    )

    ai_message = response.choices[0].message.content  # ✅ Correct response parsing
    save_message(db, user_id, "user", user_message)
    save_message(db, user_id, "assistant", ai_message)

    return ai_message

async def send_whatsapp_message(to: str, message: str):
    client.messages.create(
        from_="whatsapp:+14155238886",
        to=f"whatsapp:{to}",
        body=message
    )

@app.post("/twilio-status")
async def message_status(request: Request):
    data = await request.form()
    print("Message Status:", data)
    return {"status": "received"}

@app.post("/whatsapp")
async def receive_message(request: Request, db: Session = Depends(get_db)):
    form_data = await request.form()
    user_id = form_data["From"].replace("whatsapp:", "")
    user_message = form_data["Body"]

    ai_response = await get_ai_response(db, user_id, user_message)
    await send_whatsapp_message(user_id, ai_response)

    return {"status": "Message sent"}  # ✅ Removed extra period
