// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'checklist_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChecklistResponseModel _$ChecklistResponseModelFromJson(
  Map<String, dynamic> json,
) => ChecklistResponseModel(
  lastsaved: json['lastsaved'] as String?,
  checkItems:
      (json['checkItems'] as List<dynamic>?)
          ?.map((e) => TaskModel.fromJson(e as Map<String, dynamic>))
          .toList() ??
      [],
);

Map<String, dynamic> _$ChecklistResponseModelToJson(
  ChecklistResponseModel instance,
) => <String, dynamic>{
  'lastsaved': instance.lastsaved,
  'checkItems': instance.checkItems,
};
