import { Sequelize } from 'sequelize';

export const sequelize = new Sequelize({
  host: process.env.DB_HOST || 'localhost',
  database: 'doa_payments',
  username: 'postgres',
  password: 'postgres',
  dialect: 'postgres',
  logging: false,
});

