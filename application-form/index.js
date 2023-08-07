const express = require("express");
const app = express();
const path = require("path");

const port = 8080;

app.set('view engine', 'ejs');


app.get("/", (req, res) => {
    res.render("index");
})


app.listen(port, () => {
    console.log("Servidor rodando!");
})