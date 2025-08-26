const express = require('express');
const cors = require('cors');
require('dotenv').config();
const path = require('path');
const fs = require('fs');

const { DataTypes } = require('sequelize');
const sequelize = require('./config/db');
const app = express();

const upload = require('./config/multerConfig');

// Middleware
app.use(cors());
app.use(express.json());

// Sequelize models
const Order = require('./models/order.model')(sequelize, DataTypes);
const OrderItem = require('./models/orderItem.model')(sequelize, DataTypes);



// Database connection
sequelize.authenticate()
  .then(() => {
    console.log('✅ Connected to PostgreSQL...');
    console.log('Database:', process.env.DB_NAME || 'gas_app');
  })
  .catch(err => {
    console.error('❌ Database connection error:', err);
  });

// Serve static files (uploads)
const uploadsDir = path.join(__dirname, 'uploads');
if (!fs.existsSync(uploadsDir)) {
  fs.mkdirSync(uploadsDir, { recursive: true });
}
app.use('/uploads', express.static(uploadsDir));



// Import routes
const categoryRoutes = require('./routes/category.routes');
const productRoutes = require('./routes/product.routes');
const promotionRoutes = require('./routes/promotion.routes');
const orderRoutes = require('./routes/order.routes');
const orderItemRoutes = require('./routes/orderItem.routes');
const mpesaRoutes = require('./routes/mpesa.routes');
const bulkGasRoutes = require('./routes/bulkGas.routes.js');
const corporateSupplyRoutes = require('./routes/corporateSupply.routes.js');
const cylinderDeliveryRoutes = require('./routes/cylinderDelivery.routes.js');
const cylinderExchangeRoutes = require('./routes/cylinderExchange.routes.js');
const gasProductRoutes = require('./routes/gasProduct.routes.js');
const subscriptionRoutes = require('./routes/subscription.routes.js');
const vendorRoutes = require('./routes/vendor.routes.js');
const deliveryRoutes = require('./routes/delivery.routes.js');
const messageRoutes = require('./routes/message.routes.js');
const paymentRoutes = require('./routes/payment.routes.js');
const reviewRoutes = require('./routes/review.routes.js');
const notificationRoutes = require('./routes/notification.routes.js');
const cartRoutes = require('./routes/cart.route');


// Use routes
app.use('/api/categories', categoryRoutes);
app.use('/api/products', productRoutes);
app.use('/api/promotions', promotionRoutes);
app.use('/api/orders', orderRoutes);
app.use('/api/order-items', orderItemRoutes);
app.use('/api/mpesa', mpesaRoutes);
app.use('/api/bulk-gas', bulkGasRoutes);
app.use('/api/corporate-supply', corporateSupplyRoutes);
app.use('/api/cylinder-delivery', cylinderDeliveryRoutes);
app.use('/api/cylinder-exchange', cylinderExchangeRoutes);
app.use('/api/gas-products', gasProductRoutes);
app.use('/api/subscriptions', subscriptionRoutes);
app.use('/api/vendors', vendorRoutes);
app.use('/api/deliveries', deliveryRoutes);
app.use('/api/messages', messageRoutes);
app.use('/api/payments', paymentRoutes);
app.use('/api/reviews', reviewRoutes);
app.use('/api/notifications', notificationRoutes);
app.use('/api/cart', cartRoutes);
app.use('/api/notifications', notificationRoutes);

// Health check
app.get('/api/health', (req, res) => {
  res.json({ status: 'OK', timestamp: new Date() });
});

// Global error handler
app.use((err, req, res, next) => {
  console.error(err.stack);

  if (err instanceof multer.MulterError) {
    return res.status(400).json({ success: false, message: 'File upload error', error: err.message });
  }

  res.status(500).json({ success: false, message: 'Something went wrong!', error: err.message });
});

// Start server
const PORT = process.env.PORT || 5000;
app.listen(PORT, () => {
  console.log(`🚀 Server running on port ${PORT}`);
  console.log(`📂 Uploads directory: ${uploadsDir}`);
});