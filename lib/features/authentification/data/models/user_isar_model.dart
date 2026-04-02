import 'package:isar_community/isar.dart';

part 'user_isar_model.g.dart';

@collection
class UserIsarModel {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  String? username;

  String? token;
}
