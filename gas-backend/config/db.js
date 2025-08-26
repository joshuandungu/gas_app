const { Sequelize } = require('sequelize');
require('dotenv').config();

const sequelize = new Sequelize(
  process.env.DB_NAME,       // Database name
  process.env.DB_USER,       // Username
  process.env.DB_PASSWORD,   // Password
  {
    host: process.env.DB_HOST,
    port: process.env.DB_PORT,
    dialect: 'postgres',
    logging: false,          // Disable SQL query logs (set to true if you want logs)
  }
);

module.exports = sequelize;
