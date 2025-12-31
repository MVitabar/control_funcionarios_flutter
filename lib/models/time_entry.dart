import 'package:json_annotation/json_annotation.dart';
import 'user.dart';
import 'employee.dart';

part 'time_entry.g.dart';

enum TimeEntryStatus {
  pending,
  approved,
  rejected;

  String toJson() => name.toUpperCase();
  static TimeEntryStatus fromJson(String json) => TimeEntryStatus.values
      .firstWhere((e) => e.name.toUpperCase() == json.toUpperCase());
}

@JsonSerializable()
class TimeEntry {
  @JsonKey(name: '_id', fromJson: _idFromJson)
  final String id;
  final EmployeeReference employee;
  final DateTime date;
  final DateTime entryTime;
  final DateTime? exitTime;
  @JsonKey(fromJson: _statusFromJson, toJson: _statusToJson)
  final TimeEntryStatus? status;
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
    this.status,  // Made optional
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

  factory TimeEntry.fromJson(Map<String, dynamic> json) =>
      _$TimeEntryFromJson(json);
  Map<String, dynamic> toJson() => _$TimeEntryToJson(this);

  // Handle different _id formats from the server
  static String _idFromJson(dynamic id) {
    if (id is String) return id;
    if (id is Map && id['\$oid'] != null) return id['\$oid'] as String;
    if (id is Map && id['buffer'] != null) {
      // Handle the case where _id is an object with a buffer
      final buffer = List<int>.from(id['buffer'] as List);
      return buffer.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
    }
    return id.toString();
  }
  
  // Handle status deserialization with null safety
  static TimeEntryStatus? _statusFromJson(dynamic status) {
    if (status == null) return null;
    if (status is String) {
      return $enumDecode(_$TimeEntryStatusEnumMap, status);
    }
    return null;
  }
  
  // Convert status to string for serialization
  static dynamic _statusToJson(TimeEntryStatus? status) {
    return status?.toString().split('.').last;
  }
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
  final double? total;

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
    this.total,
  });

  factory TimeEntryCreateData.fromJson(Map<String, dynamic> json) =>
      _$TimeEntryCreateDataFromJson(json);
  Map<String, dynamic> toJson() => _$TimeEntryCreateDataToJson(this);
  
  // Create a copyWith method to update the total
  TimeEntryCreateData copyWith({
    String? employee,
    DateTime? date,
    DateTime? entryTime,
    DateTime? exitTime,
    String? notes,
    double? dailyRate,
    double? extraHoursRate,
    double? extraHours,
    TimeEntryStatus? status,
    double? total,
  }) {
    return TimeEntryCreateData(
      employee: employee ?? this.employee,
      date: date ?? this.date,
      entryTime: entryTime ?? this.entryTime,
      exitTime: exitTime ?? this.exitTime,
      notes: notes ?? this.notes,
      dailyRate: dailyRate ?? this.dailyRate,
      extraHoursRate: extraHoursRate ?? this.extraHoursRate,
      extraHours: extraHours ?? this.extraHours,
      status: status ?? this.status,
      total: total ?? this.total,
    );
  }
  
  // Calculate total based on daily rate and extra hours
  TimeEntryCreateData withCalculatedTotal() {
    if (dailyRate == null) return this;
    
    double calculatedTotal = dailyRate!;
    
    // Add extra hours payment if available
    if (extraHours != null && extraHours! > 0 && extraHoursRate != null) {
      calculatedTotal += extraHours! * extraHoursRate!;
    }
    
    return copyWith(total: calculatedTotal);
  }

  // Calculate total based on daily rate and extra hours
  double? calculateTotal() {
    double? total = dailyRate;
    
    // Add extra hours payment if available
    if (extraHours != null && extraHours! > 0 && extraHoursRate != null) {
      total = (total ?? 0) + (extraHours! * extraHoursRate!);
    }
    
    return total;
  }
}

@JsonSerializable(includeIfNull: false)
class TimeEntryUpdateData {
  final DateTime? date;
  final DateTime? entryTime;
  final DateTime? exitTime;
  final String? notes;
  final TimeEntryStatus? status;
  final double? dailyRate;
  final double? extraHours;
  final double? extraHoursRate;
  final double? total;

  const TimeEntryUpdateData({
    this.date,
    this.entryTime,
    this.exitTime,
    this.notes,
    this.status,
    this.dailyRate,
    this.extraHours,
    this.extraHoursRate,
    this.total,
  });

  factory TimeEntryUpdateData.fromJson(Map<String, dynamic> json) =>
      _$TimeEntryUpdateDataFromJson(json);
  Map<String, dynamic> toJson() => _$TimeEntryUpdateDataToJson(this);
  
  // Create a copyWith method to update the total
  TimeEntryUpdateData copyWith({
    DateTime? date,
    DateTime? entryTime,
    DateTime? exitTime,
    String? notes,
    TimeEntryStatus? status,
    double? dailyRate,
    double? extraHours,
    double? extraHoursRate,
    double? total,
  }) {
    return TimeEntryUpdateData(
      date: date ?? this.date,
      entryTime: entryTime ?? this.entryTime,
      exitTime: exitTime ?? this.exitTime,
      notes: notes ?? this.notes,
      status: status ?? this.status,
      dailyRate: dailyRate ?? this.dailyRate,
      extraHours: extraHours ?? this.extraHours,
      extraHoursRate: extraHoursRate ?? this.extraHoursRate,
      total: total ?? this.total,
    );
  }
  
  // Calculate total based on daily rate and extra hours
  TimeEntryUpdateData withCalculatedTotal() {
    if (dailyRate == null) return this;
    
    double calculatedTotal = dailyRate!;
    
    // Add extra hours payment if available
    if (extraHours != null && extraHours! > 0 && extraHoursRate != null) {
      calculatedTotal += extraHours! * extraHoursRate!;
    }
    
    return copyWith(total: calculatedTotal);
  }

  // Calculate total based on daily rate and extra hours
  double? calculateTotal() {
    double? total = dailyRate;
    
    // Add extra hours payment if available
    if (extraHours != null && extraHours! > 0 && extraHoursRate != null) {
      total = (total ?? 0) + (extraHours! * extraHoursRate!);
    }
    
    return total;
  }
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

  factory TimeEntryFilter.fromJson(Map<String, dynamic> json) =>
      _$TimeEntryFilterFromJson(json);
  Map<String, dynamic> toJson() => _$TimeEntryFilterToJson(this);
}
