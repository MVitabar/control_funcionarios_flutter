class ApiConstants {
  static const String baseUrl = 'https://control-funcionarios.onrender.com';
  static const String apiVersion = '';
  
  // Auth endpoints
  static const String login = '$apiVersion/auth/login';
  static const String register = '$apiVersion/auth/register';
  static const String profile = '$apiVersion/auth/profile';
  
  // User endpoints
  static const String users = '$apiVersion/users';
  static const String currentUser = '$apiVersion/users/me';
  
  // Employee endpoints
  static const String employees = '$apiVersion/employees';
  
  // Time entry endpoints
  static const String timeEntries = '$apiVersion/time-entries';
  static const String timeEntriesByEmployee = '$apiVersion/time-entries/employee';
  static const String timeEntryExit = '$apiVersion/time-entries';
  static const String timeEntryStatus = '$apiVersion/time-entries';
  
  // Headers
  static const String contentType = 'application/json';
  static const String accept = 'application/json';
  
  // Timeouts
  static const int connectTimeout = 30000;
  static const int receiveTimeout = 30000;
  static const int sendTimeout = 30000;
}
