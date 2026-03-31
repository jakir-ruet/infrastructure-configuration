const { connection } = require('../config/db.config');

const createTransaction = async (amount, description) => {
    const [res] = await connection.query(
        'INSERT INTO transactions (amount, description) VALUES (?, ?)',
        [amount, description]
    );
    return res;
};

const getAllTransactions = async () => {
    const [rows] = await connection.query('SELECT * FROM transactions');
    return rows;
};

const updateTransaction = async (id, amount, description) => {
    const [res] = await connection.query(
        'UPDATE transactions SET amount=?, description=? WHERE id=?',
        [amount, description, id]
    );
    return res;
};

const deleteTransaction = async (id) => {
    const [res] = await connection.query(
        'DELETE FROM transactions WHERE id=?',
        [id]
    );
    return res;
};

module.exports = {
    createTransaction,
    getAllTransactions,
    updateTransaction,
    deleteTransaction
};
