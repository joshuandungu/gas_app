const express = require('express');
const router = express.Router();
const subscriptionController = require('../controllers/subscription.controller');
const upload = require('../config/multerConfig');

// ✅ Universal error-safe wrapper
function safeHandler(handler, fallback) {
  return async (req, res) => {
    try {
      await handler(req, res);
    } catch (err) {
      console.error(`Subscription route error [${req.method} ${req.originalUrl}]:`, err.message);
      res.status(200).json(fallback);
    }
  };
}

// Routes
router.post(
  '/',
  upload.single('image'),
  safeHandler(subscriptionController.createSubscription, { success: false, message: 'Subscription creation failed' })
);

router.get(
  '/',
  safeHandler(subscriptionController.getAllSubscriptions, [])
);

router.get(
  '/:id',
  safeHandler(subscriptionController.getSubscriptionById, null)
);

router.delete(
  '/:id',
  safeHandler(subscriptionController.deleteSubscription, { success: false, message: 'Delete failed' })
);

module.exports = router;
