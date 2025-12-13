import { DataTypes, Model } from 'sequelize';
import { sequelize } from '../config/database';
import OrderItem from './order-item.model';

class Order extends Model {
  public id!: string;
  public orderNumber!: string;
  public userId!: string;
  public sellerId!: string;
  public status!: string;
  public totalAmount!: number;
  public paymentStatus!: string;
  public shippingAddress?: any;
}

Order.init(
  {
    id: { type: DataTypes.UUID, defaultValue: DataTypes.UUIDV4, primaryKey: true },
    orderNumber: { type: DataTypes.STRING(50), unique: true },
    userId: { type: DataTypes.UUID, allowNull: false },
    sellerId: { type: DataTypes.UUID, allowNull: false },
    status: {
      type: DataTypes.ENUM('pending', 'confirmed', 'processing', 'shipped', 'delivered', 'cancelled'),
      defaultValue: 'pending',
    },
    totalAmount: { type: DataTypes.DECIMAL(10, 2), allowNull: false },
    paymentStatus: {
      type: DataTypes.ENUM('pending', 'completed', 'failed', 'refunded'),
      defaultValue: 'pending',
    },
    shippingAddress: {
      type: DataTypes.JSONB,
      allowNull: true,
    },
  },
  { sequelize, tableName: 'orders' }
);

// Define associations
Order.hasMany(OrderItem, {
  foreignKey: 'orderId',
  as: 'items',
  onDelete: 'CASCADE',
});

OrderItem.belongsTo(Order, {
  foreignKey: 'orderId',
  as: 'order',
});

export default Order;

