import 'package:json_annotation/json_annotation.dart';
import 'task_model.dart';

part 'wo_model.g.dart';

@JsonSerializable()
class WoModel {
  final String? woCode;
  final int? act;
  final String? note;
  final String? trade;
  final String? range;
  final String? rangeDesc;
  final int? rangeRev;
  final int? persons;
  final double? est;
  final String? matlist;
  final int? matlrev;
  final String? workMan;
  final bool? completed;
  final String? heldBy;
  final String? device;
  final String? heldAt;
  final String? scheduldedStart;
  final String? start;
  final String? end;
  final String? specialSafetyInstrucutions;
  final String? lastsaved;
  final String? woDesc;
  final String? org;
  final String? object;
  final String? objectOrg;
  final String? woStatus;
  final String? woTarget;
  final String? woPriority;
  final String? woStartDate;
  final String? woCompletedDate;
  final String? ppm;
  final int? ppmrev;
  final String? objectDesc;
  final String? wmName;
  final String? scheduledStartHour;
  @JsonKey(defaultValue: [])
  final List<TaskModel>? checkListItems;
  final String? scheduledEnd;

  WoModel({
    this.woCode,
    this.act,
    this.note,
    this.trade,
    this.range,
    this.rangeDesc,
    this.rangeRev,
    this.persons,
    this.est,
    this.matlist,
    this.matlrev,
    this.workMan,
    this.completed,
    this.heldBy,
    this.device,
    this.heldAt,
    this.scheduldedStart,
    this.start,
    this.end,
    this.specialSafetyInstrucutions,
    this.lastsaved,
    this.woDesc,
    this.org,
    this.object,
    this.objectOrg,
    this.woStatus,
    this.woTarget,
    this.woPriority,
    this.woStartDate,
    this.woCompletedDate,
    this.ppm,
    this.ppmrev,
    this.objectDesc,
    this.wmName,
    this.scheduledStartHour,
    this.checkListItems,
    this.scheduledEnd,
  });

  factory WoModel.fromJson(Map<String, dynamic> json) =>
      _$WoModelFromJson(json);
  Map<String, dynamic> toJson() => _$WoModelToJson(this);
}
