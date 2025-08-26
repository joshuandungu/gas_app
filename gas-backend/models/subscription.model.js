'use strict';
const { Model } = require('sequelize');

module.exports = (sequelize, DataTypes) => {
  class Subscription extends Model {
    static associate(models) {
      // define association here
    }
  }

  Subscription.init({
    title: DataTypes.STRING,
    description: DataTypes.TEXT,
    price: DataTypes.DECIMAL(10, 2),
    location: DataTypes.STRING,
    subscription_plan: DataTypes.STRING,
    vendor_shop_name: DataTypes.STRING,
    vendor_phone: DataTypes.STRING,
    image_url: DataTypes.STRING,
    promo_percentage: DataTypes.INTEGER,
    promo_description: DataTypes.TEXT,
    promo_end_date: DataTypes.DATE,
    promo_is_active: DataTypes.BOOLEAN
  }, {
    sequelize,
    modelName: 'Subscription',
    tableName: 'subscriptions',
    underscored: true,
    timestamps: true, // Assuming created_at and updated_at
    createdAt: 'created_at',
    updatedAt: false, // Assuming no updated_at column based on the INSERT query
  });

  return Subscription;
};
