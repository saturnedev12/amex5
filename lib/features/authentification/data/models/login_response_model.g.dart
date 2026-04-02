// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'login_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LoginResponseModel _$LoginResponseModelFromJson(Map<String, dynamic> json) =>
    LoginResponseModel(
      token: json['token'] as String? ?? "",
      pwdToChange: json['pwdToChange'] as bool? ?? false,
      systemToken: json['systemToken'] as String?,
      docToken: json['docToken'] as String? ?? "",
      userGroup: json['userGroup'] as String? ?? "",
      profile: json['profile'] as String? ?? "",
      globalAdmin: json['globalAdmin'] as bool? ?? false,
      auths:
          (json['auths'] as List<dynamic>?)
              ?.map((e) => AuthModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      appData: json['appData'] == null
          ? null
          : AppDataModel.fromJson(json['appData'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$LoginResponseModelToJson(LoginResponseModel instance) =>
    <String, dynamic>{
      'token': instance.token,
      'pwdToChange': instance.pwdToChange,
      'systemToken': instance.systemToken,
      'docToken': instance.docToken,
      'userGroup': instance.userGroup,
      'profile': instance.profile,
      'globalAdmin': instance.globalAdmin,
      'auths': instance.auths,
      'appData': instance.appData,
    };
