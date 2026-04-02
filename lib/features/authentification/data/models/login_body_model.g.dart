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
    );

Map<String, dynamic> _$LoginBodyModelToJson(LoginBodyModel instance) =>
    <String, dynamic>{
      'login': instance.login,
      'pwd': instance.pwd,
      'checkCode': instance.checkCode,
    };
