const { Delivery } = require('../models');

exports.createDelivery = async (req, res) => {
  try {
    const delivery = await Delivery.create(req.body);
    res.status(201).json(delivery);
  } catch (error) {
    console.error('Error creating delivery:', error);
    res.status(500).json({ error: 'Failed to create delivery' });
  }
};

exports.getAllDeliveries = async (req, res) => {
  try {
    const deliveries = await Delivery.findAll();
    res.status(200).json(deliveries);
  } catch (error) {
    console.error('Error fetching deliveries:', error);
    res.status(500).json({ error: 'Failed to fetch deliveries' });
  }
};

exports.getDeliveryById = async (req, res) => {
  try {
    const delivery = await Delivery.findByPk(req.params.id);
    if (!delivery) {
      return res.status(404).json({ error: 'Delivery not found' });
    }
    res.status(200).json(delivery);
  } catch (error) {
    console.error('Error fetching delivery:', error);
    res.status(500).json({ error: 'Failed to fetch delivery' });
  }
};

exports.updateDelivery = async (req, res) => {
  try {
    const [updated] = await Delivery.update(req.body, {
      where: { id: req.params.id }
    });
    if (!updated) {
      return res.status(404).json({ error: 'Delivery not found' });
    }
    res.status(200).json({ message: 'Delivery updated successfully' });
  } catch (error) {
    console.error('Error updating delivery:', error);
    res.status(500).json({ error: 'Failed to update delivery' });
  }
};

exports.deleteDelivery = async (req, res) => {
  try {
    const deleted = await Delivery.destroy({
      where: { id: req.params.id }
    });
    if (!deleted) {
      return res.status(404).json({ error: 'Delivery not found' });
    }
    res.status(200).json({ message: 'Delivery deleted successfully' });
  } catch (error) {
    console.error('Error deleting delivery:', error);
    res.status(500).json({ error: 'Failed to delete delivery' });
  }
};