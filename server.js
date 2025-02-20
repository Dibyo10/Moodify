require('dotenv').config();
const express = require('express');
const cors = require('cors');
const bodyParser = require('body-parser');
const { GoogleGenerativeAI } = require('@google/generative-ai');

const app = express();
const port = process.env.PORT || 5002; // ✅ Ensure port matches Flutter

app.use(cors());
app.use(bodyParser.json());

const genAI = new GoogleGenerativeAI(process.env.AI_API_KEY); // ✅ Fix API Key usage

app.post('/chat', async (req, res) => {
  try {
    const userMessage = req.body.message;
    const prompt = `Give response to this message like a therapist would: ${userMessage}`;
    
    const model = genAI.getGenerativeModel({ model: 'gemini-pro' });
    const result = await model.generateContent(prompt);


    const responseText = result.response.text() || "Sorry, I couldn't understand.";

    res.json({ response: responseText });
  } catch (error) {
    console.error('Error:', error);
    res.status(500).json({ error: 'Error generating response' });
  }
});

app.listen(port, () => console.log(`Server running on http://localhost:${port}`));
