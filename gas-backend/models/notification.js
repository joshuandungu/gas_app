'use strict';
const {
  Model
} = require('sequelize');
module.exports = (sequelize, DataTypes) => {
  class Notification extends Model {
    /**
     * Helper method for defining associations.
     * This method is not a part of Sequelize lifecycle.
     * The `models/index` file will call this method automatically.
     */
    static associate(models) {
      // define association here
    }
  }
  Notification.init({
    user_id: DataTypes.STRING,
    title: DataTypes.STRING,
    body: DataTypes.TEXT,
    is_read: DataTypes.BOOLEAN,
    created_at: DataTypes.DATE
  }, {
    sequelize,
    modelName: 'Notification',
    tableName: 'notifications',
    underscored: true,
    timestamps: false
  });
  return Notification;
};