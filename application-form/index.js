const express = require("express");
const app = express();
const path = require("path");
const axios = require("axios");

const port = 80;

app.set("view engine", "ejs");

app.get("/", (req, res) => {
  res.render("index");
});

app.get("/ecs-connect", async (req, res) => {
  try {
    const response = await axios.get("http://storage-files/connect");
    console.log(JSON.stringify(response.data));
    res.send("<h1> ECS-SERVICE-CONNECT - ONLINE </h1>");
  } catch (error) {
    console.log(JSON.stringify(error));
    res.status(500);
    res.send("<h1> ECS CONNECT - OFLINE </h1>");
  }
});

app.listen(port, () => {
  console.log("Servidor rodando! 🚀");
});
