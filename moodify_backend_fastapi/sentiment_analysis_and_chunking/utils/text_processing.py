import nltk
from nltk.tokenize import sent_tokenize

nltk.download("punkt")

def message(text: str):
    return sent_tokenize(text)
