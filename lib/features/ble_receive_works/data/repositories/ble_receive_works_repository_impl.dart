import 'package:injectable/injectable.dart';

import 'package:amex5/core/base/base_repository.dart';
import 'package:amex5/core/utils/result.dart';
import 'package:amex5/features/agent_works/data/models/wo_model.dart';

import '../../domain/repositories/ble_receive_works_repository.dart';
import '../datasources/ble_receive_remote_datasource.dart';

@LazySingleton(as: BleReceiveWorksRepository)
class BleReceiveWorksRepositoryImpl
    with SafeCallMixin
    implements BleReceiveWorksRepository {
  final BleReceiveRemoteDataSource _remote;

  BleReceiveWorksRepositoryImpl(this._remote);

  @override
  Future<Result<void>> submitWork(WoModel wo) =>
      safeCall(() => _remote.submitWork(wo));
}
