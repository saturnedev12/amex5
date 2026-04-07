// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TaskModel _$TaskModelFromJson(Map<String, dynamic> json) => TaskModel(
  code: json['code'] as String?,
  sequence: (json['sequence'] as num?)?.toInt(),
  desc: json['desc'] as String?,
  type: json['type'] as String?,
  requiredtoclose: json['requiredtoclose'] as String?,
  possiblefindings: json['possiblefindings'] as String?,
  updated: json['updated'] as String?,
  lastsaved: json['lastsaved'] as String?,
  yes: json['yes'] as bool?,
  value: (json['value'] as num?)?.toDouble(),
  finding: json['finding'] as String?,
  notes: json['notes'] as String?,
  uom: json['uom'] as String?,
  completed: json['completed'] as bool?,
  taskchecklistcode: json['taskchecklistcode'] as String?,
  longLabel: json['longLabel'] as String?,
  location: json['location'] as String?,
  min: (json['min'] as num?)?.toDouble(),
  max: (json['max'] as num?)?.toDouble(),
  filters: json['filters'] as String?,
  alias: json['alias'] as String?,
  validFindings: json['validFindings'] as String?,
  checklistdate: json['checklistdate'] as String?,
  checklistdatetime: json['checklistdatetime'] as String?,
  freetext: json['freetext'] as String?,
);

Map<String, dynamic> _$TaskModelToJson(TaskModel instance) => <String, dynamic>{
  'code': instance.code,
  'sequence': instance.sequence,
  'desc': instance.desc,
  'type': instance.type,
  'requiredtoclose': instance.requiredtoclose,
  'possiblefindings': instance.possiblefindings,
  'updated': instance.updated,
  'lastsaved': instance.lastsaved,
  'yes': instance.yes,
  'value': instance.value,
  'finding': instance.finding,
  'notes': instance.notes,
  'uom': instance.uom,
  'completed': instance.completed,
  'taskchecklistcode': instance.taskchecklistcode,
  'longLabel': instance.longLabel,
  'location': instance.location,
  'min': instance.min,
  'max': instance.max,
  'filters': instance.filters,
  'alias': instance.alias,
  'validFindings': instance.validFindings,
  'checklistdate': instance.checklistdate,
  'checklistdatetime': instance.checklistdatetime,
  'freetext': instance.freetext,
};
