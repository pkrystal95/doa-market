import User from '../models/user.model';
import RefreshToken from '../models/refresh-token.model';
import { generateAccessToken, generateRefreshToken, verifyRefreshToken, getTokenExpirationDate, TokenPayload } from '../utils/jwt';
import { AppError } from '../utils/app-error';
import { logger } from '../utils/logger';

export interface RegisterDto {
  email: string;
  password: string;
  name: string;
  phone?: string;
  role?: 'user' | 'seller';
}

export interface LoginDto {
  email: string;
  password: string;
}

export class AuthService {
  async register(data: RegisterDto) {
    // Check if user already exists
    const existingUser = await User.findOne({ where: { email: data.email } });
    if (existingUser) {
      throw new AppError('Email already registered', 409);
    }

    // Create user
    const user = await User.create({
      email: data.email,
      password: data.password,
      name: data.name,
      phone: data.phone,
      role: data.role || 'user',
      status: 'active',
      emailVerified: false,
    });

    logger.info(`User registered: ${user.id}`);

    // Generate tokens
    const payload: TokenPayload = {
      userId: user.id,
      email: user.email,
      role: user.role,
    };

    const accessToken = generateAccessToken(payload);
    const refreshToken = generateRefreshToken(payload);

    // Save refresh token
    await RefreshToken.create({
      userId: user.id,
      token: refreshToken,
      expiresAt: getTokenExpirationDate(process.env.JWT_REFRESH_EXPIRES_IN || '7d'),
    });

    return {
      user: user.toJSON(),
      accessToken,
      refreshToken,
    };
  }

  async login(data: LoginDto) {
    // Find user
    const user = await User.findOne({ where: { email: data.email } });
    if (!user) {
      throw new AppError('Invalid credentials', 401);
    }

    // Check status
    if (user.status === 'suspended') {
      throw new AppError('Account suspended', 403);
    }
    if (user.status === 'deleted') {
      throw new AppError('Account deleted', 403);
    }

    // Verify password
    const isPasswordValid = await user.comparePassword(data.password);
    if (!isPasswordValid) {
      throw new AppError('Invalid credentials', 401);
    }

    // Update last login
    user.lastLoginAt = new Date();
    await user.save();

    logger.info(`User logged in: ${user.id}`);

    // Generate tokens
    const payload: TokenPayload = {
      userId: user.id,
      email: user.email,
      role: user.role,
    };

    const accessToken = generateAccessToken(payload);
    const refreshToken = generateRefreshToken(payload);

    // Save refresh token
    await RefreshToken.create({
      userId: user.id,
      token: refreshToken,
      expiresAt: getTokenExpirationDate(process.env.JWT_REFRESH_EXPIRES_IN || '7d'),
    });

    return {
      user: user.toJSON(),
      accessToken,
      refreshToken,
    };
  }

  async refresh(refreshToken: string) {
    // Verify token
    let payload: TokenPayload;
    try {
      payload = verifyRefreshToken(refreshToken);
    } catch (error) {
      throw new AppError('Invalid refresh token', 401);
    }

    // Check if token exists in database
    const tokenRecord = await RefreshToken.findOne({
      where: { token: refreshToken },
    });

    if (!tokenRecord) {
      throw new AppError('Refresh token not found', 401);
    }

    // Check if token expired
    if (new Date() > tokenRecord.expiresAt) {
      await tokenRecord.destroy();
      throw new AppError('Refresh token expired', 401);
    }

    // Find user
    const user = await User.findByPk(payload.userId);
    if (!user) {
      throw new AppError('User not found', 404);
    }

    // Check user status
    if (user.status !== 'active') {
      throw new AppError('Account not active', 403);
    }

    // Generate new access token
    const newPayload: TokenPayload = {
      userId: user.id,
      email: user.email,
      role: user.role,
    };

    const newAccessToken = generateAccessToken(newPayload);

    logger.info(`Access token refreshed for user: ${user.id}`);

    return {
      accessToken: newAccessToken,
    };
  }

  async logout(userId: string, refreshToken?: string) {
    if (refreshToken) {
      // Delete specific refresh token
      await RefreshToken.destroy({
        where: { token: refreshToken },
      });
    } else {
      // Delete all refresh tokens for user
      await RefreshToken.destroy({
        where: { userId },
      });
    }

    logger.info(`User logged out: ${userId}`);
  }

  async getMe(userId: string) {
    const user = await User.findByPk(userId);
    if (!user) {
      throw new AppError('User not found', 404);
    }

    return user.toJSON();
  }
}

export default new AuthService();

