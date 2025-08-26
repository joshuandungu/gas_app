'use strict';
/** @type {import('sequelize-cli').Migration} */
module.exports = {
  async up(queryInterface, Sequelize) {
    await queryInterface.createTable('Posts', {
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
      category: {
        type: Sequelize.STRING
      },
      capacity: {
        type: Sequelize.STRING
      },
      min_order_qty: {
        type: Sequelize.INTEGER
      },
      delivery_fee: {
        type: Sequelize.DECIMAL
      },
      subscription_plan: {
        type: Sequelize.STRING
      },
      corporate_contact: {
        type: Sequelize.STRING
      },
      vendor_phone: {
        type: Sequelize.STRING
      },
      image_url: {
        type: Sequelize.STRING
      },
      created_by: {
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
      firestore_id: {
        type: Sequelize.STRING
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
    await queryInterface.dropTable('Posts');
  }
};