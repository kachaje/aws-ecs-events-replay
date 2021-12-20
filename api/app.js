const express = require("express");
const cors = require("cors");
const app = express();
const PORT = process.env.PORT || 4000;

app.use(cors());
app.use(express.json());
app.use(express.urlencoded(true));

app.get("/", (_, res) => {
  res.send("Welcome!");
});

app.post("/", (req, res) => {
  console.log("");
  console.log("*******************");
  console.log(req.body);
  console.log("*******************");
  console.log("");
  res.send("Done!");
});

app.listen(PORT, () => {
  console.log(`API Server running on port ${PORT}`);
});
