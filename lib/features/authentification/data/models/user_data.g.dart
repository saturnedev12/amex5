// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserData _$UserDataFromJson(Map<String, dynamic> json) => UserData(
  employeeCode: json['employeeCode'] as String? ?? "",
  name: json['name'] as String? ?? "",
  lastsaved: json['lastsaved'] == null
      ? null
      : DateTime.parse(json['lastsaved'] as String),
  trades:
      (json['trades'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
);

Map<String, dynamic> _$UserDataToJson(UserData instance) => <String, dynamic>{
  'employeeCode': instance.employeeCode,
  'name': instance.name,
  'lastsaved': instance.lastsaved?.toIso8601String(),
  'trades': instance.trades,
};
