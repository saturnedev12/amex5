import 'package:json_annotation/json_annotation.dart';

part 'finding_model.g.dart';

@JsonSerializable()
class FindingModel {
  final String? code;
  final String? label;
  final DateTime? lastUpdateAt;

  FindingModel({
    this.code = "",
    this.label = "",
    this.lastUpdateAt,
  });

  factory FindingModel.fromJson(Map<String, dynamic> json) => _$FindingModelFromJson(json);
  Map<String, dynamic> toJson() => _$FindingModelToJson(this);
}
