'use strict';
const express = require('express');
const p = require('phin');

// Constants
const PORT = 8000;
const HOST = '0.0.0.0';

console.log('Starting express server');
// App
const app = express();
app.get('/', (req, res) => {
  res.send('Hello world\n');
});

app.get('/create', async (req, res) => {
  try {
    const data = await p({url: `http://${process.env.BE_SERVER}/create`, parse: 'json'});
    res.json(data.body);
  } catch (err) {
    res.status(500).send({
      message: err.message || 'Something went wrong while saving data'
    })
  }
});

app.get('/hellofromdb', async (req, res) => {
  try {
    const data = await p({url: `http://${process.env.BE_SERVER}/hellofromdb`, parse: 'json'});
    res.json(data.body);
  } catch (err) {
    res.status(500).send({
      message:
        err.message || "Some error occurred while retrieving data."
    });
  }
})

app.listen(PORT, HOST);
console.log(`Running on http://${HOST}:${PORT}`);