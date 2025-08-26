const { GasProduct } = require('../models');

exports.createGasProduct = async (req, res) => {
  try {
    const imageUrl = req.file ? `${req.protocol}://${req.get('host')}/uploads/${req.file.filename}` : null;
    const product = await GasProduct.create({ ...req.body, image_url: imageUrl });
    res.status(201).json(product);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Failed to create gas product' });
  }
};

exports.getGasProducts = async (req, res) => {
  try {
    const products = await GasProduct.findAll();
    res.json(products);
  } catch (err) {
    res.status(500).json({ error: 'Failed to fetch gas products' });
  }
};

exports.getGasProduct = async (req, res) => {
  try {
    const product = await GasProduct.findByPk(req.params.id);
    if (!product) return res.status(404).json({ error: 'Not found' });
    res.json(product);
  } catch (err) {
    res.status(500).json({ error: 'Failed to fetch gas product' });
  }
};

exports.deleteGasProduct = async (req, res) => {
  try {
    await GasProduct.destroy({ where: { id: req.params.id } });
    res.json({ message: 'Deleted successfully' });
  } catch (err) {
    res.status(500).json({ error: 'Failed to delete gas product' });
  }
};