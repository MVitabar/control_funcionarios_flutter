import 'package:flutter/foundation.dart';
import '../services/auth_service.dart';
import '../models/user.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  User? _user;
  bool _isLoading = false;
  String? _error;

  // Getters
  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _user != null;

  // Initialize auth state
  Future<void> initializeAuth() async {
    _isLoading = true;
    notifyListeners();

    try {
      final isAuth = await _authService.isAuthenticated();
      if (isAuth) {
        _user = await _authService.refreshUserData();
      }
    } catch (e) {
      _error = e.toString();
      debugPrint('Erro ao inicializar autenticação: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Login
  Future<void> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final credentials = LoginCredentials(email: email, password: password);
      final loginResponse = await _authService.login(credentials);
      _user = loginResponse.user;
      _error = null; // Limpar qualquer erro anterior
      debugPrint('Login bem-sucedido para: ${_user?.email}');
    } catch (e) {
      _error = e.toString();
      debugPrint('Erro de login: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Register
  Future<void> register(String name, String email, String password, String confirmPassword) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final registerData = RegisterData(
        name: name,
        email: email,
        password: password,
        confirmPassword: confirmPassword,
      );
      await _authService.register(registerData);
      
      // After successful registration, try to login
      await login(email, password);
    } catch (e) {
      _error = e.toString();
      debugPrint('Erro de registro: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Logout
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _authService.logout();
      _user = null;
      _error = null;
    } catch (e) {
      _error = e.toString();
      debugPrint('Erro de logout: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Refresh user data
  Future<void> refreshUser() async {
    try {
      _user = await _authService.refreshUserData();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      debugPrint('Erro ao atualizar usuário: $e');
    }
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Update user profile
  Future<void> updateProfile(String name, String email) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // This would be implemented in the auth service
      // For now, we'll just refresh the user data
      await refreshUser();
    } catch (e) {
      _error = e.toString();
      debugPrint('Erro ao atualizar perfil: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Change password
  Future<void> changePassword(String currentPassword, String newPassword, String confirmPassword) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // This would be implemented in the auth service
      // For now, we'll just simulate the operation
      await Future.delayed(const Duration(seconds: 1));
    } catch (e) {
      _error = e.toString();
      debugPrint('Erro ao alterar senha: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
