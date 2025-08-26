'use strict';
const {
  Model
} = require('sequelize');
module.exports = (sequelize, DataTypes) => {
  class Delivery extends Model {
    /**
     * Helper method for defining associations.
     * This method is not a part of Sequelize lifecycle.
     * The `models/index` file will call this method automatically.
     */
    static associate(models) {
      // define association here
    }
  }
  Delivery.init({
    order_id: DataTypes.INTEGER,
    driver_name: DataTypes.STRING,
    driver_phone: DataTypes.STRING,
    vehicle_number: DataTypes.STRING,
    status: DataTypes.STRING,
    estimated_time: DataTypes.DATE,
    delivered_at: DataTypes.DATE
  }, {
    sequelize,
    modelName: 'Delivery',
    tableName: 'deliveries',
    underscored: true,
    timestamps: false
  });
  return Delivery;
};