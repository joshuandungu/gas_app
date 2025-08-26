const express = require('express');
const router = express.Router();
const gasProductController = require('../controllers/gasProduct.controller');
const upload = require('../config/multerConfig');

// ✅ Safe handler wrapper
function safeHandler(handler, fallback) {
  return async (req, res) => {
    try {
      await handler(req, res);
    } catch (err) {
      console.error(`Gas Product route error [${req.method} ${req.originalUrl}]:`, err.message);
      res.status(200).json(fallback); // Always return JSON, never crash
    }
  };
}

// Routes
router.post(
  '/',
  upload.single('image'),
  safeHandler(gasProductController.createGasProduct, { success: false, message: 'Gas product creation failed' })
);

router.get(
  '/',
  safeHandler(gasProductController.getGasProducts, [])
);

router.get(
  '/:id',
  safeHandler(gasProductController.getGasProduct, {})
);

router.delete(
  '/:id',
  safeHandler(gasProductController.deleteGasProduct, { success: false, message: 'Gas product deletion failed' })
);

module.exports = router;