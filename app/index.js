const express = require("express");
const app = express();

app.get("/", (req, res) => {
  res.json({ message: "This is the BLUE version v1.1.0 (stable)" });
});

app.get("/health", (req, res) => {
  res.json({ status: "OK" });
});

app.listen(5000, () => {
  console.log("BLUE (stable) API running on port 5000");
});
