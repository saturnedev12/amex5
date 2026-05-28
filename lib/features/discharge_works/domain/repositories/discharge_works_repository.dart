import 'package:injectable/injectable.dart';
import 'package:amex5/core/base/base_repository.dart';
import 'package:amex5/core/utils/result.dart';
import '../../data/datasources/discharge_works_remote_datasource.dart';
import '../entities/discharge_entities.dart';

@lazySingleton
class DischargeWorksRepository with SafeCallMixin {
  final DischargeWorksRemoteDataSource _remote;

  DischargeWorksRepository(this._remote);

  Future<Result<DischargeUploadResult>> uploadDischargeWorks(
    Map<String, dynamic> payload,
  ) {
    return safeCall(() => _remote.uploadDischargeWorks(payload));
  }
}
