import 'package:amex5/core/utils/result.dart';
import '../../data/models/sync_response_model.dart';
import '../../data/models/checklist_response_model.dart';

abstract interface class AgentWorksRepository {
  Future<Result<SyncResponseModel>> fetchAllWorks();
  Future<Result<ChecklistResponseModel>> fetchChecklist({
    required String woCode,
    required int act,
  });
}
