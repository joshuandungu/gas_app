const express = require('express');
const router = express.Router();
const promotionController = require('../controllers/promotion.controller');

// ✅ Universal error-safe wrapper
function safeHandler(handler, fallback) {
  return async (req, res) => {
    try {
      await handler(req, res);
    } catch (err) {
      console.error(`Promotion route error [${req.method} ${req.originalUrl}]:`, err.message);
      res.status(200).json(fallback);
    }
  };
}

// Routes
router.post(
  '/',
  safeHandler(promotionController.createPromotion, { success: false, message: 'Promotion creation failed' })
);

router.get(
  '/',
  safeHandler(promotionController.getAllPromotions, [])
);

router.get(
  '/:id',
  safeHandler(promotionController.getPromotionById, null)
);

router.put(
  '/:id',
  safeHandler(promotionController.updatePromotion, { success: false, message: 'Update failed' })
);

router.delete(
  '/:id',
  safeHandler(promotionController.deletePromotion, { success: false, message: 'Delete failed' })
);

module.exports = router;
