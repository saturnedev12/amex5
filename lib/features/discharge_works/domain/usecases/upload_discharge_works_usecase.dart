import '../../../../core/base/base_usecase.dart';
import '../../../../core/utils/result.dart';
import '../entities/discharge_entities.dart';
import '../repositories/discharge_works_repository.dart';

class UploadDischargeWorksUseCase
    extends UseCase<DischargeUploadResult, Map<String, dynamic>> {
  final DischargeWorksRepository _repository;

  UploadDischargeWorksUseCase(this._repository);

  @override
  Future<Result<DischargeUploadResult>> call(Map<String, dynamic> payload) =>
      _repository.uploadDischargeWorks(payload);
}
