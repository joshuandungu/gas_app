const express = require('express');
const router = express.Router();
const orderItemController = require('../controllers/orderItem.controller');

// ✅ Universal error-safe wrapper
function safeHandler(handler, fallback) {
  return async (req, res) => {
    try {
      await handler(req, res);
    } catch (err) {
      console.error(`OrderItem route error [${req.method} ${req.originalUrl}]:`, err.message);
      res.status(200).json(fallback);
    }
  };
}

// Routes
router.post(
  '/',
  safeHandler(orderItemController.createOrderItem, { success: false, message: 'Order item creation failed' })
);

router.get(
  '/',
  safeHandler(orderItemController.getAllOrderItems, [])
);

router.get(
  '/order/:orderId',
  safeHandler(orderItemController.getOrderItemsByOrder, [])
);

router.put(
  '/:id',
  safeHandler(orderItemController.updateOrderItem, { success: false, message: 'Update failed' })
);

router.delete(
  '/:id',
  safeHandler(orderItemController.deleteOrderItem, { success: false, message: 'Delete failed' })
);

module.exports = router;
