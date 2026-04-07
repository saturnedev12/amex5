// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'login_body_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LoginBodyModel _$LoginBodyModelFromJson(Map<String, dynamic> json) =>
    LoginBodyModel(
      login: json['login'] as String,
      pwd: json['pwd'] as String,
      checkCode: json['checkCode'] as String,
      tokenRequired: json['tokenRequired'] as bool,
      authsRequired: json['authsRequired'] as bool,
      eamDocRequired: json['eamDocRequired'] as bool,
      userAsPerson: json['userAsPerson'] as bool,
      remoteRequestDate: json['remoteRequestDate'] as String,
      appData: json['appData'] as Map<String, dynamic>,
    );

Map<String, dynamic> _$LoginBodyModelToJson(LoginBodyModel instance) =>
    <String, dynamic>{
      'login': instance.login,
      'pwd': instance.pwd,
      'checkCode': instance.checkCode,
      'tokenRequired': instance.tokenRequired,
      'authsRequired': instance.authsRequired,
      'eamDocRequired': instance.eamDocRequired,
      'userAsPerson': instance.userAsPerson,
      'remoteRequestDate': instance.remoteRequestDate,
      'appData': instance.appData,
    };
