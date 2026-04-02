// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_password_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UpdatePasswordDto _$UpdatePasswordDtoFromJson(Map<String, dynamic> json) =>
    UpdatePasswordDto(
      pwd: json['pwd'] as String,
      oldPwd: json['oldPwd'] as String,
      validated: json['validated'] as bool,
    );

Map<String, dynamic> _$UpdatePasswordDtoToJson(UpdatePasswordDto instance) =>
    <String, dynamic>{
      'pwd': instance.pwd,
      'oldPwd': instance.oldPwd,
      'validated': instance.validated,
    };
