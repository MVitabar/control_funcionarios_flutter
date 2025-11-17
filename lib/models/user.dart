import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

@JsonSerializable()
class User {
  final String id;
  final String name;
  final String email;
  final String? role;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? username;

  const User({
    required this.id,
    required this.name,
    required this.email,
    this.role,
    this.createdAt,
    this.updatedAt,
    this.username,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);
}

@JsonSerializable()
class UserReference {
  @JsonKey(name: '_id')
  final String id;
  final String name;
  final String? email;

  const UserReference({
    required this.id,
    required this.name,
    this.email,
  });

  factory UserReference.fromJson(Map<String, dynamic> json) => _$UserReferenceFromJson(json);
  Map<String, dynamic> toJson() => _$UserReferenceToJson(this);
}

@JsonSerializable()
class LoginResponse {
  @JsonKey(name: 'access_token')
  final String accessToken;
  final User user;

  const LoginResponse({
    required this.accessToken,
    required this.user,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) => _$LoginResponseFromJson(json);
  Map<String, dynamic> toJson() => _$LoginResponseToJson(this);
}

@JsonSerializable()
class LoginCredentials {
  final String email;
  final String password;

  const LoginCredentials({
    required this.email,
    required this.password,
  });

  factory LoginCredentials.fromJson(Map<String, dynamic> json) => _$LoginCredentialsFromJson(json);
  Map<String, dynamic> toJson() => _$LoginCredentialsToJson(this);
}

@JsonSerializable()
class RegisterData {
  final String name;
  final String email;
  final String password;
  final String confirmPassword;

  const RegisterData({
    required this.name,
    required this.email,
    required this.password,
    required this.confirmPassword,
  });

  factory RegisterData.fromJson(Map<String, dynamic> json) => _$RegisterDataFromJson(json);
  Map<String, dynamic> toJson() => _$RegisterDataToJson(this);
}
