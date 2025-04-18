from transformers import AutoTokenizer, AutoModel
import torch


model_name = "facebook/bart-large"
tokenizer = AutoTokenizer.from_pretrained(model_name)
model = AutoModel.from_pretrained(model_name)

async def get_embedding(text: str):
   
    inputs = tokenizer(text, return_tensors="pt", truncation=True, padding=True)

   
    with torch.no_grad():
        outputs = model(**inputs)

   
    embedding = outputs.last_hidden_state[:, 0, :].squeeze().tolist()
    return embedding if isinstance(embedding, list) else [embedding]
