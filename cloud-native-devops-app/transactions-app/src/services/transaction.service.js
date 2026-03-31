const model = require('../models/transaction.model');

const add = (data) => model.createTransaction(data.amount, data.description);
const getAll = () => model.getAllTransactions();
const update = (id, data) => model.updateTransaction(id, data.amount, data.description);
const remove = (id) => model.deleteTransaction(id);

module.exports = { add, getAll, update, remove };
