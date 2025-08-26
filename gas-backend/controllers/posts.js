const { Post } = require('../models');
const { Op } = require('sequelize');
const admin = require('../config/firebase-admin');
const createError = require('http-errors');
const { v4: uuidv4 } = require('uuid');

const bucket = admin.storage().bucket();

class PostController {
  static async createPost(req, res, next) {
    try {
      // Verify Firebase token
      const authHeader = req.headers.authorization;
      if (!authHeader) throw createError.Unauthorized('No authorization token provided');
      
      const token = authHeader.split(' ')[1];
      const decodedToken = await admin.auth().verifyIdToken(token);
      const userId = decodedToken.uid;

      // Handle file upload if exists
      let imageUrl = '';
      if (req.file) {
        const file = req.file;
        const fileName = `posts/${uuidv4()}_${file.originalname}`;
        const fileUpload = bucket.file(fileName);

        await fileUpload.save(file.buffer, {
          metadata: {
            contentType: file.mimetype,
          },
        });

        imageUrl = await fileUpload.getSignedUrl({
          action: 'read',
          expires: '03-09-2491', // Far future date
        });
        imageUrl = imageUrl[0]; // getSignedUrl returns an array
      }

      // Prepare post data
      const postData = {
        title: req.body.title,
        description: req.body.description,
        price: req.body.price,
        location: req.body.location,
        category: req.body.category,
        capacity: req.body.capacity || null,
        min_order_qty: req.body.minOrderQty || null,
        delivery_fee: req.body.deliveryFee || null,
        subscription_plan: req.body.subscriptionPlan || null,
        corporate_contact: req.body.corporateContact || null,
        vendor_shop_name: req.body.vendorShopName || null,
        vendor_phone: req.body.vendorPhone || null,
        image_url: imageUrl || req.body.imageUrl || null,
        created_by: userId,
        promo_percentage: req.body.promoPercentage ? parseInt(req.body.promoPercentage) : null,
        promo_description: req.body.promoDescription || null,
        promo_end_date: req.body.promoEndDate || null,
        promo_is_active: !!req.body.promoPercentage,
        firestore_id: req.body.firestoreId || null,
      };

      // Save to PostgreSQL
      const post = await Post.create(postData);

      res.status(201).json({
        success: true,
        data: post,
      });
    } catch (error) {
      next(error);
    }
  }

  static async getAllPosts(req, res, next) {
    try {
      const posts = await Post.findAll();
      res.json({
        success: true,
        data: posts,
      });
    } catch (error) {
      next(error);
    }
  }

  static async getPostsByUser(req, res, next) {
    try {
      const authHeader = req.headers.authorization;
      if (!authHeader) throw createError.Unauthorized('No authorization token provided');
      
      const token = authHeader.split(' ')[1];
      const decodedToken = await admin.auth().verifyIdToken(token);
      const userId = decodedToken.uid;

      const posts = await Post.findAll({ where: { created_by: userId } });
      res.json({
        success: true,
        data: posts,
      });
    } catch (error) {
      next(error);
    }
  }

  static async getActivePromos(req, res, next) {
    try {
      const posts = await Post.findAll({ 
        where: { 
          promo_is_active: true, 
          promo_end_date: { [Op.gt]: new Date() } 
        } 
      });
      res.json({
        success: true,
        data: posts,
      });
    } catch (error) {
      next(error);
    }
  }

  static async getPostsByCategory(req, res, next) {
    try {
      const category = req.params.category;
      const posts = await Post.findAll({ where: { category: category } });
      res.json({
        success: true,
        data: posts,
      });
    } catch (error) {
      next(error);
    }
  }

  static async getPostById(req, res, next) {
    try {
      const id = req.params.id;
      const post = await Post.findByPk(id);
      
      if (!post) {
        throw createError.NotFound('Post not found');
      }

      res.json({
        success: true,
        data: post,
      });
    } catch (error) {
      next(error);
    }
  }

  static async deletePost(req, res, next) {
    try {
      const authHeader = req.headers.authorization;
      if (!authHeader) throw createError.Unauthorized('No authorization token provided');
      
      const token = authHeader.split(' ')[1];
      const decodedToken = await admin.auth().verifyIdToken(token);
      const userId = decodedToken.uid;

      const id = req.params.id;
      const deleted = await Post.destroy({ where: { id: id, created_by: userId } });

      if (!deleted) {
        throw createError.NotFound('Post not found or not authorized');
      }

      res.json({
        success: true,
        data: {},
      });
    } catch (error) {
      next(error);
    }
  }
}

module.exports = PostController;
