import { Sequelize } from 'sequelize';

export const sequelize = new Sequelize({
  host: 'localhost',
  database: 'doa_orders',
  username: 'postgres',
  password: 'postgres',
  dialect: 'postgres',
  logging: false,
});

