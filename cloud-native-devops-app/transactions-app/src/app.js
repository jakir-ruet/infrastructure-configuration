const express = require('express');
const app = express();

const routes = require('./routes/transaction.routes');
const errorHandler = require('./middlewares/error.middleware');

app.use(express.json());
app.use(express.static('public'));

app.use('/api/transactions', routes);

app.use(errorHandler);

module.exports = app;
