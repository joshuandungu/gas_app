const axios = require('axios');
require('dotenv').config();

const BASES = {
  sandbox: 'https://sandbox.safaricom.co.ke',
  production: 'https://api.safaricom.co.ke',
};

function baseUrl() {
  const env = (process.env.MPESA_ENV || 'sandbox').toLowerCase();
  return BASES[env] || BASES.sandbox;
}

async function getAccessToken() {
  const key = process.env.MPESA_CONSUMER_KEY;
  const secret = process.env.MPESA_CONSUMER_SECRET;
  if (!key || !secret) throw new Error('Missing consumer key/secret');

  const auth = Buffer.from(`${key}:${secret}`).toString('base64');

  const url = `${baseUrl()}/oauth/v1/generate?grant_type=client_credentials`;
  const res = await axios.get(url, {
    headers: { Authorization: `Basic ${auth}` },
    timeout: 15000,
  });
  return res.data.access_token;
}

module.exports = { getAccessToken, baseUrl };
