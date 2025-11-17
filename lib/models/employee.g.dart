// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'employee.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Employee _$EmployeeFromJson(Map<String, dynamic> json) => Employee(
      id: json['_id'] as String,
      name: json['name'] as String,
      email: json['email'] as String?,
      isActive: json['isActive'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$EmployeeToJson(Employee instance) => <String, dynamic>{
      '_id': instance.id,
      'name': instance.name,
      'email': instance.email,
      'isActive': instance.isActive,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

EmployeeReference _$EmployeeReferenceFromJson(Map<String, dynamic> json) =>
    EmployeeReference(
      id: json['_id'] as String,
      name: json['name'] as String,
      email: json['email'] as String?,
    );

Map<String, dynamic> _$EmployeeReferenceToJson(EmployeeReference instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'name': instance.name,
      'email': instance.email,
    };

EmployeeCreateData _$EmployeeCreateDataFromJson(Map<String, dynamic> json) =>
    EmployeeCreateData(
      name: json['name'] as String,
      email: json['email'] as String?,
      isActive: json['isActive'] as bool? ?? true,
    );

Map<String, dynamic> _$EmployeeCreateDataToJson(EmployeeCreateData instance) =>
    <String, dynamic>{
      'name': instance.name,
      'email': instance.email,
      'isActive': instance.isActive,
    };

EmployeeUpdateData _$EmployeeUpdateDataFromJson(Map<String, dynamic> json) =>
    EmployeeUpdateData(
      name: json['name'] as String?,
      email: json['email'] as String?,
      isActive: json['isActive'] as bool?,
    );

Map<String, dynamic> _$EmployeeUpdateDataToJson(EmployeeUpdateData instance) =>
    <String, dynamic>{
      'name': instance.name,
      'email': instance.email,
      'isActive': instance.isActive,
    };
