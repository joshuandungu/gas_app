const axios = require('axios');
require('dotenv').config();
const { getAccessToken, baseUrl } = require('../config/mpesa.config');

// Utilities
const nowTimestamp = () => {
  const d = new Date();
  const pad = (n) => String(n).padStart(2, '0');
  return `${d.getFullYear()}${pad(d.getMonth() + 1)}${pad(d.getDate())}${pad(d.getHours())}${pad(d.getMinutes())}${pad(d.getSeconds())}`;
};

const normalizeMsisdn = (raw) => {
  if (!raw) return '';
  let p = String(raw).replace(/\s/g, '');
  if (p.startsWith('+')) p = p.slice(1);
  if (p.startsWith('07') && p.length === 10) return '254' + p.slice(1); // 07XXXXXXXX -> 2547XXXXXXXX
  if (p.startsWith('254') && p.length === 12) return p;
  if (p.startsWith('7') && p.length === 9) return '254' + p; // 7XXXXXXXX
  return p; // fallback (Daraja will validate)
};

exports.stkPush = async (req, res) => {
  try {
    const { phone, amount } = req.body || {};
    if (!phone || !amount) {
      return res.status(400).json({ message: 'Phone and amount are required' });
    }

    const amt = Number(amount);
    if (!Number.isFinite(amt) || amt < 1) {
      return res.status(400).json({ message: 'Amount must be >= 1' });
    }

    const shortcode = process.env.MPESA_SHORTCODE;
    const passkey = process.env.MPESA_PASSKEY;
    const callbackURL = process.env.MPESA_CALLBACK_URL;

    if (!shortcode || !passkey || !callbackURL) {
      return res.status(500).json({ message: 'M-Pesa env vars missing (SHORTCODE / PASSKEY / CALLBACK)' });
    }

    const msisdn = normalizeMsisdn(phone);
    const timestamp = nowTimestamp();
    const password = Buffer.from(`${shortcode}${passkey}${timestamp}`).toString('base64');

    const token = await getAccessToken();

    const payload = {
      BusinessShortCode: shortcode,
      Password: password,
      Timestamp: timestamp,
      TransactionType: 'CustomerPayBillOnline',
      Amount: amt,
      PartyA: msisdn,
      PartyB: shortcode,
      PhoneNumber: msisdn,
      CallBackURL: callbackURL,
      AccountReference: 'GasPayment',
      TransactionDesc: 'Payment for gas',
    };

    const url = `${baseUrl()}/mpesa/stkpush/v1/processrequest`;
    const darajaRes = await axios.post(url, payload, {
      headers: { Authorization: `Bearer ${token}` },
      timeout: 20000,
    });

    return res.status(200).json({
      message: 'STK Push initiated',
      data: darajaRes.data,
    });
  } catch (err) {
    const details = err.response?.data || { errorMessage: err.message };
    console.error('STK Push error:', details);
    return res.status(500).json({ message: 'STK Push failed', error: details });
  }
};

exports.mpesaCallback = async (req, res) => {
  try {
    // Safaricom sends JSON body here
    console.log('--- M-Pesa Callback ---');
    console.log(JSON.stringify(req.body, null, 2));

    // TODO: Persist to DB if you want (success/failure, amount, receipt, phone, etc.)

    // Always respond 200 to acknowledge receipt
    return res.json({ ResultCode: 0, ResultDesc: 'Callback received successfully' });
  } catch (err) {
    console.error('Callback processing error:', err.message);
    // Still return 200 so Daraja does not retry forever
    return res.json({ ResultCode: 0, ResultDesc: 'Callback received (logged with errors)' });
  }
};
