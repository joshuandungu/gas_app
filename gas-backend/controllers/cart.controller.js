const pool = require('../config/db');

// Add item to cart
exports.addItemToCart = async (req, res) => {
    const { user_id, product_id, quantity } = req.body;
    try {
        const result = await pool.query(
            'INSERT INTO cart (user_id, product_id, quantity) VALUES ($1, $2, $3) RETURNING *',
            [user_id, product_id, quantity]
        );
        res.status(201).json(result.rows[0]);
    } catch (err) {
        console.error("Error adding item to cart:", err);
        res.status(500).json({ error: err.message });
    }
};

// Get user's cart
exports.getUserCart = async (req, res) => {
    const { user_id } = req.params;
    try {
        const result = await pool.query('SELECT * FROM cart WHERE user_id = $1', [user_id]);
        res.status(200).json(result.rows);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
};

// Update item quantity in cart
exports.updateCartItemQuantity = async (req, res) => {
    const { user_id, product_id } = req.params;
    const { quantity } = req.body;
    try {
        const result = await pool.query(
            'UPDATE cart SET quantity = $1 WHERE user_id = $2 AND product_id = $3 RETURNING *',
            [quantity, user_id, product_id]
        );
        res.status(200).json(result.rows[0]);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
};

// Remove item from cart
exports.removeCartItem = async (req, res) => {
    const { user_id, product_id } = req.params;
    try {
        await pool.query('DELETE FROM cart WHERE user_id = $1 AND product_id = $2', [user_id, product_id]);
        res.status(204).send(); // No content to send back
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
};

// Clear user's cart
exports.clearUserCart = async (req, res) => {
    const { user_id } = req.params;
    try {
        await pool.query('DELETE FROM cart WHERE user_id = $1', [user_id]);
        res.status(204).send(); // No content to send back
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
};