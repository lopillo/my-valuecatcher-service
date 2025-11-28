// server.js (example skeleton)
const express = require('express');
const app = express();

app.use(express.json());

app.post('/api/ci-events', (req, res) => {
  console.log('Received CI event:', req.body);
  res.status(200).json({ ok: true });
});

app.listen(3000, () => {
  console.log('ValueCatcher running on port 3000');
});
