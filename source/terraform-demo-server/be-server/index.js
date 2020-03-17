'use strict';
const express = require('express');

// Constants
const PORT = 8080;
const HOST = '0.0.0.0';

console.log('Starting express server');
// App
const app = express();

const db = require("./models");
db.sequelize.sync();

const Hello = db.hello;
const Op = db.Sequelize.Op;

app.get('/', (req, res) => {
  res.send('Hello world\n');
});

app.get('/create', async (req, res) => {
 try {
  const obj = {
    title: 'hello',
    description: 'Hello world from DB'
  };

  const data = await Hello.create(obj);
  res.json(data);
 } catch (err) {
   res.status(500).send({
     message: err.message || 'Something went wrong while saving data'
   })
 }
});

app.get('/hellofromdb', async (req, res) => {
  try {
    const condition = { title: { [Op.like]: `%hello%` } };

    const data = await Hello.findAll({ where: condition });
    res.json(data);
  } catch (err) {
    res.status(500).send({
      message:
        err.message || "Some error occurred while retrieving data."
    });
  }
})

app.listen(PORT, HOST);
console.log(`Running on http://${HOST}:${PORT}`);