const express = require('express');
const router = express.Router();
const PostController = require('../controllers/posts');
const auth = require('../middlewares/auth');
const upload = require('../config/multerConfig');

// ✅ Universal safe wrapper
function safeHandler(handler, fallback) {
  return async (req, res) => {
    try {
      await handler(req, res);
    } catch (err) {
      console.error(`Posts route error [${req.method} ${req.originalUrl}]:`, err.message);
      res.status(200).json(fallback);
    }
  };
}

router.get(
  '/',
  safeHandler(PostController.getAllPosts, [])
);

// Create a new post
router.post(
  '/',
  auth,
  upload.single('image'),
  safeHandler(PostController.createPost, { success: false, message: 'Failed to create post' })
);

// Get posts by user
router.get(
  '/user',
  auth,
  safeHandler(PostController.getPostsByUser, [])
);

// Get active promo posts
router.get(
  '/promos',
  safeHandler(PostController.getActivePromos, [])
);

// Get posts by category
router.get(
  '/category/:category',
  safeHandler(PostController.getPostsByCategory, [])
);

// Get single post by ID
router.get(
  '/:id',
  safeHandler(PostController.getPostById, null)
);

// Delete a post
router.delete(
  '/:id',
  auth,
  safeHandler(PostController.deletePost, { success: false, message: 'Failed to delete post' })
);

module.exports = router;
