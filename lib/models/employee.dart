import 'package:json_annotation/json_annotation.dart';

part 'employee.g.dart';

@JsonSerializable()
class Employee {
  @JsonKey(name: '_id')
  final String id;
  final String name;
  final String? email;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Employee({
    required this.id,
    required this.name,
    this.email,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Employee.fromJson(Map<String, dynamic> json) => _$EmployeeFromJson(json);
  Map<String, dynamic> toJson() => _$EmployeeToJson(this);
}

@JsonSerializable()
class EmployeeReference {
  @JsonKey(name: '_id')
  final String id;
  final String name;
  final String? email;

  const EmployeeReference({
    required this.id,
    required this.name,
    this.email,
  });

  factory EmployeeReference.fromJson(Map<String, dynamic> json) => _$EmployeeReferenceFromJson(json);
  Map<String, dynamic> toJson() => _$EmployeeReferenceToJson(this);
}

@JsonSerializable()
class EmployeeCreateData {
  final String name;
  final String? email;
  final bool isActive;

  const EmployeeCreateData({
    required this.name,
    this.email,
    this.isActive = true,
  });

  factory EmployeeCreateData.fromJson(Map<String, dynamic> json) => _$EmployeeCreateDataFromJson(json);
  Map<String, dynamic> toJson() => _$EmployeeCreateDataToJson(this);
}

@JsonSerializable()
class EmployeeUpdateData {
  final String? name;
  final String? email;
  final bool? isActive;

  const EmployeeUpdateData({
    this.name,
    this.email,
    this.isActive,
  });

  factory EmployeeUpdateData.fromJson(Map<String, dynamic> json) => _$EmployeeUpdateDataFromJson(json);
  Map<String, dynamic> toJson() => _$EmployeeUpdateDataToJson(this);
}
