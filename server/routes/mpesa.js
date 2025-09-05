const express = require('express');
const axios = require('axios');
const auth = require('../middlewares/auth');
const Order = require('../models/order');

const mpesaRouter = express.Router();

// --- M-PESA CONFIGURATION ---
// It's highly recommended to use environment variables for these
const MPESA_CONSUMER_KEY = process.env.MPESA_CONSUMER_KEY || "XT7jbFbpUeG0EzBJoT4yHCd70gnivoeqCAf2Ao4dI7aCJQUW";
const MPESA_CONSUMER_SECRET = process.env.MPESA_CONSUMER_SECRET || "hfuESnzGCAYJJIgjL6JYeUhNt2UASl4S32soGhT2fk2LhmvEt0bGga6QmxACtZXu";
const MPESA_SHORTCODE = process.env.MPESA_SHORTCODE || "174379"; // Use your Till/Paybill Number
const MPESA_PASSKEY = process.env.MPESA_PASSKEY || "bfb279f9aa9bdbcf158e97dd71a467cd2e0c893059b10f78e6b72ada1ed2c919";
const MPESA_ENV = process.env.MPESA_ENV || 'sandbox'; // 'sandbox' or 'production'

// This must be a publicly accessible HTTPS URL. Use a tool like ngrok for local testing.
const MPESA_CALLBACK_URL = process.env.MPESA_CALLBACK_URL || "https://ee75a38f2a40.ngrok-free.app/api/mpesa/callback";

const mpesaAuthUrl = MPESA_ENV === 'sandbox' 
    ? 'https://sandbox.safaricom.co.ke/oauth/v1/generate?grant_type=client_credentials'
    : 'https://api.safaricom.co.ke/oauth/v1/generate?grant_type=client_credentials';

const mpesaStkUrl = MPESA_ENV === 'sandbox'
    ? 'https://sandbox.safaricom.co.ke/mpesa/stkpush/v1/processrequest'
    : 'https://api.safaricom.co.ke/mpesa/stkpush/v1/processrequest';

// Helper to get M-Pesa access token
const getAccessToken = async () => {
    const auth = Buffer.from(`${MPESA_CONSUMER_KEY}:${MPESA_CONSUMER_SECRET}`).toString('base64');
    try {
        const response = await axios.get(mpesaAuthUrl, {
            headers: { 'Authorization': `Basic ${auth}` }
        });
        return response.data.access_token;
    } catch (error) {
        console.error("M-Pesa Auth Error:", error.response ? error.response.data : error.message);
        throw new Error("Could not get M-Pesa access token");
    }
};

// Endpoint to initiate STK Push
mpesaRouter.post('/api/mpesa/stk-push', auth, async (req, res) => {
    const { amount, phoneNumber, orderId } = req.body;

    if (!amount || !phoneNumber || !orderId) {
        return res.status(400).json({ msg: 'Amount, phone number, and orderId are required.' });
    }

    const formattedPhone = phoneNumber.startsWith('0') ? `254${phoneNumber.substring(1)}` : phoneNumber;
    const timestamp = new Date().toISOString().replace(/[-T:.Z]/g, '').slice(0, 14);
    const password = Buffer.from(`${MPESA_SHORTCODE}${MPESA_PASSKEY}${timestamp}`).toString('base64');

    try {
        console.log(`[STK Push] Initiating for Order ID: ${orderId}, Phone: ${formattedPhone}, Amount: ${Math.round(amount)}`);

        const accessToken = await getAccessToken();
        const response = await axios.post(mpesaStkUrl, {
            "BusinessShortCode": MPESA_SHORTCODE,
            "Password": password,
            "Timestamp": timestamp,
            "TransactionType": "CustomerPayBillOnline",
            "Amount": Math.round(amount),
            "PartyA": formattedPhone,
            "PartyB": MPESA_SHORTCODE,
            "PhoneNumber": formattedPhone,
            "CallBackURL": `${MPESA_CALLBACK_URL}/${orderId}`,
            "AccountReference": "Revos",
            "TransactionDesc": `Payment for Order ${orderId}`
        }, {
            headers: { 'Authorization': `Bearer ${accessToken}` }
        });

        console.log('[STK Push] Safaricom Response:', response.data);
        res.json(response.data);

    } catch (error) {
        console.error("STK Push Error:", error.response ? error.response.data : error.message);
        res.status(500).json({ error: 'Failed to initiate M-Pesa payment.' });
    }
});

// M-Pesa Callback endpoint to receive transaction status
mpesaRouter.post('/api/mpesa/callback/:orderId', async (req, res) => {
    const { orderId } = req.params;
    console.log(`\n--- [Callback] Received for Order ID: ${orderId} ---`);
    console.log(JSON.stringify(req.body, null, 2));

    const callbackData = req.body.Body.stkCallback;
    const resultCode = callbackData.ResultCode;

    try {
        let order = await Order.findById(orderId);
        if (!order) {
            console.error(`[Callback] Error: Order with ID ${orderId} not found.`);
            return res.status(404).json({ msg: 'Order not found' });
        }

        if (resultCode === 0) {
            console.log(`[Callback] Payment successful for Order ID: ${orderId}.`);
            order.paymentStatus = 'paid';
            order.paymentDetails = {
                method: 'M-Pesa',
                transactionId: callbackData.CallbackMetadata.Item.find(item => item.Name === 'MpesaReceiptNumber').Value,
                payload: callbackData
            };
        } else {
            console.log(`[Callback] Payment failed for Order ID: ${orderId}. Reason: ${callbackData.ResultDesc}`);
            order.paymentStatus = 'failed';
            order.paymentDetails = { method: 'M-Pesa', payload: callbackData };
        }

        await order.save();
        console.log(`[Callback] Order ${orderId} updated in DB with status: ${order.paymentStatus}`);
        res.json({ "ResultCode": 0, "ResultDesc": "Accepted" });

    } catch (error) {
        console.error(`Error processing M-Pesa callback for order ${orderId}:`, error.message);
        res.status(500).json({ "ResultCode": 1, "ResultDesc": "Failed" });
    }
});

module.exports = mpesaRouter;