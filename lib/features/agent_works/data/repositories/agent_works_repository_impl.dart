import 'package:injectable/injectable.dart';
import 'package:amex5/core/base/base_repository.dart';
import 'package:amex5/core/utils/result.dart';
import '../../domain/repositories/agent_works_repository.dart';
import '../datasources/agent_works_remote_datasource.dart';
import '../models/sync_response_model.dart';
import '../models/checklist_response_model.dart';

@LazySingleton(as: AgentWorksRepository)
class AgentWorksRepositoryImpl
    with SafeCallMixin
    implements AgentWorksRepository {
  final AgentWorksRemoteDataSource _remote;

  AgentWorksRepositoryImpl(this._remote);

  @override
  Future<Result<SyncResponseModel>> fetchAllWorks() =>
      safeCall(() => _remote.fetchAllWorks());

  @override
  Future<Result<ChecklistResponseModel>> fetchChecklist({
    required String woCode,
    required int act,
  }) => safeCall(() => _remote.fetchChecklist(woCode: woCode, act: act));
}
