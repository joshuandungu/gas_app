const express = require('express');
const router = express.Router();
const ctrl = require('../controllers/mpesa.controller');

// health check
router.get('/health', (req, res) => res.json({ status: 'ok' }));

// initiate STK push
router.post('/stkpush', ctrl.stkPush);

// Daraja callback URL (must be publicly reachable)
router.post('/callback', ctrl.mpesaCallback);

module.exports = router;
