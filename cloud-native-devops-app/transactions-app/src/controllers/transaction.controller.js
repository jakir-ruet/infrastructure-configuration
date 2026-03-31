const service = require('../services/transaction.service');

exports.create = async (req, res, next) => {
    try {
        await service.add(req.body);
        res.status(201).json({ message: 'Created' });
    } catch (e) { next(e); }
};

exports.getAll = async (req, res, next) => {
    try {
        res.json(await service.getAll());
    } catch (e) { next(e); }
};

exports.update = async (req, res, next) => {
    try {
        await service.update(req.params.id, req.body);
        res.json({ message: 'Updated' });
    } catch (e) { next(e); }
};

exports.delete = async (req, res, next) => {
    try {
        await service.remove(req.params.id);
        res.json({ message: 'Deleted' });
    } catch (e) { next(e); }
};
