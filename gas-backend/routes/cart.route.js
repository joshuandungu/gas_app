const express = require('express');
const router = express.Router();
const cartController = require('../controllers/cart.controller');

// Add item to cart
router.post('/', cartController.addItemToCart);

// Get user's cart
router.get('/:user_id', cartController.getUserCart);

// Update item quantity in cart
router.put('/:user_id/:product_id', cartController.updateCartItemQuantity);

// Remove item from cart
router.delete('/:user_id/:product_id', cartController.removeCartItem);

// Clear user's cart
router.delete('/:user_id', cartController.clearUserCart);

module.exports = router;