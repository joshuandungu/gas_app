'use strict';
/** @type {import('sequelize-cli').Migration} */
module.exports = {
  async up(queryInterface, Sequelize) {
    await queryInterface.createTable('CylinderExchanges', {
      id: {
        allowNull: false,
        autoIncrement: true,
        primaryKey: true,
        type: Sequelize.INTEGER
      },
      title: {
        type: Sequelize.STRING
      },
      description: {
        type: Sequelize.TEXT
      },
      price: {
        type: Sequelize.DECIMAL
      },
      location: {
        type: Sequelize.STRING
      },
      capacity: {
        type: Sequelize.STRING
      },
      vendor_shop_name: {
        type: Sequelize.STRING
      },
      vendor_phone: {
        type: Sequelize.STRING
      },
      image_url: {
        type: Sequelize.STRING
      },
      promo_percentage: {
        type: Sequelize.INTEGER
      },
      promo_description: {
        type: Sequelize.TEXT
      },
      promo_end_date: {
        type: Sequelize.DATE
      },
      promo_is_active: {
        type: Sequelize.BOOLEAN
      },
      createdAt: {
        allowNull: false,
        type: Sequelize.DATE
      },
      updatedAt: {
        allowNull: false,
        type: Sequelize.DATE
      }
    });
  },
  async down(queryInterface, Sequelize) {
    await queryInterface.dropTable('CylinderExchanges');
  }
};