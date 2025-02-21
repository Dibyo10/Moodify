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

      let emotionSummary = 'Neutral (No strong emotions detected)';
      let detailedEmotionData = '';

      if (predictions.length > 0) {
        const emotions = predictions[0].emotions;

        // Format emotions as "Happiness: 75%, Sadness: 20%"
        emotionSummary = emotions
          .map(e => `${e.name}: ${Math.round(e.score * 100)}%`)
          .join(', ');

        // Construct detailed breakdown for better AI understanding
        detailedEmotionData = emotions
          .map(e => `${e.name} (${(e.score * 100).toFixed(2)}%)`)
          .join('; ');
      }

      
      const prompt = `The user expressed the following emotions with confidence levels: ${detailedEmotionData}.
      Their message: "${userMessage}".
      
      As an empathetic therapist, craft a response that acknowledges the user's emotions using the confidence levels. 
      Provide thoughtful guidance based on these emotions and their intensities.
      
      If a specific emotion is dominant (above 50%), address it directly.
      If multiple emotions are detected, recognize their combination and provide balanced support.
      Maintain a friendly and understanding tone throughout.`;

      const model = genAI.getGenerativeModel({ model: 'gemini-pro' });
      const result = await model.generateContent(prompt);
      const responseText = result.response.text() || "Sorry, I couldn't understand.";

      res.json({ response: responseText, emotion: emotionSummary });
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
