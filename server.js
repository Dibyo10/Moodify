require('dotenv').config();
const express = require('express');
const cors = require('cors');
const bodyParser = require('body-parser');
const axios = require('axios');
const WebSocket = require('ws');
const { GoogleGenerativeAI } = require('@google/generative-ai');

const app = express();
const port = process.env.PORT || 5002;

app.use(cors());
app.use(bodyParser.json());

const genAI = new GoogleGenerativeAI(process.env.AI_API_KEY);
const HUME_API_KEY = process.env.HUME_API_KEY;

app.post('/chat', async (req, res) => {
  try {
    const userMessage = req.body.message;
    const ws = new WebSocket('wss://api.hume.ai/v0/stream/models', {
      headers: { 'X-Hume-Api-Key': HUME_API_KEY }
    });

    ws.on('open', () => {
      ws.send(JSON.stringify({
        data: userMessage,
        models: { language: { granularity: 'word' } }
      }));
    });

    ws.on('message', async (data) => {
      const humeResponse = JSON.parse(data);
      const predictions = humeResponse?.language?.predictions || [];
      
      let dominantEmotion = 'neutral';
      if (predictions.length > 0) {
        const emotions = predictions[0].emotions;
        dominantEmotion = emotions.reduce((max, e) => e.score > max.score ? e : max, { name: 'neutral', score: 0 }).name;
      }

      
      const prompt = `User is feeling ${dominantEmotion}. Their message: "${userMessage}".
      As a therapist, provide a thoughtful and supportive response based on this emotion. Talk to the user in a very friendly tone too`;
      
      const model = genAI.getGenerativeModel({ model: 'gemini-pro' });
      const result = await model.generateContent(prompt);
      const responseText = result.response.text() || "Sorry, I couldn't understand.";

      res.json({ response: responseText, emotion: dominantEmotion });
      ws.close();
    });

    ws.on('error', (error) => {
      console.error('WebSocket Error:', error);
      res.status(500).json({ error: 'Error processing emotion analysis' });
    });

  } catch (error) {
    console.error('Error:', error);
    res.status(500).json({ error: 'Error generating response' });
  }
});

app.listen(port, () => console.log(`Server running on http://localhost:${port}`));
