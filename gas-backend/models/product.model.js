'use strict';
const { Model } = require('sequelize');

module.exports = (sequelize, DataTypes) => {
  class Product extends Model {
    static associate(models) {
      Product.belongsTo(models.Vendor, { foreignKey: 'vendor_id' });
      Product.belongsTo(models.Category, { foreignKey: 'category_id' });
    }
  }

  Product.init({
    vendor_id: {
      type: DataTypes.INTEGER,
      references: { model: 'vendors', key: 'id' },
    },
    category_id: {
      type: DataTypes.INTEGER,
      references: { model: 'categories', key: 'id' },
    },
    title: {
      type: DataTypes.STRING(150),
      allowNull: false,
    },
    description: {
      type: DataTypes.TEXT,
    },
    size: {
      type: DataTypes.STRING(50), // e.g., 6kg, 13kg, 50kg
    },
    price: {
      type: DataTypes.DECIMAL(10,2),
      allowNull: false,
    },
    image_url: {
      type: DataTypes.TEXT,
    },
    created_at: {
      type: DataTypes.DATE,
      defaultValue: DataTypes.NOW,
    }
  }, {
    sequelize,
    modelName: 'Product',
    tableName: 'products',
    timestamps: false
  });

  return Product;
};
