// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'time_entry.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TimeEntry _$TimeEntryFromJson(Map<String, dynamic> json) => TimeEntry(
  id: json['_id'] as String,
  employee: EmployeeReference.fromJson(
    json['employee'] as Map<String, dynamic>,
  ),
  date: DateTime.parse(json['date'] as String),
  entryTime: DateTime.parse(json['entryTime'] as String),
  exitTime: json['exitTime'] == null
      ? null
      : DateTime.parse(json['exitTime'] as String),
  status: $enumDecode(_$TimeEntryStatusEnumMap, json['status']),
  dailyRate: (json['dailyRate'] as num?)?.toDouble(),
  extraHours: (json['extraHours'] as num?)?.toDouble(),
  extraHoursRate: (json['extraHoursRate'] as num?)?.toDouble(),
  total: (json['total'] as num?)?.toDouble(),
  totalHours: json['totalHours'] as num?,
  regularHours: json['regularHours'] as num?,
  notes: json['notes'] as String?,
  approvedBy: json['approvedBy'] == null
      ? null
      : UserReference.fromJson(json['approvedBy'] as Map<String, dynamic>),
  approvedAt: json['approvedAt'] == null
      ? null
      : DateTime.parse(json['approvedAt'] as String),
  rejectedAt: json['rejectedAt'] == null
      ? null
      : DateTime.parse(json['rejectedAt'] as String),
  rejectedReason: json['rejectedReason'] as String?,
  rejectedBy: json['rejectedBy'] == null
      ? null
      : UserReference.fromJson(json['rejectedBy'] as Map<String, dynamic>),
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$TimeEntryToJson(TimeEntry instance) => <String, dynamic>{
  '_id': instance.id,
  'employee': instance.employee,
  'date': instance.date.toIso8601String(),
  'entryTime': instance.entryTime.toIso8601String(),
  'exitTime': instance.exitTime?.toIso8601String(),
  'status': instance.status,
  'dailyRate': instance.dailyRate,
  'extraHours': instance.extraHours,
  'extraHoursRate': instance.extraHoursRate,
  'total': instance.total,
  'totalHours': instance.totalHours,
  'regularHours': instance.regularHours,
  'notes': instance.notes,
  'approvedBy': instance.approvedBy,
  'approvedAt': instance.approvedAt?.toIso8601String(),
  'rejectedAt': instance.rejectedAt?.toIso8601String(),
  'rejectedReason': instance.rejectedReason,
  'rejectedBy': instance.rejectedBy,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
};

const _$TimeEntryStatusEnumMap = {
  TimeEntryStatus.pending: 'pending',
  TimeEntryStatus.approved: 'approved',
  TimeEntryStatus.rejected: 'rejected',
};

TimeEntryCreateData _$TimeEntryCreateDataFromJson(Map<String, dynamic> json) =>
    TimeEntryCreateData(
      employee: json['employee'] as String,
      date: DateTime.parse(json['date'] as String),
      entryTime: DateTime.parse(json['entryTime'] as String),
      exitTime: json['exitTime'] == null
          ? null
          : DateTime.parse(json['exitTime'] as String),
      notes: json['notes'] as String?,
      dailyRate: (json['dailyRate'] as num?)?.toDouble(),
      extraHoursRate: (json['extraHoursRate'] as num?)?.toDouble(),
      status: $enumDecodeNullable(_$TimeEntryStatusEnumMap, json['status']),
    );

Map<String, dynamic> _$TimeEntryCreateDataToJson(
  TimeEntryCreateData instance,
) => <String, dynamic>{
  'employee': instance.employee,
  'date': instance.date.toIso8601String(),
  'entryTime': instance.entryTime.toIso8601String(),
  'exitTime': instance.exitTime?.toIso8601String(),
  'notes': instance.notes,
  'dailyRate': instance.dailyRate,
  'extraHoursRate': instance.extraHoursRate,
  'status': instance.status,
};

TimeEntryUpdateData _$TimeEntryUpdateDataFromJson(Map<String, dynamic> json) =>
    TimeEntryUpdateData(
      date: json['date'] == null
          ? null
          : DateTime.parse(json['date'] as String),
      entryTime: json['entryTime'] == null
          ? null
          : DateTime.parse(json['entryTime'] as String),
      exitTime: json['exitTime'] == null
          ? null
          : DateTime.parse(json['exitTime'] as String),
      notes: json['notes'] as String?,
      status: $enumDecodeNullable(_$TimeEntryStatusEnumMap, json['status']),
      dailyRate: (json['dailyRate'] as num?)?.toDouble(),
      extraHours: (json['extraHours'] as num?)?.toDouble(),
      extraHoursRate: (json['extraHoursRate'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$TimeEntryUpdateDataToJson(
  TimeEntryUpdateData instance,
) => <String, dynamic>{
  'date': instance.date?.toIso8601String(),
  'entryTime': instance.entryTime?.toIso8601String(),
  'exitTime': instance.exitTime?.toIso8601String(),
  'notes': instance.notes,
  'status': instance.status,
  'dailyRate': instance.dailyRate,
  'extraHours': instance.extraHours,
  'extraHoursRate': instance.extraHoursRate,
};

TimeEntryFilter _$TimeEntryFilterFromJson(Map<String, dynamic> json) =>
    TimeEntryFilter(
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      employeeId: json['employeeId'] as String?,
      status: $enumDecodeNullable(_$TimeEntryStatusEnumMap, json['status']),
      includeDetails: json['includeDetails'] as bool? ?? false,
    );

Map<String, dynamic> _$TimeEntryFilterToJson(TimeEntryFilter instance) =>
    <String, dynamic>{
      'startDate': instance.startDate.toIso8601String(),
      'endDate': instance.endDate.toIso8601String(),
      'employeeId': instance.employeeId,
      'status': instance.status,
      'includeDetails': instance.includeDetails,
    };
