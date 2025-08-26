const OrderItem = require('../models/orderItem.model');

// Create new order item
exports.createOrderItem = async (req, res) => {
  try {
    const orderItem = await OrderItem.create(req.body);
    res.status(201).json(orderItem);
  } catch (error) {
    console.error('Error creating order item:', error);
    res.status(500).json({ error: 'Failed to create order item' });
  }
};

// Get all order items
exports.getAllOrderItems = async (req, res) => {
  try {
    const items = await OrderItem.findAll();
    res.json(items);
  } catch (error) {
    console.error('Error fetching order items:', error);
    res.status(500).json({ error: 'Failed to fetch order items' });
  }
};

// Get items by order ID
exports.getOrderItemsByOrder = async (req, res) => {
  try {
    const items = await OrderItem.findAll({
      where: { order_id: req.params.orderId }
    });
    res.json(items);
  } catch (error) {
    console.error('Error fetching order items:', error);
    res.status(500).json({ error: 'Failed to fetch order items' });
  }
};

// Update an order item
exports.updateOrderItem = async (req, res) => {
  try {
    const [updated] = await OrderItem.update(req.body, {
      where: { id: req.params.id }
    });
    if (!updated) return res.status(404).json({ error: 'Order item not found' });
    res.json({ message: 'Order item updated successfully' });
  } catch (error) {
    console.error('Error updating order item:', error);
    res.status(500).json({ error: 'Failed to update order item' });
  }
};

// Delete an order item
exports.deleteOrderItem = async (req, res) => {
  try {
    const deleted = await OrderItem.destroy({
      where: { id: req.params.id }
    });
    if (!deleted) return res.status(404).json({ error: 'Order item not found' });
    res.json({ message: 'Order item deleted successfully' });
  } catch (error) {
    console.error('Error deleting order item:', error);
    res.status(500).json({ error: 'Failed to delete order item' });
  }
};
