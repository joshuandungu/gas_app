const express = require('express');
const router = express.Router();
const messageController = require('../controllers/message.controller');

// Routes
router.post('/', messageController.createMessage);
router.get('/', messageController.getAllMessages);
router.get('/user/:userId', messageController.getMessagesForUser);
router.get('/conversation/:senderId/:receiverId', messageController.getConversation);
router.get('/:id', messageController.getMessageById);
router.put('/:id', messageController.updateMessage);
router.delete('/:id', messageController.deleteMessage);

module.exports = router;