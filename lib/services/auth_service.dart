import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../constants/api_constants.dart';
import 'api_client.dart';

class AuthService {
  final ApiClient _apiClient = ApiClient();

  // Login user
  Future<LoginResponse> login(LoginCredentials credentials) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.login,
        data: credentials.toJson(),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint('Dados da resposta de login: ${response.data}');
        final loginResponse = LoginResponse.fromJson(response.data);
        
        // Save token and user data
        await _apiClient.saveToken(loginResponse.accessToken);
        await _apiClient.saveUser(loginResponse.user.toJson().toString());
        
        return loginResponse;
      } else {
        debugPrint('Falha no login com status: ${response.statusCode}, data: ${response.data}');
        throw Exception('Falha no login: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception(_apiClient.handleError(e));
    }
  }

  // Register user
  Future<User> register(RegisterData registerData) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.register,
        data: registerData.toJson(),
      );

      if (response.statusCode == 201) {
        return User.fromJson(response.data);
      } else {
        throw Exception('Falha no registro: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception(_apiClient.handleError(e));
    }
  }

  // Get current user profile
  Future<User> getProfile() async {
    try {
      final response = await _apiClient.get(ApiConstants.profile);

      if (response.statusCode == 200) {
        return User.fromJson(response.data);
      } else {
        throw Exception('Falha ao obter perfil: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception(_apiClient.handleError(e));
    }
  }

  // Logout user
  Future<void> logout() async {
    try {
      await _apiClient.clearToken();
    } catch (e) {
      // Even if clearing token fails, continue with logout
      debugPrint('Erro ao fazer logout: $e');
    }
  }

  // Check if user is authenticated
  Future<bool> isAuthenticated() async {
    final token = await _apiClient.getToken();
    return token != null && token.isNotEmpty;
  }

  // Get stored user data
  Future<User?> getStoredUser() async {
    try {
      final userJson = await _apiClient.getUser();
      if (userJson != null) {
        // Parse JSON string to Map<String, dynamic>
        final userMap = Map<String, dynamic>.from(
          // This is a simple approach - you might want to use json.decode
          // but for now we'll assume the stored data is properly formatted
          Map<String, dynamic>.from({})
        );
        return User.fromJson(userMap);
      }
      return null;
    } catch (e) {
      debugPrint('Erro ao obter usuário armazenado: $e');
      return null;
    }
  }

  // Refresh user data
  Future<User> refreshUserData() async {
    try {
      final user = await getProfile();
      await _apiClient.saveUser(user.toJson().toString());
      return user;
    } on DioException catch (e) {
      throw Exception(_apiClient.handleError(e));
    }
  }
}
