import 'package:amex5/core/utils/result.dart';
import 'package:amex5/features/agent_works/data/models/wo_model.dart';

abstract interface class BleReceiveWorksRepository {
  Future<Result<void>> submitWork(WoModel wo);
}
