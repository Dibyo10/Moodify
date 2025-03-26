import os
from dotenv import load_dotenv

# Load environment variables from .env file
load_dotenv()

# Retrieve values from .env
DATABASE_URL = os.getenv("DATABASE_URL")
TWILIO_ACCOUNT_SID = os.getenv("TWILIO_SID")
TWILIO_AUTH_TOKEN = os.getenv("TWILIO_AUTH_TOKEN")
TWILIO_WHATSAPP_NUMBER = os.getenv("TWILIO_PHONE")
OPENAI_API_KEY = os.getenv("OPENAI_API_KEY")
