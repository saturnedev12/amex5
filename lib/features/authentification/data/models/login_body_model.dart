import 'package:json_annotation/json_annotation.dart';

part 'login_body_model.g.dart';

@JsonSerializable()
class LoginBodyModel {
  final String login;
  final String pwd;
  final String checkCode;
  final bool tokenRequired;
  final bool authsRequired;
  final bool eamDocRequired;
  final bool userAsPerson;
  final String remoteRequestDate;
  final Map<String, dynamic> appData;

  LoginBodyModel({
    required this.login,
    required this.pwd,
    required this.checkCode,
    required this.tokenRequired,
    required this.authsRequired,
    required this.eamDocRequired,
    required this.userAsPerson,
    required this.remoteRequestDate,
    required this.appData,
  });

  factory LoginBodyModel.fromJson(Map<String, dynamic> json) =>
      _$LoginBodyModelFromJson(json);
  Map<String, dynamic> toJson() => _$LoginBodyModelToJson(this);
}
