'use strict';
const {
  Model
} = require('sequelize');
module.exports = (sequelize, DataTypes) => {
  class Message extends Model {
    /**
     * Helper method for defining associations.
     * This method is not a part of Sequelize lifecycle.
     * The `models/index` file will call this method automatically.
     */
    static associate(models) {
      // define association here
    }
  }
  Message.init({
    sender_id: DataTypes.STRING,
    receiver_id: DataTypes.STRING,
    content: DataTypes.TEXT,
    created_at: DataTypes.DATE
  }, {
    sequelize,
    modelName: 'Message',
    tableName: 'messages',
    underscored: true,
    timestamps: false
  });
  return Message;
};