import 'package:json_annotation/json_annotation.dart';
import 'task_model.dart';

part 'checklist_response_model.g.dart';

@JsonSerializable()
class ChecklistResponseModel {
  final String? lastsaved;
  @JsonKey(defaultValue: [])
  final List<TaskModel>? checkItems;

  ChecklistResponseModel({this.lastsaved, this.checkItems});

  factory ChecklistResponseModel.fromJson(Map<String, dynamic> json) =>
      _$ChecklistResponseModelFromJson(json);
  Map<String, dynamic> toJson() => _$ChecklistResponseModelToJson(this);
}
