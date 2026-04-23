import 'package:json_annotation/json_annotation.dart';
import 'status_model.dart';
import 'user_data.dart';

part 'dataunitmap.g.dart';

@JsonSerializable()
class DataUnitMap {
  final List<dynamic>? uom;
  final List<UserData>? userData;
  final List<dynamic>? finding;
  final List<StatusModel>? status;

  DataUnitMap({
    this.uom = const [],
    this.userData = const [],
    this.finding = const [],
    this.status = const [],
  });

  factory DataUnitMap.fromJson(Map<String, dynamic> json) => _$DataUnitMapFromJson(json);
  Map<String, dynamic> toJson() => _$DataUnitMapToJson(this);
}
