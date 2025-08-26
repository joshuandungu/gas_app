const express = require('express');
const router = express.Router();
const cylinderExchangeController = require('../controllers/cylinderExchange.controller');
const upload = require('../config/multerConfig');

// ✅ Safe handler wrapper
function safeHandler(handler, fallback) {
  return async (req, res) => {
    try {
      await handler(req, res);
    } catch (err) {
      console.error(`Cylinder Exchange route error [${req.method} ${req.originalUrl}]:`, err.message);
      res.status(200).json(fallback); // Always return JSON, no crash
    }
  };
}

// Routes
router.post(
  '/',
  upload.single('image'),
  safeHandler(cylinderExchangeController.createCylinderExchange, { success: false, message: 'Cylinder exchange creation failed' })
);

router.get(
  '/',
  safeHandler(cylinderExchangeController.getAllCylinderExchange, [])
);

router.get(
  '/:id',
  safeHandler(cylinderExchangeController.getCylinderExchangeById, {})
);

router.delete(
  '/:id',
  safeHandler(cylinderExchangeController.deleteCylinderExchange, { success: false, message: 'Cylinder exchange deletion failed' })
);

module.exports = router;
