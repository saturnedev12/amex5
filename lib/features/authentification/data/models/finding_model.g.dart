// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'finding_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FindingModel _$FindingModelFromJson(Map<String, dynamic> json) => FindingModel(
  code: json['code'] as String? ?? "",
  label: json['label'] as String? ?? "",
  lastUpdateAt: json['lastUpdateAt'] == null
      ? null
      : DateTime.parse(json['lastUpdateAt'] as String),
);

Map<String, dynamic> _$FindingModelToJson(FindingModel instance) =>
    <String, dynamic>{
      'code': instance.code,
      'label': instance.label,
      'lastUpdateAt': instance.lastUpdateAt?.toIso8601String(),
    };
