// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_data_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AppDataModel _$AppDataModelFromJson(Map<String, dynamic> json) => AppDataModel(
  nextSyncDate: json['nextSyncDate'] as String?,
  syncPeriod: (json['syncPeriod'] as num?)?.toDouble(),
  defaultParams: json['defaultParams'] as Map<String, dynamic>?,
  dataUnitMap: json['dataUnitMap'] == null
      ? null
      : DataUnitMap.fromJson(json['dataUnitMap'] as Map<String, dynamic>),
);

Map<String, dynamic> _$AppDataModelToJson(AppDataModel instance) =>
    <String, dynamic>{
      'nextSyncDate': instance.nextSyncDate,
      'syncPeriod': instance.syncPeriod,
      'defaultParams': instance.defaultParams,
      'dataUnitMap': instance.dataUnitMap,
    };
