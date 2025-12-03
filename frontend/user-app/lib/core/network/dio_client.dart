import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/app_config.dart';
import '../utils/logger.dart';

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: AppConfig.apiBaseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );

  // Request Interceptor
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        final token = AppConfig.accessToken;
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }

        AppLogger.d('REQUEST[${options.method}] => ${options.uri}');
        return handler.next(options);
      },
      onResponse: (response, handler) {
        AppLogger.d(
          'RESPONSE[${response.statusCode}] => ${response.requestOptions.uri}',
        );
        return handler.next(response);
      },
      onError: (error, handler) async {
        AppLogger.e(
          'ERROR[${error.response?.statusCode}] => ${error.requestOptions.uri}',
        );

        // Handle 401 Unauthorized
        if (error.response?.statusCode == 401) {
          try {
            final refreshToken = AppConfig.refreshToken;
            if (refreshToken != null) {
              // Refresh token
              final response = await dio.post(
                '/api/v1/auth/refresh',
                data: {'refreshToken': refreshToken},
              );

              if (response.statusCode == 200) {
                final newAccessToken = response.data['data']['accessToken'];
                final newRefreshToken = response.data['data']['refreshToken'];

                await AppConfig.setTokens(newAccessToken, newRefreshToken);

                // Retry original request
                error.requestOptions.headers['Authorization'] =
                    'Bearer $newAccessToken';

                final retryResponse = await dio.fetch(error.requestOptions);
                return handler.resolve(retryResponse);
              }
            }
          } catch (e) {
            // Refresh failed, clear tokens and redirect to login
            await AppConfig.clearTokens();
            // Navigate to login page
          }
        }

        return handler.next(error);
      },
    ),
  );

  // Logging Interceptor (Debug only)
  if (AppConfig.enableLogging) {
    dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
    ));
  }

  return dio;
});
