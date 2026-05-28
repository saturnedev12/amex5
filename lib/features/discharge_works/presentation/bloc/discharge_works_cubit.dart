import 'dart:async';
import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:amex5/core/ble/ble_service.dart';
import 'package:amex5/features/agent_works/data/models/check_items_work.dart';
import 'package:amex5/features/agent_works/data/models/wo_model.dart';
import 'package:amex5/features/agent_works/domain/repositories/agent_works_repository.dart';

import '../../domain/entities/discharge_entities.dart';

class DischargeWorksCubit extends Cubit<DischargeWorksCubitState> {
  final AgentWorksRepository _repository;
  final BleService _bleService;
  StreamSubscription<Map<String, dynamic>>? _jsonSubscription;

  DischargeWorksCubit(this._repository, this._bleService)
    : super(const DischargeWorksCubitState()) {
    _jsonSubscription = _bleService.receivedJsonStream.listen(
      receiveJson,
      onError: (Object error) =>
          emit(state.copyWith(errorMessage: 'Erreur réception BLE : $error')),
    );
  }

  void receiveJson(Map<String, dynamic> json) {
    try {
      final directWorks = _readList(json, const ['WORKS', 'works']);
      final nestedWorks = _readNestedList(json, 'UPPLOAD_WORK', const [
        'wo',
        'WORKS',
      ]);
      final directCheckItems = _readList(json, const [
        'CHECK_ITEMS_WORKS',
        'checkItemsWorks',
        'check_items_works',
      ]);
      final nestedCheckItems = _readNestedList(json, 'UPPLOAD_WORK', const [
        'checkItems',
      ]);

      final hasKnownPayload =
          directWorks != null ||
          nestedWorks != null ||
          directCheckItems != null ||
          nestedCheckItems != null;
      if (!hasKnownPayload) {
        throw const FormatException(
          'Clés WORKS ou CHECK_ITEMS_WORKS introuvables.',
        );
      }

      final worksRaw = directWorks ?? nestedWorks ?? const <dynamic>[];
      final checkItemsRaw =
          directCheckItems ?? nestedCheckItems ?? const <dynamic>[];

      final works = worksRaw.asMap().entries.map((entry) {
        final work = WoModel.fromJson(_toStringMap(entry.value));
        return DischargeWorkLine(
          id: 'work-${entry.key}-${work.woCode ?? 'no-code'}',
          index: entry.key,
          work: work,
        );
      }).toList();

      final checkItemsWorks = checkItemsRaw.asMap().entries.map((entry) {
        final checkItem = CheckItemsWork.fromJson(_toStringMap(entry.value));
        return DischargeCheckItemLine(
          id: 'check-${entry.key}-${checkItem.checkItemCode ?? checkItem.woMobileUuid ?? 'no-code'}',
          index: entry.key,
          checkItem: checkItem,
        );
      }).toList();

      final sizeBytes = utf8.encode(jsonEncode(json)).length;
      emit(
        DischargeWorksCubitState(
          payload: DischargePayload(
            rawJson: json,
            works: works,
            checkItemsWorks: checkItemsWorks,
            sizeBytes: sizeBytes,
            receivedAt: DateTime.now(),
          ),
          successMessage:
              'Données reçues : ${works.length} travaux, ${checkItemsWorks.length} check items.',
        ),
      );
    } on FormatException catch (error) {
      emit(
        state.copyWith(
          errorMessage: 'JSON de déchargement invalide : ${error.message}',
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          errorMessage: 'Impossible de parser les données reçues : $error',
        ),
      );
    }
  }

  Future<void> uploadWork(String id) async {
    final payload = state.payload;
    if (payload == null) return;

    final line = payload.works.where((item) => item.id == id).firstOrNull;
    if (line == null) return;

    emit(
      _replaceWorkLine(
        state.copyWith(clearError: true, clearSuccess: true),
        line.copyWith(status: DischargeUploadStatus.sending, clearError: true),
      ),
    );

    final result = await _repository.sendWorkStatus(line.work);
    result.fold(
      (failure) => emit(
        _replaceWorkLine(
          state,
          line.copyWith(
            status: DischargeUploadStatus.error,
            errorMessage: failure.message,
          ),
        ).copyWith(errorMessage: failure.message),
      ),
      (_) => emit(
        _replaceWorkLine(
          state,
          line.copyWith(status: DischargeUploadStatus.sent, clearError: true),
        ),
      ),
    );
  }

