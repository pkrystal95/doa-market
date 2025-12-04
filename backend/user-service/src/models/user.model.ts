import { DataTypes, Model } from 'sequelize';
import { sequelize } from '../config/database';

class User extends Model {
  public id!: string;
  public email!: string;
  public name!: string;
  public phone?: string;
  public profileImage?: string;
  public role!: string;
  public grade!: string;
  public status!: string;
  public readonly createdAt!: Date;
  public readonly updatedAt!: Date;
}

User.init(
  {
    id: { type: DataTypes.UUID, primaryKey: true },
    email: { type: DataTypes.STRING(255), allowNull: false, unique: true },
    name: { type: DataTypes.STRING(100), allowNull: false },
    phone: { type: DataTypes.STRING(20) },
    profileImage: { type: DataTypes.TEXT },
    role: { type: DataTypes.ENUM('admin', 'seller', 'user'), defaultValue: 'user' },
    grade: { type: DataTypes.ENUM('bronze', 'silver', 'gold', 'vip'), defaultValue: 'bronze' },
    status: { type: DataTypes.ENUM('active', 'suspended', 'deleted'), defaultValue: 'active' },
  },
  { sequelize, tableName: 'users', timestamps: true }
);

export default User;

