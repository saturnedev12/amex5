// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AuthModel _$AuthModelFromJson(Map<String, dynamic> json) => AuthModel(
  object: json['object'] as String? ?? "",
  clearance: json['clearance'] as String? ?? "",
  scopeType: json['scopeType'] as String? ?? "",
  scope: json['scope'] as String? ?? "",
);

Map<String, dynamic> _$AuthModelToJson(AuthModel instance) => <String, dynamic>{
  'object': instance.object,
  'clearance': instance.clearance,
  'scopeType': instance.scopeType,
  'scope': instance.scope,
};
