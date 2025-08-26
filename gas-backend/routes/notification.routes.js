const express = require('express');
const router = express.Router();
const notificationController = require('../controllers/notification.controller');

// Routes
router.post('/', notificationController.createNotification);
router.get('/', notificationController.getUserNotifications);

router.put('/:notificationId/read', notificationController.markNotificationAsRead);
router.delete('/:notificationId', notificationController.deleteNotification);

module.exports = router;