const express = require('express');
const chatRouter = express.Router();
const auth = require('../middlewares/auth'); // Assuming you have this middleware
const ChatRoom = require('../models/chatRoom');
const Message = require('../models/message');
const User = require('../models/user');

// POST /api/chat/get-or-create
// Body: { receiverId: '...' }
// Finds or creates a chat room between the current user and a receiver (vendor).
chatRouter.post('/api/chat/get-or-create', auth, async (req, res) => {
    try {
        const { receiverId } = req.body;
        const senderId = req.user; // from auth middleware

        if (!receiverId) {
            return res.status(400).json({ msg: 'Receiver ID is required.' });
        }

        // Find a chat room that has exactly these two participants
        let chatRoom = await ChatRoom.findOne({
            participants: { $all: [senderId, receiverId], $size: 2 }
        });

        if (!chatRoom) {
            // If no chat room exists, create a new one
            chatRoom = new ChatRoom({
                participants: [senderId, receiverId],
            });
            await chatRoom.save();
        }

        // Populate participant details before sending back
        await chatRoom.populate({
            path: 'participants',
            select: 'name shopName type shopAvatar' // select fields you need
        });

        res.json(chatRoom);

    } catch (e) {
        res.status(500).json({ error: e.message });
    }
});

// GET /api/chat/my-chats
// Fetches all chat rooms for the currently logged-in user.
chatRouter.get('/api/chat/my-chats', auth, async (req, res) => {
    try {
        const chatRooms = await ChatRoom.find({ participants: req.user })
            .populate({
                path: 'participants',
                select: 'name shopName type shopAvatar'
            })
            .sort({ lastMessageAt: -1 }); // Show most recent chats first

        res.json(chatRooms);
    } catch (e) {
        res.status(500).json({ error: e.message });
    }
});


// GET /api/chat/messages/:chatRoomId
// Fetches all messages for a given chat room.
chatRouter.get('/api/chat/messages/:chatRoomId', auth, async (req, res) => {
    try {
        const messages = await Message.find({ chatRoomId: req.params.chatRoomId })
            .sort({ createdAt: 'asc' }); // Oldest messages first

        res.json(messages);
    } catch (e) {
        res.status(500).json({ error: e.message });
    }
});


module.exports = chatRouter;