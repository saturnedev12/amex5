import 'package:injectable/injectable.dart';
import '../../../../core/base/base_repository.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/discharge_entities.dart';
import '../../domain/repositories/discharge_works_repository.dart';
import '../datasources/discharge_works_remote_datasource.dart';

@LazySingleton(as: DischargeWorksRepository)
class DischargeWorksRepositoryImpl
    with SafeCallMixin
    implements DischargeWorksRepository {
  final DischargeWorksRemoteDataSource _remote;

  DischargeWorksRepositoryImpl(this._remote);

  @override
  Future<Result<DischargeUploadResult>> uploadDischargeWorks(
    Map<String, dynamic> payload,
  ) => safeCall(() => _remote.uploadDischargeWorks(payload));
}
