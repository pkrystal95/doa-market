import User from '../models/user.model';
import { AppError } from '../utils/app-error';

export class UserService {
  async getUsers(page = 1, limit = 20, filters?: any) {
    const offset = (page - 1) * limit;
    const where: any = {};
    
    if (filters?.status) where.status = filters.status;
    if (filters?.role) where.role = filters.role;

    const { count, rows } = await User.findAndCountAll({
      where,
      limit,
      offset,
      order: [['createdAt', 'DESC']],
    });

    return {
      users: rows,
      meta: {
        page,
        limit,
        total: count,
        totalPages: Math.ceil(count / limit),
      },
    };
  }

  async getUserById(id: string) {
    const user = await User.findByPk(id);
    if (!user) throw new AppError('User not found', 404);
    return user;
  }

  async updateUser(id: string, data: Partial<User>) {
    const user = await this.getUserById(id);
    await user.update(data);
    return user;
  }

  async deleteUser(id: string) {
    const user = await this.getUserById(id);
    await user.update({ status: 'deleted' });
  }
}

export default new UserService();

