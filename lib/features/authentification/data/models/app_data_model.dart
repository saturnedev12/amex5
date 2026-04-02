import 'package:json_annotation/json_annotation.dart';
import 'package:amex5/features/authentification/data/models/dataunitmap.dart';

part 'app_data_model.g.dart';

@JsonSerializable()
class AppDataModel {
  final String? nextSyncDate;
  final DataUnitMap? dataUnitMap;
  
  AppDataModel({
    this.nextSyncDate,
    this.dataUnitMap,
  });

  factory AppDataModel.fromJson(Map<String, dynamic> json) => _$AppDataModelFromJson(json);
  Map<String, dynamic> toJson() => _$AppDataModelToJson(this);
}
