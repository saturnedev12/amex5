import 'package:json_annotation/json_annotation.dart';

part 'auth_model.g.dart';

@JsonSerializable()
class AuthModel {
  final String? object;
  final String? clearance;
  final String? scopeType;
  final String? scope;

  AuthModel({
    this.object = "",
    this.clearance = "",
    this.scopeType = "",
    this.scope = "",
  });

  factory AuthModel.fromJson(Map<String, dynamic> json) => _$AuthModelFromJson(json);
  Map<String, dynamic> toJson() => _$AuthModelToJson(this);
}
