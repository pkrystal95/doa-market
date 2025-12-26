import { defineConfig, devices } from '@playwright/test';
import dotenv from 'dotenv';
import path from 'path';

// Load test environment variables
dotenv.config({ path: path.join(__dirname, 'tests/.env.test') });

export default defineConfig({
  testDir: './tests/e2e',

  // Maximum time one test can run
  timeout: 60 * 1000,

  // Test execution settings
  fullyParallel: true,
  forbidOnly: !!process.env.CI,
  retries: process.env.CI ? 2 : 1,
  workers: process.env.CI ? 1 : undefined,

  // Reporter configuration
  reporter: [
    ['html', {
      outputFolder: 'playwright-report',
      open: 'never'
    }],
    ['json', {
      outputFile: 'test-results/results.json'
    }],
    ['list'],
  ],

  use: {
    // Base URL for API tests
    baseURL: process.env.API_GATEWAY_URL || 'http://localhost:3000',

    // Screenshot on failure
    screenshot: 'only-on-failure',

    // Video on retry
    video: 'retain-on-failure',

    // Trace on first retry
    trace: 'on-first-retry',

    // Action timeout
    actionTimeout: 15 * 1000,

    // Navigation timeout
    navigationTimeout: 30 * 1000,
  },

  // Configure projects for different test types
  projects: [
    {
      name: 'API Tests',
      testMatch: /.*\.api\.spec\.ts/,
      use: {
        ...devices['Desktop Chrome'],
        baseURL: process.env.API_GATEWAY_URL || 'http://localhost:3000',
      },
    },

    {
      name: 'Admin Web UI',
      testMatch: /.*admin.*\.spec\.ts/,
      testIgnore: /.*\.api\.spec\.ts/,
      use: {
        ...devices['Desktop Chrome'],
        baseURL: process.env.ADMIN_WEB_URL || 'http://localhost:3100',
      },
    },

    {
      name: 'Seller Web UI',
      testMatch: /.*seller.*\.spec\.ts/,
      testIgnore: /.*\.api\.spec\.ts/,
      use: {
        ...devices['Desktop Chrome'],
        baseURL: process.env.SELLER_WEB_URL || 'http://localhost:3200',
      },
    },

    {
      name: 'Integration Scenarios',
      testMatch: /.*scenarios.*\.spec\.ts/,
      use: {
        ...devices['Desktop Chrome'],
      },
    },
  ],

  // Web Server configuration (optional - for local development)
  webServer: process.env.SKIP_WEB_SERVER ? undefined : [
    {
      command: 'cd frontend/admin-web && npm run dev',
      url: 'http://localhost:3100',
      reuseExistingServer: !process.env.CI,
      timeout: 120 * 1000,
    },
  ],
});
