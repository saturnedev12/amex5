import 'package:json_annotation/json_annotation.dart';

part 'user_data.g.dart';

@JsonSerializable()
class UserData {
  final String? code;
  final String employeeCode;
  final String name;
  final DateTime? lastsaved;
  final List<String>? trades;

  UserData({
    this.code,
    this.employeeCode = "",
    this.name = "",
    this.lastsaved,
    this.trades = const [],
  });

  factory UserData.fromJson(Map<String, dynamic> json) => _$UserDataFromJson(json);
  Map<String, dynamic> toJson() => _$UserDataToJson(this);
}
