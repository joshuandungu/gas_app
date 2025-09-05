


const express = require("express");
const { Product } = require("../models/product");
const admin = require("../middlewares/admin");
const Order = require("../models/order");
const SellerRequest = require("../models/sellerRequest");
const bcryptjs = require('bcryptjs');
const adminRouter = express.Router();
const User = require("../models/user");

// DEV ONLY: Create admin user
adminRouter.post('/admin/create-admin', async (req, res) => {
    try {
        const { name, email, password } = req.body;
        const existingUser = await User.findOne({ email });
        if (existingUser) {
            return res.status(400).json({ msg: 'Email address already exists' });
        }
        if (!password || password.length < 6) {
            return res.status(400).json({ msg: 'Password must be at least 6 characters' });
        }
        const hashedPassword = await bcryptjs.hash(password, 8);
        let user = new User({
            name,
            email,
            password: hashedPassword,
            type: 'admin',
        });
        user = await user.save();
        res.json({ msg: 'Admin created', user });
    } catch (e) {
        res.status(500).json({ error: e.message });
    }
});

// admin login route can be added here if needed
// admin login route can be added here if needed
adminRouter.post('/admin/login', async (req, res) => {
    try {
        const { email, password } = req.body;
        const user = await User.findOne({ email });
        if (!user || user.type !== 'admin') {
            return res.status(400).json({ msg: 'Invalid credentials' });
        }
        const isMatch = await bcryptjs.compare(password, user.password);
        if (!isMatch) {
            return res.status(400).json({ msg: 'Invalid credentials' });
        }
        // Generate a token or session here if needed
        res.json({ msg: 'Admin logged in', user });
    } catch (e) {
        res.status(500).json({ error: e.message });
    }
});
// Admin adds a new product
adminRouter.post("/admin/add-product", admin, async (req, res) => {
    try {
        const { name, description, images, quantity, price, category } = req.body;
        let product = new Product({
            name,
            description,
            images,
            quantity,
            price,
            category,
        });
        product = await product.save();
        res.json(product);
    } catch (e) {
        res.status(500).json({ error: e.message });
    }
});

// Admin gets all products
adminRouter.get("/admin/products", admin, async (req, res) => {
    try {
        const products = await Product.find({});
        res.json(products);
    } catch (e) {
        res.status(500).json({ error: e.message });
    }
});

// Admin deletes a product
adminRouter.delete("/admin/product/:id", admin, async (req, res) => {
    try {
        const { id } = req.params;
        let product = await Product.findById(id);
        if (!product) {
            return res.status(404).json({ msg: "Product not found" });
        }
        product = await Product.findByIdAndDelete(id);
        res.json(product);
    } catch (e) {
        res.status(500).json({ error: e.message });
    }
});



// Admin gets all pending seller requests
adminRouter.get("/admin/seller-requests", admin, async (req, res) => {
    try {
        const requests = await SellerRequest.find({ status: "pending" })
            .populate("userId", "name email") // Lấy thêm name và email từ user
            .lean();
        res.json(requests);
    } catch (e) {
        res.status(500).json({ error: e.message });
    }
});

// Admin approves or rejects seller request
adminRouter.post("/admin/process-seller-request", admin, async (req, res) => {
    try {
        const { requestId, status } = req.body;
        const request = await SellerRequest.findById(requestId);

        if (!request) {
            return res.status(404).json({ msg: "Request not found" });
        }

        request.status = status;
        await request.save();

        if (status === "approved") {
            await User.findByIdAndUpdate(request.userId, {
                type: "seller",
                shopName: request.shopName,
                shopDescription: request.shopDescription,
                address: request.address,
                shopAvatar: request.avatarUrl,
            });
        }

        res.json({ msg: `Seller request ${status}` });
    } catch (e) {
        res.status(500).json({ error: e.message });
    }
});

// Get all sellers
adminRouter.get("/admin/sellers", admin, async (req, res) => {
    try {
        const sellers = await User.find({ type: "seller" });
        res.json(sellers);
    } catch (e) {
        res.status(500).json({ error: e.message });
    }
});

// Disable seller account
adminRouter.post("/admin/disable-seller", admin, async (req, res) => {
    try {
        const { sellerId } = req.body;
        const seller = await User.findById(sellerId);

        if (!seller || seller.type !== "seller") {
            return res.status(404).json({ msg: "Seller not found" });
        }

        seller.type = "user";
        await seller.save();
        res.json({ msg: "Seller account disabled successfully" });
    } catch (e) {
        res.status(500).json({ error: e.message });
    }
});

// Get seller statistics
adminRouter.get("/admin/seller-stats", admin, async (req, res) => {
    try {
        const totalSellers = await User.countDocuments({ type: "seller" });
        const pendingRequests = await SellerRequest.countDocuments({
            status: "pending",
        });

        res.json({
            totalSellers,
            pendingRequests,
        });
    } catch (e) {
        res.status(500).json({ error: e.message });
    }
});

// Get best sellers statistics
adminRouter.get("/admin/best-sellers", admin, async (req, res) => {
    try {
        const { month, year, category } = req.query;

        // Tạo điều kiện filter theo tháng và năm
        const startDate = new Date(year, month - 1, 1);
        const endDate = new Date(year, month, 0);

        // Base query để lấy các đơn hàng đã delivered
        let matchQuery = {
            status: 3,
            orderedAt: {
                $gte: startDate.getTime(),
                $lte: endDate.getTime(),
            },
        };

        // Thêm điều kiện category nếu có
        const categoryMatch = category
            ? { "products.product.category": category }
            : {};

        const sellers = await Order.aggregate([
            { $match: matchQuery },
            { $unwind: "$products" },
            {
                $lookup: {
                    from: "users",
                    localField: "products.product.sellerId",
                    foreignField: "_id",
                    as: "seller",
                },
            },
            { $unwind: "$seller" },
            { $match: categoryMatch },
            {
                $group: {
                    _id: "$seller._id",
                    shopName: { $first: "$seller.shopName" },
                    shopAvatar: { $first: "$seller.shopAvatar" },
                    totalRevenue: {
                        $sum: {
                            $multiply: ["$products.quantity", "$products.product.price"],
                        },
                    },
                    totalOrders: { $sum: 1 },
                    totalProducts: {
                        $sum: "$products.quantity",
                    },
                },
            },
            { $sort: { totalRevenue: -1 } },
        ]);

        res.json(sellers);
    } catch (e) {
        res.status(500).json({ error: e.message });
    }
});

module.exports = adminRouter;
