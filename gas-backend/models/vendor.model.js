'use strict';
const { Model } = require('sequelize');

module.exports = (sequelize, DataTypes) => {
  class Vendor extends Model {
    static associate(models) {
      // define association here
    }
  }

  Vendor.init({
    name: {
      type: DataTypes.STRING(150),
      allowNull: false,
    },
    image_url: {
      type: DataTypes.TEXT,
    },
    location: {
      type: DataTypes.STRING(150),
    },
    price: {
      type: DataTypes.DECIMAL(10,2), // base price
    },
    stock: {
      type: DataTypes.INTEGER,
      defaultValue: 0,
    },
    phone: {
      type: DataTypes.STRING(20),
    },
    created_at: {
      type: DataTypes.DATE,
      defaultValue: DataTypes.NOW,
    }
  }, {
    sequelize,
    modelName: 'Vendor',
    tableName: 'vendors',
    timestamps: false
  });

  return Vendor;
};
