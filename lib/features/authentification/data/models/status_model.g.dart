// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'status_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StatusModel _$StatusModelFromJson(Map<String, dynamic> json) => StatusModel(
  code: json['code'] as String,
  label: json['label'] as String,
  category: json['category'] as String,
  notUsed: json['notUsed'] as bool,
  defaultInCategory: json['defaultInCategory'] as bool,
  lastsaved: DateTime.parse(json['lastsaved'] as String),
);

Map<String, dynamic> _$StatusModelToJson(StatusModel instance) =>
    <String, dynamic>{
      'code': instance.code,
      'label': instance.label,
      'category': instance.category,
      'notUsed': instance.notUsed,
      'defaultInCategory': instance.defaultInCategory,
      'lastsaved': instance.lastsaved.toIso8601String(),
    };
