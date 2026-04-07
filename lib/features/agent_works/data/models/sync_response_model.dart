import 'package:json_annotation/json_annotation.dart';
import 'wo_model.dart';

part 'sync_response_model.g.dart';

@JsonSerializable()
class SyncResponseModel {
  final DataUnitMapModel? dataUnitMap;
  final Map<String, dynamic>? defaultParams;
  final String? nextSyncDate;

  SyncResponseModel({this.dataUnitMap, this.defaultParams, this.nextSyncDate});

  factory SyncResponseModel.fromJson(Map<String, dynamic> json) =>
      _$SyncResponseModelFromJson(json);
  Map<String, dynamic> toJson() => _$SyncResponseModelToJson(this);
}

@JsonSerializable()
class DataUnitMapModel {
  @JsonKey(defaultValue: [])
  final List<WoModel>? wo;
  final List<dynamic>? uom;
  final List<dynamic>? userData;
  final List<dynamic>? woPart;
  final List<dynamic>? doc;
  final List<dynamic>? finding;
  final List<dynamic>? status;

  DataUnitMapModel({
    this.wo,
    this.uom,
    this.userData,
    this.woPart,
    this.doc,
    this.finding,
    this.status,
  });

  factory DataUnitMapModel.fromJson(Map<String, dynamic> json) =>
      _$DataUnitMapModelFromJson(json);
  Map<String, dynamic> toJson() => _$DataUnitMapModelToJson(this);
}
