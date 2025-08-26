const express = require('express');
const router = express.Router();
const orderController = require('../controllers/order.controller');

// ✅ Safe handler wrapper
function safeHandler(handler, fallback) {
  return async (req, res) => {
    try {
      await handler(req, res);
    } catch (err) {
      console.error(`Order route error [${req.method} ${req.originalUrl}]:`, err.message);
      res.status(200).json(fallback); // Always return JSON so Flutter won't crash
    }
  };
}

// Routes
router.post(
  '/',
  safeHandler(orderController.createOrder, { success: false, message: 'Order creation failed' })
);

router.get(
  '/',
  safeHandler(orderController.getAllOrders, [])
);

module.exports = router;
