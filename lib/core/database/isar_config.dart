import 'package:injectable/injectable.dart';
import 'package:isar_community/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:amex5/features/authentification/data/models/user_isar_model.dart';

@singleton
class IsarConfig {
  late final Isar _isar;

  Future<void> init() async {
    _isar = await Isar.open(
      [UserIsarModelSchema],
      name: 'myInstance',
      directory: await getApplicationDocumentsDirectory().then(
        (dir) => dir.path,
      ),
    );
  }

  Isar get instance {
    return _isar;
  }
}
