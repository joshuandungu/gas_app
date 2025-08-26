const pool = require('../config/db');

// Create a new notification
exports.createNotification = async (req, res) => {
    const { user_id, title, body } = req.body;
    try {
        const result = await pool.query(
            'INSERT INTO notifications (user_id, title, body, is_read) VALUES ($1, $2, $3, FALSE) RETURNING *',
            [user_id, title, body]
        );
        res.status(201).json(result.rows[0]);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
};

// Get user's notifications
exports.getUserNotifications = async (req, res) => {
    const { user_id } = req.params;
    try {
        const result = await pool.query('SELECT * FROM notifications WHERE user_id = $1 ORDER BY created_at DESC', [user_id]);
        res.status(200).json(result.rows);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
};

// Mark notification as read
exports.markNotificationAsRead = async (req, res) => {
    const { notificationId } = req.params;
    try {
        const result = await pool.query(
            'UPDATE notifications SET is_read = TRUE WHERE id = $1 RETURNING *',
            [notificationId]
        );
        res.status(200).json(result.rows[0]);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
};

// Delete a notification
exports.deleteNotification = async (req, res) => {
    const { notificationId } = req.params;
    try {
        await pool.query('DELETE FROM notifications WHERE id = $1', [notificationId]);
        res.status(204).send(); // No content to send back
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
};

// Clear all user's notifications
exports.clearUserNotifications = async (req, res) => {
    const { user_id } = req.params;
    try {
        await pool.query('DELETE FROM notifications WHERE user_id = $1', [user_id]);
        res.status(204).send(); // No content to send back
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
};