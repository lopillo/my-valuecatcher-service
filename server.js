const express = require('express');
const app = express();
app.use(express.json());

app.post('/api/ci-events', (req, res) => {
  console.log("Received:", req.body);
  res.json({message: "Stored OK"});
});

app.listen(3000, () => console.log("ValueCatcher running on port 3000"));
