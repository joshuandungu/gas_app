const { CylinderExchange } = require('../models');

exports.createCylinderExchange = async (req, res) => {
  try {
    const imageUrl = req.file ? `${req.protocol}://${req.get('host')}/uploads/${req.file.filename}` : null;
    const { capacity, ...rest } = req.body;
    const item = await CylinderExchange.create({
      ...rest,
      capacity: capacity ? parseFloat(capacity) : null, // Convert to number
      image_url: imageUrl
    });
    res.status(201).json(item);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Failed to create cylinder exchange' });
  }
};

exports.getAllCylinderExchange = async (req, res) => {
  try {
    const items = await CylinderExchange.findAll();
    res.json(items);
  } catch (err) {
    res.status(500).json({ error: 'Failed to fetch cylinder exchanges' });
  }
};

exports.getCylinderExchangeById = async (req, res) => {
  try {
    const item = await CylinderExchange.findByPk(req.params.id);
    if (!item) return res.status(404).json({ error: 'Not found' });
    res.json(item);
  } catch (err) {
    res.status(500).json({ error: 'Failed to fetch cylinder exchange' });
  }
};

exports.deleteCylinderExchange = async (req, res) => {
  try {
    await CylinderExchange.destroy({ where: { id: req.params.id } });
    res.json({ message: 'Deleted successfully' });
  } catch (err) {
    res.status(500).json({ error: 'Failed to delete cylinder exchange' });
  }
};