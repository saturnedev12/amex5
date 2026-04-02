import 'package:json_annotation/json_annotation.dart';

part 'update_password_dto.g.dart';

@JsonSerializable()
class UpdatePasswordDto {
  final String pwd;
  final String oldPwd;
  final bool validated;

  UpdatePasswordDto({
    required this.pwd,
    required this.oldPwd,
    required this.validated,
  });

  factory UpdatePasswordDto.fromJson(Map<String, dynamic> json) => _$UpdatePasswordDtoFromJson(json);
  Map<String, dynamic> toJson() => _$UpdatePasswordDtoToJson(this);
}
