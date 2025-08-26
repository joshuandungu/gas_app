const express = require('express');
const router = express.Router();
const categoryController = require('../controllers/category.controller');

// ✅ Safe wrapper to handle errors gracefully
function safeHandler(handler, fallback) {
  return async (req, res) => {
    try {
      await handler(req, res);
    } catch (err) {
      console.error(`Category route error [${req.method} ${req.originalUrl}]:`, err.message);
      res.status(200).json(fallback); // Always return valid JSON
    }
  };
}

// Routes
router.post(
  '/',
  safeHandler(categoryController.createCategory, { success: false, message: 'Category creation failed' })
);

router.get(
  '/',
  safeHandler(categoryController.getAllCategories, [])
);

router.get(
  '/:id',
  safeHandler(categoryController.getCategoryById, {})
);

router.put(
  '/:id',
  safeHandler(categoryController.updateCategory, { success: false, message: 'Category update failed' })
);

router.delete(
  '/:id',
  safeHandler(categoryController.deleteCategory, { success: false, message: 'Category deletion failed' })
);

module.exports = router;
