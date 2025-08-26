const express = require('express');
const router = express.Router();
const corporateSupplyController = require('../controllers/corporateSupply.controller');
const upload = require('../config/multerConfig');

// ✅ Safe handler to avoid crashes
function safeHandler(handler, fallback) {
  return async (req, res) => {
    try {
      await handler(req, res);
    } catch (err) {
      console.error(`Corporate Supply route error [${req.method} ${req.originalUrl}]:`, err.message);
      res.status(200).json(fallback); // Always return valid JSON instead of crashing
    }
  };
}

// Routes
router.post(
  '/',
  upload.single('image'),
  safeHandler(corporateSupplyController.createCorporateSupply, { success: false, message: 'Corporate supply creation failed' })
);

router.get(
  '/',
  safeHandler(corporateSupplyController.getAllCorporateSupply, [])
);

router.get(
  '/:id',
  safeHandler(corporateSupplyController.getCorporateSupplyById, {})
);

router.delete(
  '/:id',
  safeHandler(corporateSupplyController.deleteCorporateSupply, { success: false, message: 'Corporate supply deletion failed' })
);

module.exports = router;
