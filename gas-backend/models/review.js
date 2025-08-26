'use strict';
const {
  Model
} = require('sequelize');
module.exports = (sequelize, DataTypes) => {
  class Review extends Model {
    /**
     * Helper method for defining associations.
     * This method is not a part of Sequelize lifecycle.
     * The `models/index` file will call this method automatically.
     */
    static associate(models) {
      // define association here
    }
  }
  Review.init({
    product_id: DataTypes.INTEGER,
    user_id: DataTypes.STRING,
    rating: DataTypes.INTEGER,
    comment: DataTypes.TEXT,
    created_at: DataTypes.DATE
  }, {
    sequelize,
    modelName: 'Review',
    tableName: 'reviews',
    underscored: true,
    timestamps: false
  });
  return Review;
};