import 'package:json_annotation/json_annotation.dart';

part 'login_body_model.g.dart';

@JsonSerializable()
class LoginBodyModel {
  final String login;
  final String pwd;
  final String checkCode;

  LoginBodyModel({
    required this.login,
    required this.pwd,
    required this.checkCode,
  });

  factory LoginBodyModel.fromJson(Map<String, dynamic> json) => _$LoginBodyModelFromJson(json);
  Map<String, dynamic> toJson() => _$LoginBodyModelToJson(this);
}
