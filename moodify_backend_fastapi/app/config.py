import os
from dotenv import load_dotenv

load_dotenv()

DATABASE_URL = os.getenv("DATABASE_URL", "postgresql://dibyochakraborty@localhost:5432/moodify_db")
OPENAI_API_KEY = os.getenv("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")
