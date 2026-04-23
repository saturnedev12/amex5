// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dataunitmap.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DataUnitMap _$DataUnitMapFromJson(Map<String, dynamic> json) => DataUnitMap(
  uom: json['uom'] as List<dynamic>? ?? const [],
  userData:
      (json['userData'] as List<dynamic>?)
          ?.map((e) => UserData.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  finding: json['finding'] as List<dynamic>? ?? const [],
  status:
      (json['status'] as List<dynamic>?)
          ?.map((e) => StatusModel.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
);

Map<String, dynamic> _$DataUnitMapToJson(DataUnitMap instance) =>
    <String, dynamic>{
      'uom': instance.uom,
      'userData': instance.userData,
      'finding': instance.finding,
      'status': instance.status,
    };
