const express = require('express');
const router = express.Router();
const notificationController = require('../controllers/notification.controller');

// Create a new notification
router.post('/', notificationController.createNotification);

// Get user's notifications
router.get('/:user_id', notificationController.getUserNotifications);

// Mark notification as read
router.put('/:notificationId/read', notificationController.markNotificationAsRead);

// Delete a notification
router.delete('/:notificationId', notificationController.deleteNotification);

// Clear all user's notifications
router.delete('/user/:user_id', notificationController.clearUserNotifications);

module.exports = router;