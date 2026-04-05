// Guaranteed crash on startup
throw new Error("Simulated startup failure for GREEN v1.1.1-broken");

const express = require("express");
const app = express();

app.get("/", (req, res) => {
  res.json({ message: "This is the GREEN version v1.1.1 (BROKEN)" });
});

app.get("/health", (req, res) => {
  res.json({ status: "BROKEN" });
});

app.listen(5000, () => {
  console.log("GREEN (broken) API attempting to run on port 5000");
});
