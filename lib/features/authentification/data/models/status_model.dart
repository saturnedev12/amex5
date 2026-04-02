import 'package:json_annotation/json_annotation.dart';

part 'status_model.g.dart';

@JsonSerializable()
class StatusModel {
  final String code;
  final String label;
  final String category;
  final bool notUsed;
  final bool defaultInCategory;
  final DateTime lastsaved;

  StatusModel({
    required this.code,
    required this.label,
    required this.category,
    required this.notUsed,
    required this.defaultInCategory,
    required this.lastsaved,
  });

  factory StatusModel.fromJson(Map<String, dynamic> json) => _$StatusModelFromJson(json);
  Map<String, dynamic> toJson() => _$StatusModelToJson(this);
}
