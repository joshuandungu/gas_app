const { CorporateSupply } = require('../models');

exports.createCorporateSupply = async (req, res) => {
  try {
    const imageUrl = req.file ? `${req.protocol}://${req.get('host')}/uploads/${req.file.filename}` : null;
    const item = await CorporateSupply.create({ ...req.body, image_url: imageUrl });
    res.status(201).json(item);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Failed to create corporate supply' });
  }
};

exports.getAllCorporateSupply = async (req, res) => {
  try {
    const items = await CorporateSupply.findAll();
    res.json(items);
  } catch (err) {
    res.status(500).json({ error: 'Failed to fetch corporate supply' });
  }
};

exports.getCorporateSupplyById = async (req, res) => {
  try {
    const item = await CorporateSupply.findByPk(req.params.id);
    if (!item) return res.status(404).json({ error: 'Not found' });
    res.json(item);
  } catch (err) {
    res.status(500).json({ error: 'Failed to fetch corporate supply' });
  }
};

exports.deleteCorporateSupply = async (req, res) => {
  try {
    await CorporateSupply.destroy({ where: { id: req.params.id } });
    res.json({ message: 'Deleted successfully' });
  } catch (err) {
    res.status(500).json({ error: 'Failed to delete corporate supply' });
  }
};