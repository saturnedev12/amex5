import '../../../../core/utils/result.dart';
import '../entities/discharge_entities.dart';

abstract interface class DischargeWorksRepository {
  Future<Result<DischargeUploadResult>> uploadDischargeWorks(
    Map<String, dynamic> payload,
  );
}
