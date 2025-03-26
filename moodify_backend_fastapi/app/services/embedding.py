from transformers import AutoTokenizer, AutoModel
import torch

# Load Facebook BART model
model_name = "facebook/bart-large"
tokenizer = AutoTokenizer.from_pretrained(model_name)
model = AutoModel.from_pretrained(model_name)

async def get_embedding(text: str):
    # Tokenize input text
    inputs = tokenizer(text, return_tensors="pt", truncation=True, padding=True)

    # Get model output
    with torch.no_grad():
        outputs = model(**inputs)

    # Extract embeddings (use the last hidden state of the first token [CLS])
    embedding = outputs.last_hidden_state[:, 0, :].squeeze().tolist()
    return embedding if isinstance(embedding, list) else [embedding]
