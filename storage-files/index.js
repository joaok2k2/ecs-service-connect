const express = require("express");
const app = express();
const multer = require("multer");
const path = require("path");

const port = 80;

const storage = multer.diskStorage({
    destination: (req, file, cb) => {
        cb(null, "./uploads/");
        
    },
    filename: (req, file, cb) => {
        cb(null, file.originalname + Date.now() + path.extname(file.originalname));
    }
})
const upload = multer({storage})

app.get("/", (req, res) => {
    try {
        res.sendStatus(200)
    } catch (error){
        res.sendStatus(500)
    }
})

app.get("/connect", (req, res) => {
    try {
        console.log("Service Connect Works!");
        res.status(200).send("Connect OK!")
    } catch (error){
        res.sendStatus(500)
    }
})

app.post("/upload", upload.single("file"), (req, res) => {
    res.status(200).send("Arquivo Recebido!");
})

app.listen(port, () => {
    console.log("Servidor rodando!");
})