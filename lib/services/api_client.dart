import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/api_constants.dart';

class ApiClient {
  late Dio _dio;
  static final ApiClient _instance = ApiClient._internal();
  final FlutterSecureStorage _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.unlocked_this_device,
    ),
  );

  factory ApiClient() {
    return _instance;
  }

  ApiClient._internal() {
    _dio = Dio(BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(milliseconds: ApiConstants.connectTimeout),
      receiveTimeout: const Duration(milliseconds: ApiConstants.receiveTimeout),
      sendTimeout: const Duration(milliseconds: ApiConstants.sendTimeout),
      headers: {
        'Content-Type': ApiConstants.contentType,
        'Accept': ApiConstants.accept,
      },
      validateStatus: (status) => status != null && status < 400,
    ));

    _setupInterceptors();
  }

  void _setupInterceptors() {
    // Add request interceptor to include auth token
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _storage.read(key: 'access_token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (error, handler) async {
        // Handle token refresh or logout if needed
        if (error.response?.statusCode == 401) {
          await _storage.delete(key: 'access_token');
          await _storage.delete(key: 'user');
          // You might want to navigate to login screen here
        }
        handler.next(error);
      },
    ));
  }

  Dio get dio => _dio;

  // Generic GET request
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw handleError(e);
    }
  }

  // Generic POST request
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      debugPrint('Making POST request to: $path');
      debugPrint('Request data: $data');
      final response = await _dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      debugPrint('Response status: ${response.statusCode}');
      debugPrint('Response data: ${response.data}');
      return response;
    } on DioException catch (e) {
      debugPrint('DioException: ${e.type}');
      debugPrint('Response status: ${e.response?.statusCode}');
      debugPrint('Response data: ${e.response?.data}');
      throw handleError(e);
    }
  }

  // Generic PUT request
  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.put<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw handleError(e);
    }
  }

  // Generic DELETE request
  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.delete<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw handleError(e);
    }
  }

  // Handle Dio errors
  String handleError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return 'Tempo limite de conexão esgotado';
      case DioExceptionType.sendTimeout:
        return 'Tempo limite de envio esgotado';
      case DioExceptionType.receiveTimeout:
        return 'Tempo limite de recebimento esgotado';
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final message = error.response?.data?['message'] ?? 'Erro desconhecido';
        return 'Erro $statusCode: $message';
      case DioExceptionType.cancel:
        return 'Solicitação cancelada';
      case DioExceptionType.unknown:
        return 'Erro de rede: ${error.message}';
      default:
        return 'Ocorreu um erro desconhecido';
    }
  }

  // Save token to secure storage
  Future<void> saveToken(String token) async {
    await _storage.write(key: 'access_token', value: token);
  }

  // Get token from secure storage
  Future<String?> getToken() async {
    return await _storage.read(key: 'access_token');
  }

  // Clear token from secure storage
  Future<void> clearToken() async {
    await _storage.delete(key: 'access_token');
    await _storage.delete(key: 'user');
  }

  // Save user data to secure storage
  Future<void> saveUser(String userJson) async {
    await _storage.write(key: 'user', value: userJson);
  }

  // Get user data from secure storage
  Future<String?> getUser() async {
    return await _storage.read(key: 'user');
  }
}
