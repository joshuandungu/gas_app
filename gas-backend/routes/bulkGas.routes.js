const express = require('express');
const router = express.Router();
const bulkGasController = require('../controllers/bulkGas.controller');
const upload = require('../config/multerConfig');

// ✅ Safe wrapper to prevent route crashes
function safeHandler(handler, fallback) {
  return async (req, res) => {
    try {
      await handler(req, res);
    } catch (err) {
      console.error(`Bulk Gas route error [${req.method} ${req.originalUrl}]:`, err.message);
      res.status(200).json(fallback); // Always send safe default
    }
  };
}

// Routes
router.post(
  '/',
  upload.single('image'),
  safeHandler(bulkGasController.createBulkGas, { success: false, message: 'Bulk gas creation failed' })
);

router.get(
  '/',
  safeHandler(bulkGasController.getBulkGasAll, [])
);

router.get(
  '/:id',
  safeHandler(bulkGasController.getBulkGasById, {})
);

router.delete(
  '/:id',
  safeHandler(bulkGasController.deleteBulkGas, { success: false, message: 'Delete failed' })
);

module.exports = router;
