const { BulkGas } = require('../models');

exports.createBulkGas = async (req, res) => {
  try {
    const imageUrl = req.file ? `${req.protocol}://${req.get('host')}/uploads/${req.file.filename}` : null;
    const { capacity, ...rest } = req.body;
    const item = await BulkGas.create({
      ...rest,
      capacity: capacity ? parseFloat(capacity) : null, // Convert to number
      image_url: imageUrl
    });
    res.status(201).json(item);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Failed to create bulk gas supply' });
  }
};

exports.getBulkGasAll = async (req, res) => {
  try {
    const items = await BulkGas.findAll();
    res.json(items);
  } catch (err) {
    res.status(500).json({ error: 'Failed to fetch bulk gas supplies' });
  }
};

exports.getBulkGasById = async (req, res) => {
  try {
    const item = await BulkGas.findByPk(req.params.id);
    if (!item) return res.status(404).json({ error: 'Not found' });
    res.json(item);
  } catch (err) {
    res.status(500).json({ error: 'Failed to fetch bulk gas supply' });
  }
};

exports.deleteBulkGas = async (req, res) => {
  try {
    await BulkGas.destroy({ where: { id: req.params.id } });
    res.json({ message: 'Deleted successfully' });
  } catch (err) {
    res.status(500).json({ error: 'Failed to delete bulk gas supply' });
  }
};