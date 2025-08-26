const { Promotion } = require('../models');

// Create promotion
exports.createPromotion = async (req, res) => {
  try {
    const promo = await Promotion.create(req.body);
    res.status(201).json(promo);
  } catch (error) {
    console.error('Error creating promotion:', error);
    res.status(500).json({ error: 'Failed to create promotion' });
  }
};

// Get all promotions
exports.getAllPromotions = async (req, res) => {
  try {
    const promos = await Promotion.findAll();
    res.json(promos);
  } catch (error) {
    console.error('Error fetching promotions:', error);
    res.status(500).json({ error: 'Failed to fetch promotions' });
  }
};

// Get promotion by ID
exports.getPromotionById = async (req, res) => {
  try {
    const promo = await Promotion.findByPk(req.params.id);
    if (!promo) return res.status(404).json({ error: 'Promotion not found' });
    res.json(promo);
  } catch (error) {
    console.error('Error fetching promotion:', error);
    res.status(500).json({ error: 'Failed to fetch promotion' });
  }
};

// Update promotion
exports.updatePromotion = async (req, res) => {
  try {
    const [updated] = await Promotion.update(req.body, {
      where: { id: req.params.id }
    });
    if (!updated) return res.status(404).json({ error: 'Promotion not found' });
    res.json({ message: 'Promotion updated successfully' });
  } catch (error) {
    console.error('Error updating promotion:', error);
    res.status(500).json({ error: 'Failed to update promotion' });
  }
};

// Delete promotion
exports.deletePromotion = async (req, res) => {
  try {
    const deleted = await Promotion.destroy({
      where: { id: req.params.id }
    });
    if (!deleted) return res.status(404).json({ error: 'Promotion not found' });
    res.json({ message: 'Promotion deleted successfully' });
  } catch (error) {
    console.error('Error deleting promotion:', error);
    res.status(500).json({ error: 'Failed to delete promotion' });
  }
};