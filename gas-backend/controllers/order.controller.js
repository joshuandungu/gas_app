const { Order, OrderItem, Product, Vendor } = require('../models');

exports.createOrder = async (req, res) => {
  try {
    // Assuming req.body contains necessary order data like userId, vendorId, totalAmount, status, and items array
    const { user_id, vendor_id, total_amount, status, items } = req.body;

    const order = await Order.create({
      user_id,
      vendor_id,
      total_amount,
      status: status || 'pending',
    });

    if (items && items.length > 0) {
      const orderItems = items.map(item => ({
        order_id: order.id,
        product_id: item.product_id,
        quantity: item.quantity,
        price: item.price,
      }));
      await OrderItem.bulkCreate(orderItems);
    }

    res.status(201).json({ message: 'Order created successfully', orderId: order.id });
  } catch (error) {
    console.error('Error creating order:', error);
    res.status(500).json({ error: 'Failed to create order' });
  }
};

exports.getAllOrders = async (req, res) => {
  try {
    const orders = await Order.findAll({
      include: [
        {
          model: OrderItem,
          include: [Product]
        },
        Vendor
      ]
    });
    res.status(200).json(orders);
  } catch (error) {
    console.error('Error fetching all orders:', error);
    res.status(500).json({ error: 'Failed to fetch all orders' });
  }
};

exports.getOrder = async (req, res) => {
  try {
    const orderId = req.params.id;

    const order = await Order.findByPk(orderId, {
      include: [
        {
          model: OrderItem,
          include: [Product]
        },
        Vendor
      ]
    });

    if (!order) {
      return res.status(404).json({ error: 'Order not found' });
    }

    res.status(200).json(order);
  } catch (error) {
    console.error('Error fetching order:', error);
    res.status(500).json({ error: 'Failed to fetch order' });
  }
};