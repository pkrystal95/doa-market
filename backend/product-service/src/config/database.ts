import { Sequelize } from 'sequelize';

export const sequelize = new Sequelize({
  host: process.env.DB_HOST || 'localhost',
  port: 5432,
  database: 'doa_products',
  username: 'postgres',
  password: 'postgres',
  dialect: 'postgres',
  logging: false,
});

