import 'package:injectable/injectable.dart';
import 'package:amex5/core/base/base_repository.dart';
import 'package:amex5/core/utils/result.dart';
import '../../data/datasources/agent_works_remote_datasource.dart';
import '../../data/models/check_items_work.dart';
import '../../data/models/checklist_response_model.dart';
import '../../data/models/sync_response_model.dart';
import '../../data/models/wo_model.dart';

@lazySingleton
class AgentWorksRepository with SafeCallMixin {
  final AgentWorksRemoteDataSource _remote;

  AgentWorksRepository(this._remote);

  Future<Result<SyncResponseModel>> fetchAllWorks() {
    return safeCall(() => _remote.fetchAllWorks());
  }

  Future<Result<ChecklistResponseModel>> fetchChecklist({
    required String woCode,
    required int act,
  }) {
    return safeCall(() => _remote.fetchChecklist(woCode: woCode, act: act));
  }

  Future<Result<void>> sendWorkStatus(WoModel work) {
    return safeCall(() => _remote.sendWorkStatus(work));
  }

  Future<Result<void>> createCheckItemWo(CheckItemsWork body) {
    return safeCall(() => _remote.createCheckItemWo(body));
  }
}
