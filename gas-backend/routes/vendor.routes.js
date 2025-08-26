const express = require('express');
const router = express.Router();
const vendorController = require('../controllers/vendor.controller');

// ✅ Universal error-safe wrapper
function safeHandler(handler, fallback) {
  return async (req, res) => {
    try {
      await handler(req, res);
    } catch (err) {
      console.error(`Vendor route error [${req.method} ${req.originalUrl}]:`, err.message);
      res.status(200).json(fallback);
    }
  };
}

// Routes
router.post(
  '/',
  safeHandler(vendorController.createVendor, { success: false, message: 'Vendor creation failed' })
);

router.get(
  '/',
  safeHandler(vendorController.getAllVendors, [])
);

router.get(
  '/:id',
  safeHandler(vendorController.getVendorById, null)
);

router.put(
  '/:id',
  safeHandler(vendorController.updateVendor, { success: false, message: 'Vendor update failed' })
);

router.delete(
  '/:id',
  safeHandler(vendorController.deleteVendor, { success: false, message: 'Vendor deletion failed' })
);

module.exports = router;
