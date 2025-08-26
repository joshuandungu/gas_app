const admin = require('firebase-admin');

// Load JSON file directly instead of reading from .env
const serviceAccount = require('../firebase-service-account.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  storageBucket: process.env.FIREBASE_STORAGE_BUCKET, // Keep this in .env
});

module.exports = admin;
