import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:amex5/core/database/isar_config.dart';
import 'package:amex5/core/session/session_manager.dart';

import 'injection.config.dart';

final getIt = GetIt.instance;

@InjectableInit()
Future<void> configureDependencies() async {
  getIt.init();

  await getIt<IsarConfig>().init();
  await getIt<SessionManager>().init();
}
