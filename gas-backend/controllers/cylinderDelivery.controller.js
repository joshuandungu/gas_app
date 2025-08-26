const { CylinderDelivery } = require('../models');

exports.createCylinderDelivery = async (req, res) => {
  try {
    const imageUrl = req.file ? `${req.protocol}://${req.get('host')}/uploads/${req.file.filename}` : null;
    const item = await CylinderDelivery.create({ ...req.body, image_url: imageUrl });
    res.status(201).json(item);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Failed to create cylinder delivery' });
  }
};

exports.getAllCylinderDelivery = async (req, res) => {
  try {
    const items = await CylinderDelivery.findAll();
    res.json(items);
  } catch (err) {
    res.status(500).json({ error: 'Failed to fetch cylinder deliveries' });
  }
};

exports.getCylinderDeliveryById = async (req, res) => {
  try {
    const item = await CylinderDelivery.findByPk(req.params.id);
    if (!item) return res.status(404).json({ error: 'Not found' });
    res.json(item);
  } catch (err) {
    res.status(500).json({ error: 'Failed to fetch cylinder delivery' });
  }
};

exports.deleteCylinderDelivery = async (req, res) => {
  try {
    await CylinderDelivery.destroy({ where: { id: req.params.id } });
    res.json({ message: 'Deleted successfully' });
  } catch (err) {
    res.status(500).json({ error: 'Failed to delete cylinder delivery' });
  }
};