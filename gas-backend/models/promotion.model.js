'use strict';
const { Model } = require('sequelize');

module.exports = (sequelize, DataTypes) => {
  class Promotion extends Model {
    static associate(models) {
      // define association here
    }
  }

  Promotion.init({
    title: {
      type: DataTypes.STRING(150),
      allowNull: false,
    },
    description: {
      type: DataTypes.TEXT,
    },
    percentage: {
      type: DataTypes.INTEGER,
      allowNull: false,
      validate: {
        min: 0,
        max: 100,
      }
    },
    is_active: {
      type: DataTypes.BOOLEAN,
      defaultValue: false,
    },
    start_date: {
      type: DataTypes.DATE,
    },
    end_date: {
      type: DataTypes.DATE,
    },
    created_at: {
      type: DataTypes.DATE,
      defaultValue: DataTypes.NOW,
    }
  }, {
    sequelize,
    modelName: 'Promotion',
    tableName: 'promotions',
    timestamps: false
  });

  return Promotion;
};
