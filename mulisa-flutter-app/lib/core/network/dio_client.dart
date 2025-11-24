// lib/core/network/dio_client.dart
import 'package:dio/dio.dart';
import '../../features/auth/data/auth_local_store.dart';
import '../Applogger.dart'; // AppLogger.logger

class DioClient {
  final Dio _dio;
  final AuthLocalStore _local;

  DioClient._(this._dio, this._local);

  /// Build from an already-configured Dio (baseUrl, timeouts, etc. come from DI)
  factory DioClient.from(
      Dio dio,
      AuthLocalStore local, {
        bool enableLogging = false,
      }) {

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final requiresAuth = options.extra['requireAuth'] == true;
          if (requiresAuth) {
            final token = await local.readToken();
            if (token != null && token.isNotEmpty) {
              options.headers['Authorization'] = 'Bearer $token';
            }
          } else {
            // ensure no leftover auth header
            options.headers.remove('Authorization');
          }
          handler.next(options);
        },
        onError: (e, handler) => handler.next(e),
      ),
    );

    // === Logging (optional, controlled by AppConfig.enableLogging) ===
    if (enableLogging) {
      dio.interceptors.add(
        LogInterceptor(
          request: true,
          requestHeader: true,
          requestBody: true,
          responseHeader: false,
          responseBody: true,
          error: true,
          logPrint: (obj) => AppLogger.logger.d(obj),
        ),
      );
    }

    return DioClient._(dio, local);
  }

  // ===== Convenience methods =====

  Future<Response<T>> get<T>(
      String path, {
        Map<String, dynamic>? queryParameters,
        bool requireAuth = false,
        Options? options,
      }) {
    return _dio.get<T>(
      path,
      queryParameters: queryParameters,
      options: _withAuth(requireAuth, options),
    );
  }

  Future<Response<T>> post<T>(
      String path, {
        dynamic data,
        Map<String, dynamic>? queryParameters,
        bool requireAuth = false,
        Options? options,
      }) {
    return _dio.post<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: _withAuth(requireAuth, options),
    );
  }

  Future<Response<T>> patch<T>(
      String path, {
        dynamic data,
        Map<String, dynamic>? queryParameters,
        bool requireAuth = false,
        Options? options,
      }) {
    return _dio.patch<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: _withAuth(requireAuth, options),
    );
  }

  Future<Response<T>> put<T>(
      String path, {
        dynamic data,
        Map<String, dynamic>? queryParameters,
        bool requireAuth = false,
        Options? options,
      }) {
    return _dio.put<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: _withAuth(requireAuth, options),
    );
  }

  Future<Response<T>> delete<T>(
      String path, {
        dynamic data,
        Map<String, dynamic>? queryParameters,
        bool requireAuth = false,
        Options? options,
      }) {
    return _dio.delete<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: _withAuth(requireAuth, options),
    );
  }

  // helper
  Options _withAuth(bool requireAuth, Options? options) {
    final base = (options ?? Options());
    final headers = Map<String, dynamic>.from(base.headers ?? {});
    // don't set Authorization here; interceptor will handle it based on 'requireAuth'
    headers.remove('Authorization');
    final extra = Map<String, dynamic>.from(base.extra ?? {});
    extra['requireAuth'] = requireAuth;           // <— key line
    return base.copyWith(headers: headers, extra: extra);
  }
}
