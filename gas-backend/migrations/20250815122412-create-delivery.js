'use strict';
/** @type {import('sequelize-cli').Migration} */
module.exports = {
  async up(queryInterface, Sequelize) {
    await queryInterface.createTable('deliveries', {
      id: {
        allowNull: false,
        autoIncrement: true,
        primaryKey: true,
        type: Sequelize.INTEGER
      },
      order_id: {
        type: Sequelize.INTEGER
      },
      driver_name: {
        type: Sequelize.STRING
      },
      driver_phone: {
        type: Sequelize.STRING
      },
      vehicle_number: {
        type: Sequelize.STRING
      },
      status: {
        type: Sequelize.STRING
      },
      estimated_time: {
        type: Sequelize.DATE
      },
      delivered_at: {
        type: Sequelize.DATE
      },
      createdAt: {
        allowNull: false,
        type: Sequelize.DATE
      },
      updatedAt: {
        allowNull: false,
        type: Sequelize.DATE
      }
    }, {
      underscored: true,
    });
  },
  async down(queryInterface, Sequelize) {
    await queryInterface.dropTable('Deliveries');
  }
};