module.exports = (sequelize, DataTypes) => {
  const Order = sequelize.define('Order', {
    id: {
      type: DataTypes.INTEGER,
      autoIncrement: true,
      primaryKey: true,
    },
    user_id: {
      type: DataTypes.STRING(100), // Firebase UID
      allowNull: false,
    },
    vendor_id: {
      type: DataTypes.INTEGER,
      references: {
        model: 'vendors',
        key: 'id',
      },
      onDelete: 'SET NULL'
    },
    total_amount: {
      type: DataTypes.DECIMAL(10,2),
      allowNull: false,
    },
    status: {
      type: DataTypes.STRING(50),
      defaultValue: 'pending',
    },
    payment_status: {
      type: DataTypes.STRING(50),
      defaultValue: 'pending',
    },
    created_at: {
      type: DataTypes.DATE,
      defaultValue: DataTypes.NOW,
    }
  }, {
    tableName: 'orders',
    timestamps: false
  });

  Order.associate = (models) => {
    Order.hasMany(models.OrderItem, { foreignKey: 'order_id' });
    Order.belongsTo(models.Vendor, { foreignKey: 'vendor_id' });
  };

  return Order;
};