// server.js
const express = require('express');
const app = express();

app.use(express.json());

// CI events endpoint used by Jenkins
app.post('/api/ci-events', (req, res) => {
  console.log('Received CI event:', req.body);
  res.status(200).json({ ok: true });
});

// Optional: a simple health check
app.get('/health', (req, res) => {
  res.json({ status: 'ok' });
});

const PORT = 3000;
app.listen(PORT, () => {
  console.log(`ValueCatcher running on port ${PORT}`);
});
