const express = require('express');
const router = express.Router();
const cylinderDeliveryController = require('../controllers/cylinderDelivery.controller');
const upload = require('../config/multerConfig');

// ✅ Safe handler wrapper
function safeHandler(handler, fallback) {
  return async (req, res) => {
    try {
      await handler(req, res);
    } catch (err) {
      console.error(`Cylinder Delivery route error [${req.method} ${req.originalUrl}]:`, err.message);
      res.status(200).json(fallback); // Always return JSON
    }
  };
}

// Routes
router.post(
  '/',
  upload.single('image'),
  safeHandler(cylinderDeliveryController.createCylinderDelivery, { success: false, message: 'Cylinder delivery creation failed' })
);

router.get(
  '/',
  safeHandler(cylinderDeliveryController.getAllCylinderDelivery, [])
);

router.get(
  '/:id',
  safeHandler(cylinderDeliveryController.getCylinderDeliveryById, {})
);

router.delete(
  '/:id',
  safeHandler(cylinderDeliveryController.deleteCylinderDelivery, { success: false, message: 'Cylinder delivery deletion failed' })
);

module.exports = router;