  Future<void> uploadCheckItem(String id) async {
    final payload = state.payload;
    if (payload == null) return;

    final line = payload.checkItemsWorks
        .where((item) => item.id == id)
        .firstOrNull;
    if (line == null) return;

    emit(
      _replaceCheckItemLine(
        state.copyWith(clearError: true, clearSuccess: true),
        line.copyWith(status: DischargeUploadStatus.sending, clearError: true),
      ),
    );

    final result = await _repository.createCheckItemWo(line.checkItem);
    result.fold(
      (failure) => emit(
        _replaceCheckItemLine(
          state,
          line.copyWith(
            status: DischargeUploadStatus.error,
            errorMessage: failure.message,
          ),
        ).copyWith(errorMessage: failure.message),
      ),
      (_) => emit(
        _replaceCheckItemLine(
          state,
          line.copyWith(status: DischargeUploadStatus.sent, clearError: true),
        ),
      ),
    );
  }

  Future<void> uploadAll() async {
    final payload = state.payload;
    if (payload == null || state.isUploadingAll) return;

    emit(
      state.copyWith(
        isUploadingAll: true,
        clearError: true,
        clearSuccess: true,
      ),
    );

    for (final line in payload.works) {
      final current = state.payload?.works
          .where((item) => item.id == line.id)
          .firstOrNull;
      if (current == null || current.status == DischargeUploadStatus.sent) {
        continue;
      }
      await uploadWork(line.id);
    }

    for (final line in payload.checkItemsWorks) {
      final current = state.payload?.checkItemsWorks
          .where((item) => item.id == line.id)
          .firstOrNull;
      if (current == null || current.status == DischargeUploadStatus.sent) {
        continue;
      }
      await uploadCheckItem(line.id);
    }

    final latestPayload = state.payload;
    final errorCount = latestPayload?.errorCount ?? 0;
    emit(
      state.copyWith(
        isUploadingAll: false,
        successMessage: errorCount == 0
            ? 'Tous les éléments ont été envoyés.'
            : null,
        errorMessage: errorCount == 0
            ? null
            : '$errorCount élément(s) en erreur pendant l\'envoi.',
        clearSuccess: errorCount != 0,
        clearError: errorCount == 0,
      ),
    );
  }

  void resetPayload() {
    emit(const DischargeWorksCubitState());
  }

  DischargeWorksCubitState _replaceWorkLine(
    DischargeWorksCubitState source,
    DischargeWorkLine updatedLine,
  ) {
    final payload = source.payload;
    if (payload == null) return source;
    final works = payload.works
        .map((line) => line.id == updatedLine.id ? updatedLine : line)
        .toList();
    return source.copyWith(payload: payload.copyWith(works: works));
  }

  DischargeWorksCubitState _replaceCheckItemLine(
    DischargeWorksCubitState source,
    DischargeCheckItemLine updatedLine,
  ) {
    final payload = source.payload;
    if (payload == null) return source;
    final checkItems = payload.checkItemsWorks
        .map((line) => line.id == updatedLine.id ? updatedLine : line)
        .toList();
    return source.copyWith(
      payload: payload.copyWith(checkItemsWorks: checkItems),
    );
  }

  List<dynamic>? _readNestedList(
    Map<String, dynamic> json,
    String parentKey,
    List<String> childKeys,
  ) {
    final parent = json[parentKey];
    if (parent is! Map) return null;
    return _readList(_toStringMap(parent), childKeys);
  }

  List<dynamic>? _readList(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      final value = json[key];
      if (value is List) return value;
    }
    return null;
  }

  Map<String, dynamic> _toStringMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) {
      return value.map((key, value) => MapEntry(key.toString(), value));
    }
    throw FormatException('Objet JSON attendu, reçu ${value.runtimeType}.');
  }

  @override
  Future<void> close() async {
    await _jsonSubscription?.cancel();
    return super.close();
  }
}

class DischargeWorksCubitState {
  final DischargePayload? payload;
  final bool isUploadingAll;
  final String? errorMessage;
  final String? successMessage;

  const DischargeWorksCubitState({
    this.payload,
    this.isUploadingAll = false,
    this.errorMessage,
    this.successMessage,
  });

  bool get hasPayload => payload != null;
  bool get canUploadAll =>
      payload != null && !isUploadingAll && !payload!.allSent;

  DischargeWorksCubitState copyWith({
    DischargePayload? payload,
    bool? isUploadingAll,
    String? errorMessage,
    String? successMessage,
    bool clearError = false,
    bool clearSuccess = false,
  }) {
    return DischargeWorksCubitState(
      payload: payload ?? this.payload,
      isUploadingAll: isUploadingAll ?? this.isUploadingAll,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      successMessage: clearSuccess
          ? null
          : (successMessage ?? this.successMessage),
    );
  }
}
