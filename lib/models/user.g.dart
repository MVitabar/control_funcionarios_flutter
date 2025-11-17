// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) => User(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      role: json['role'] as String?,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
      username: json['username'] as String?,
    );

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'email': instance.email,
      'role': instance.role,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
      'username': instance.username,
    };

UserReference _$UserReferenceFromJson(Map<String, dynamic> json) =>
    UserReference(
      id: json['_id'] as String,
      name: json['name'] as String,
      email: json['email'] as String?,
    );

Map<String, dynamic> _$UserReferenceToJson(UserReference instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'name': instance.name,
      'email': instance.email,
    };

LoginResponse _$LoginResponseFromJson(Map<String, dynamic> json) =>
    LoginResponse(
      accessToken: json['access_token'] as String,
      user: User.fromJson(json['user'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$LoginResponseToJson(LoginResponse instance) =>
    <String, dynamic>{
      'access_token': instance.accessToken,
      'user': instance.user,
    };

LoginCredentials _$LoginCredentialsFromJson(Map<String, dynamic> json) =>
    LoginCredentials(
      email: json['email'] as String,
      password: json['password'] as String,
    );

Map<String, dynamic> _$LoginCredentialsToJson(LoginCredentials instance) =>
    <String, dynamic>{
      'email': instance.email,
      'password': instance.password,
    };

RegisterData _$RegisterDataFromJson(Map<String, dynamic> json) => RegisterData(
      name: json['name'] as String,
      email: json['email'] as String,
      password: json['password'] as String,
      confirmPassword: json['confirmPassword'] as String,
    );

Map<String, dynamic> _$RegisterDataToJson(RegisterData instance) =>
    <String, dynamic>{
      'name': instance.name,
      'email': instance.email,
      'password': instance.password,
      'confirmPassword': instance.confirmPassword,
    };
