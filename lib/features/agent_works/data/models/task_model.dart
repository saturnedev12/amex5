import 'package:json_annotation/json_annotation.dart';

part 'task_model.g.dart';

@JsonSerializable()
class TaskModel {
  final String? code;
  final int? sequence;
  final String? desc;
  final String? type;
  final String? requiredtoclose;
  final String? possiblefindings;
  final String? updated;
  final String? lastsaved;
  final bool? yes;
  final double? value;
  final String? finding;
  final String? notes;
  final String? uom;
  final bool? completed;
  final String? taskchecklistcode;
  final String? longLabel;
  final String? location;
  final double? min;
  final double? max;
  final String? filters;
  final String? alias;
  final String? validFindings;
  final String? checklistdate;
  final String? checklistdatetime;
  final String? freetext;

  TaskModel({
    this.code,
    this.sequence,
    this.desc,
    this.type,
    this.requiredtoclose,
    this.possiblefindings,
    this.updated,
    this.lastsaved,
    this.yes,
    this.value,
    this.finding,
    this.notes,
    this.uom,
    this.completed,
    this.taskchecklistcode,
    this.longLabel,
    this.location,
    this.min,
    this.max,
    this.filters,
    this.alias,
    this.validFindings,
    this.checklistdate,
    this.checklistdatetime,
    this.freetext,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) =>
      _$TaskModelFromJson(json);
  Map<String, dynamic> toJson() => _$TaskModelToJson(this);
}
