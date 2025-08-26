'use strict';
const {
  Model
} = require('sequelize');
module.exports = (sequelize, DataTypes) => {
  class DynamicPost extends Model {
    /**
     * Helper method for defining associations.
     * This method is not a part of Sequelize lifecycle.
     * The `models/index` file will call this method automatically.
     */
    static associate(models) {
      // define association here
    }
  }
  DynamicPost.init({
    title: DataTypes.STRING,
    category: DataTypes.STRING,
    image_url: DataTypes.STRING,
    dynamic_data: DataTypes.JSONB
  }, {
    sequelize,
    modelName: 'DynamicPost',
    tableName: 'dynamic_posts',
    underscored: true,
  });
  return DynamicPost;
};