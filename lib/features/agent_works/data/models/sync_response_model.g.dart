// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sync_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SyncResponseModel _$SyncResponseModelFromJson(Map<String, dynamic> json) =>
    SyncResponseModel(
      dataUnitMap: json['dataUnitMap'] == null
          ? null
          : DataUnitMapModel.fromJson(
              json['dataUnitMap'] as Map<String, dynamic>,
            ),
      defaultParams: json['defaultParams'] as Map<String, dynamic>?,
      nextSyncDate: json['nextSyncDate'] as String?,
    );

Map<String, dynamic> _$SyncResponseModelToJson(SyncResponseModel instance) =>
    <String, dynamic>{
      'dataUnitMap': instance.dataUnitMap,
      'defaultParams': instance.defaultParams,
      'nextSyncDate': instance.nextSyncDate,
    };

DataUnitMapModel _$DataUnitMapModelFromJson(Map<String, dynamic> json) =>
    DataUnitMapModel(
      wo:
          (json['wo'] as List<dynamic>?)
              ?.map((e) => WoModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      uom: json['uom'] as List<dynamic>?,
      userData: json['userData'] as List<dynamic>?,
      woPart: json['woPart'] as List<dynamic>?,
      doc: json['doc'] as List<dynamic>?,
      finding: json['finding'] as List<dynamic>?,
      status: json['status'] as List<dynamic>?,
    );

Map<String, dynamic> _$DataUnitMapModelToJson(DataUnitMapModel instance) =>
    <String, dynamic>{
      'wo': instance.wo,
      'uom': instance.uom,
      'userData': instance.userData,
      'woPart': instance.woPart,
      'doc': instance.doc,
      'finding': instance.finding,
      'status': instance.status,
    };
