import 'package:json_annotation/json_annotation.dart';
import 'user.dart';
import 'employee.dart';

part 'time_entry.g.dart';

enum TimeEntryStatus {
  pending,
  approved,
  rejected;

  String toJson() => name.toUpperCase();
  static TimeEntryStatus fromJson(String json) => 
      TimeEntryStatus.values.firstWhere((e) => e.name.toUpperCase() == json.toUpperCase());
}

@JsonSerializable()
class TimeEntry {
  @JsonKey(name: '_id')
  final String id;
  final EmployeeReference employee;
  final DateTime date;
  final DateTime entryTime;
  final DateTime? exitTime;
  final TimeEntryStatus status;
  final double? dailyRate;
  final double? extraHours;
  final double? extraHoursRate;
  final double? total;
  final num? totalHours; // Can be number or string
  final num? regularHours; // Can be number or string
  final String? notes;
  final UserReference? approvedBy;
  final DateTime? approvedAt;
  final DateTime? rejectedAt;
  final String? rejectedReason;
  final UserReference? rejectedBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  const TimeEntry({
    required this.id,
    required this.employee,
    required this.date,
    required this.entryTime,
    this.exitTime,
    required this.status,
    this.dailyRate,
    this.extraHours,
    this.extraHoursRate,
    this.total,
    this.totalHours,
    this.regularHours,
    this.notes,
    this.approvedBy,
    this.approvedAt,
    this.rejectedAt,
    this.rejectedReason,
    this.rejectedBy,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TimeEntry.fromJson(Map<String, dynamic> json) => _$TimeEntryFromJson(json);
  Map<String, dynamic> toJson() => _$TimeEntryToJson(this);
}

@JsonSerializable()
class TimeEntryCreateData {
  final String employee;
  final DateTime date;
  final DateTime entryTime;
  final DateTime? exitTime;
  final String? notes;
  final double? dailyRate;
  final double? extraHoursRate;
  final double? extraHours;
  final TimeEntryStatus? status;

  const TimeEntryCreateData({
    required this.employee,
    required this.date,
    required this.entryTime,
    this.exitTime,
    this.notes,
    this.dailyRate,
    this.extraHoursRate,
    this.extraHours,
    this.status,
  });

  factory TimeEntryCreateData.fromJson(Map<String, dynamic> json) => _$TimeEntryCreateDataFromJson(json);
  Map<String, dynamic> toJson() => _$TimeEntryCreateDataToJson(this);
}

@JsonSerializable()
class TimeEntryUpdateData {
  final DateTime? date;
  final DateTime? entryTime;
  final DateTime? exitTime;
  final String? notes;
  final TimeEntryStatus? status;
  final double? dailyRate;
  final double? extraHours;
  final double? extraHoursRate;
  final num? totalHours; // Can be number or string
  final num? regularHours; // Can be number or string
  final String? approvedBy;
  final String? rejectedBy;
  final String? rejectedReason;

  const TimeEntryUpdateData({
    this.date,
    this.entryTime,
    this.exitTime,
    this.notes,
    this.status,
    this.dailyRate,
    this.extraHours,
    this.extraHoursRate,
    this.totalHours,
    this.regularHours,
    this.approvedBy,
    this.rejectedBy,
    this.rejectedReason,
  });

  factory TimeEntryUpdateData.fromJson(Map<String, dynamic> json) => _$TimeEntryUpdateDataFromJson(json);
  Map<String, dynamic> toJson() => _$TimeEntryUpdateDataToJson(this);
}

@JsonSerializable()
class TimeEntryFilter {
  final DateTime startDate;
  final DateTime endDate;
  final String? employeeId;
  final TimeEntryStatus? status;
  final bool includeDetails;

  const TimeEntryFilter({
    required this.startDate,
    required this.endDate,
    this.employeeId,
    this.status,
    this.includeDetails = false,
  });

  factory TimeEntryFilter.fromJson(Map<String, dynamic> json) => _$TimeEntryFilterFromJson(json);
  Map<String, dynamic> toJson() => _$TimeEntryFilterToJson(this);
}
