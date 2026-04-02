import 'package:json_annotation/json_annotation.dart';
import 'app_data_model.dart';
import 'auth_model.dart';

part 'login_response_model.g.dart';

@JsonSerializable()
class LoginResponseModel {
  final String? token;
  final bool? pwdToChange;
  final String? systemToken;
  final String? docToken;
  final String? userGroup;
  final String? profile;
  final bool? globalAdmin;
  final List<AuthModel>? auths;
  final AppDataModel? appData;

  LoginResponseModel({
    this.token = "",
    this.pwdToChange = false,
    this.systemToken,
    this.docToken = "",
    this.userGroup = "",
    this.profile = "",
    this.globalAdmin = false,
    this.auths = const [],
    this.appData,
  });

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) => _$LoginResponseModelFromJson(json);
  Map<String, dynamic> toJson() => _$LoginResponseModelToJson(this);
}
