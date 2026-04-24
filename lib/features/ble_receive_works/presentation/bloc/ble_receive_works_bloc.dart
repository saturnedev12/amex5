import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import 'package:amex5/features/agent_works/data/models/wo_model.dart';
import 'package:amex5/core/ble/ble_service.dart';
import '../../domain/repositories/ble_receive_works_repository.dart';

// ── Statut d'envoi par travail ─────────────────────────────────────────────

enum WorkSendStatus { pending, sending, sent, error }

// ── Events ────────────────────────────────────────────────────────────────

sealed class BleReceiveWorksEvent {}

class BleReceiveSubmitAllEvent extends BleReceiveWorksEvent {}

class BleReceiveResetEvent extends BleReceiveWorksEvent {}

class _JsonReceivedEvent extends BleReceiveWorksEvent {
  final Map<String, dynamic> json;
  _JsonReceivedEvent(this.json);
}

class _BleErrorEvent extends BleReceiveWorksEvent {
  final String message;
  _BleErrorEvent(this.message);
}

// ── States ────────────────────────────────────────────────────────────────

sealed class BleReceiveWorksState {}

class BleReceiveIdle extends BleReceiveWorksState {}

class BleReceiveDataReady extends BleReceiveWorksState {
  final List<WoModel> works;
  final Map<String, WorkSendStatus> sendStatus;
  final bool isSubmitting;

  BleReceiveDataReady({
    required this.works,
    required this.sendStatus,
    this.isSubmitting = false,
  });

  bool get allSent =>
      sendStatus.isNotEmpty &&
      sendStatus.values.every((s) => s == WorkSendStatus.sent);

  bool get hasErrors => sendStatus.values.any((s) => s == WorkSendStatus.error);

  int get sentCount =>
      sendStatus.values.where((s) => s == WorkSendStatus.sent).length;

  BleReceiveDataReady copyWith({
    List<WoModel>? works,
    Map<String, WorkSendStatus>? sendStatus,
    bool? isSubmitting,
  }) => BleReceiveDataReady(
    works: works ?? this.works,
    sendStatus: sendStatus ?? this.sendStatus,
    isSubmitting: isSubmitting ?? this.isSubmitting,
  );
}

class BleReceiveError extends BleReceiveWorksState {
  final String message;
  BleReceiveError(this.message);
}

// ── BLoC ──────────────────────────────────────────────────────────────────

@injectable
class BleReceiveWorksBloc
    extends Bloc<BleReceiveWorksEvent, BleReceiveWorksState> {
  final BleReceiveWorksRepository _worksRepo;
  final BleService _bleService;
  StreamSubscription<Map<String, dynamic>>? _jsonSub;

  BleReceiveWorksBloc(this._worksRepo, this._bleService) : super(BleReceiveIdle()) {
    on<BleReceiveSubmitAllEvent>(_onSubmitAll);
    on<BleReceiveResetEvent>(_onReset);
    on<_JsonReceivedEvent>(_onJsonReceived);
    on<_BleErrorEvent>(_onBleError);

    _jsonSub = _bleService.receivedJsonStream.listen(
      (json) => add(_JsonReceivedEvent(json)),
      onError: (Object e) => add(_BleErrorEvent('Erreur réception : $e')),
    );
  }

  // ── Réception JSON ────────────────────────────────────────────────────────

  void _onJsonReceived(
    _JsonReceivedEvent event,
    Emitter<BleReceiveWorksState> emit,
  ) {
    final raw = event.json;

    // La datasource BLE encapsule les listes dans {'data': [...]}
    final List<dynamic> items;
    if (raw.containsKey('data') && raw['data'] is List) {
      items = raw['data'] as List<dynamic>;
    } else {
      // Objet unique — on le traite comme une liste d'un seul travail
      items = [raw];
    }

    try {
      final works = items
          .whereType<Map<String, dynamic>>()
          .map(WoModel.fromJson)
          .toList();

      if (works.isEmpty) {
        // Maybe it wasn't a work sync payload. We just ignore it instead of erroring out.
        return;
      }

      final sendStatus = <String, WorkSendStatus>{
        for (final w in works)
          if (w.woCode != null) w.woCode!: WorkSendStatus.pending,
      };

      emit(BleReceiveDataReady(works: works, sendStatus: sendStatus));
    } catch (e) {
      emit(BleReceiveError('Impossible de parser les travaux reçus : $e'));
    }
  }

  // ── Envoi vers l'API ──────────────────────────────────────────────────────

  Future<void> _onSubmitAll(
    BleReceiveSubmitAllEvent event,
    Emitter<BleReceiveWorksState> emit,
  ) async {
    final current = state;
    if (current is! BleReceiveDataReady) return;

    var s = current.copyWith(isSubmitting: true);
    emit(s);

    for (final wo in current.works) {
      final code = wo.woCode ?? '';
      // Ne pas renvoyer un travail déjà envoyé.
      if (s.sendStatus[code] == WorkSendStatus.sent) continue;

      s = s.copyWith(
        sendStatus: Map.of(s.sendStatus)..[code] = WorkSendStatus.sending,
      );
      emit(s);

      final result = await _worksRepo.submitWork(wo);

      s = s.copyWith(
        sendStatus: Map.of(
          s.sendStatus,
        )..[code] = result.isRight ? WorkSendStatus.sent : WorkSendStatus.error,
      );
      emit(s);
    }

    emit(s.copyWith(isSubmitting: false));
  }

  // ── Reset ───────────────────────────────────────────────────

  Future<void> _onReset(
    BleReceiveResetEvent event,
    Emitter<BleReceiveWorksState> emit,
  ) async {
    emit(BleReceiveIdle());
  }

  void _onBleError(_BleErrorEvent event, Emitter<BleReceiveWorksState> emit) {
    emit(BleReceiveError(event.message));
  }

  @override
  Future<void> close() async {
    await _jsonSub?.cancel();
    return super.close();
  }
}
