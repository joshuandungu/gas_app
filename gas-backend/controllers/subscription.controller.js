const { Subscription } = require('../models');

exports.createSubscription = async (req, res) => {
  try {
    const imageUrl = req.file ? `${req.protocol}://${req.get('host')}/uploads/${req.file.filename}` : null;
    const item = await Subscription.create({ ...req.body, image_url: imageUrl });
    res.status(201).json(item);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Failed to create subscription' });
  }
};

exports.getAllSubscriptions = async (req, res) => {
  try {
    const items = await Subscription.findAll();
    res.json(items);
  } catch (err) {
    res.status(500).json({ error: 'Failed to fetch subscriptions' });
  }
};

exports.getSubscriptionById = async (req, res) => {
  try {
    const item = await Subscription.findByPk(req.params.id);
    if (!item) return res.status(404).json({ error: 'Not found' });
    res.json(item);
  } catch (err) {
    res.status(500).json({ error: 'Failed to fetch subscription' });
  }
};

exports.deleteSubscription = async (req, res) => {
  try {
    await Subscription.destroy({ where: { id: req.params.id } });
    res.json({ message: 'Deleted successfully' });
  } catch (err) {
    res.status(500).json({ error: 'Failed to delete subscription' });
  }
};