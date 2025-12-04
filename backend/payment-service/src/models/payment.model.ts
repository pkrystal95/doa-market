import { DataTypes, Model } from 'sequelize';
import { sequelize } from '../config/database';

class Payment extends Model {
  public id!: string;
  public orderId!: string;
  public amount!: number;
  public method!: string;
  public status!: string;
  public pgTransactionId?: string;
  public paidAt?: Date;
}

Payment.init(
  {
    id: { type: DataTypes.UUID, defaultValue: DataTypes.UUIDV4, primaryKey: true },
    orderId: { type: DataTypes.UUID, allowNull: false },
    amount: { type: DataTypes.DECIMAL(10, 2), allowNull: false },
    method: { type: DataTypes.ENUM('card', 'transfer', 'virtual_account', 'mobile'), allowNull: false },
    status: { type: DataTypes.ENUM('pending', 'completed', 'failed', 'refunded'), defaultValue: 'pending' },
    pgTransactionId: { type: DataTypes.STRING(255) },
    paidAt: { type: DataTypes.DATE },
  },
  { sequelize, tableName: 'payments' }
);

export default Payment;

