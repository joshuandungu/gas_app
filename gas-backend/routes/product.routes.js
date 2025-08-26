const express = require('express');
const router = express.Router();
const productController = require('../controllers/product.controller');

// ✅ Universal safe wrapper
function safeHandler(handler, fallback) {
  return async (req, res) => {
    try {
      await handler(req, res);
    } catch (err) {
      console.error(`Product route error [${req.method} ${req.originalUrl}]:`, err.message);
      res.status(200).json(fallback);
    }
  };
}

// Routes
router.post(
  '/',
  safeHandler(productController.createProduct, { success: false, message: 'Product creation failed' })
);

router.get(
  '/',
  safeHandler(productController.getAllProducts, [])
);

router.get(
  '/:id',
  safeHandler(productController.getProductById, null)
);

router.put(
  '/:id',
  safeHandler(productController.updateProduct, { success: false, message: 'Update failed' })
);

router.delete(
  '/:id',
  safeHandler(productController.deleteProduct, { success: false, message: 'Delete failed' })
);

module.exports = router;
