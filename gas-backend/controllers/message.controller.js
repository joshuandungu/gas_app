const { Message } = require('../models');
const { Op } = require('sequelize');

exports.createMessage = async (req, res) => {
  try {
    const message = await Message.create(req.body);
    res.status(201).json(message);
  } catch (error) {
    console.error('Error creating message:', error);
    res.status(500).json({ error: 'Failed to create message' });
  }
};

exports.getAllMessages = async (req, res) => {
  try {
    const messages = await Message.findAll();
    res.status(200).json(messages);
  } catch (error) {
    console.error('Error fetching messages:', error);
    res.status(500).json({ error: 'Failed to fetch messages' });
  }
};

exports.getMessagesForUser = async (req, res) => {
  const { userId } = req.params;
  try {
    const messages = await Message.findAll({
      where: {
        [Op.or]: [
          { sender_id: userId },
          { receiver_id: userId }
        ]
      },
      order: [['created_at', 'ASC']]
    });
    res.status(200).json(messages);
  } catch (error) {
    console.error('Error fetching messages for user:', error);
    res.status(500).json({ error: 'Failed to fetch messages for user' });
  }
};

exports.getConversation = async (req, res) => {
  const { senderId, receiverId } = req.params;
  try {
    const messages = await Message.findAll({
      where: {
        [Op.or]: [
          { sender_id: senderId, receiver_id: receiverId },
          { sender_id: receiverId, receiver_id: senderId }
        ]
      },
      order: [['created_at', 'ASC']]
    });
    res.status(200).json(messages);
  } catch (error) {
    console.error('Error fetching conversation:', error);
    res.status(500).json({ error: 'Failed to fetch conversation' });
  }
};

exports.getMessageById = async (req, res) => {
  try {
    const message = await Message.findByPk(req.params.id);
    if (!message) {
      return res.status(404).json({ error: 'Message not found' });
    }
    res.status(200).json(message);
  } catch (error) {
    console.error('Error fetching message:', error);
    res.status(500).json({ error: 'Failed to fetch message' });
  }
};

exports.updateMessage = async (req, res) => {
  try {
    const [updated] = await Message.update(req.body, {
      where: { id: req.params.id }
    });
    if (!updated) {
      return res.status(404).json({ error: 'Message not found' });
    }
    res.status(200).json({ message: 'Message updated successfully' });
  } catch (error) {
    console.error('Error updating message:', error);
    res.status(500).json({ error: 'Failed to update message' });
  }
};

exports.deleteMessage = async (req, res) => {
  try {
    const deleted = await Message.destroy({
      where: { id: req.params.id }
    });
    if (!deleted) {
      return res.status(404).json({ error: 'Message not found' });
    }
    res.status(200).json({ message: 'Message deleted successfully' });
  } catch (error) {
    console.error('Error deleting message:', error);
    res.status(500).json({ error: 'Failed to delete message' });
  }
};