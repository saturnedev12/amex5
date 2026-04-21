import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import 'package:amex5/features/agent_works/data/models/wo_model.dart';
import 'package:amex5/features/ble_receiver/data/datasources/ble_data_source.dart';
import 'package:amex5/features/ble_receiver/data/repositories/ble_repository_impl.dart';
import 'package:amex5/features/ble_receiver/domain/entities/ble_device_entity.dart';
import 'package:amex5/features/ble_receiver/domain/repositories/ble_repository.dart';

import '../../domain/repositories/ble_receive_works_repository.dart';

// ── Statut d'envoi par travail ─────────────────────────────────────────────

enum WorkSendStatus { pending, sending, sent, error }

// ── Events ────────────────────────────────────────────────────────────────

sealed class BleReceiveWorksEvent {}

class BleReceiveStartScanEvent extends BleReceiveWorksEvent {}

class BleReceiveConnectEvent extends BleReceiveWorksEvent {
  final BleDeviceEntity device;
  BleReceiveConnectEvent(this.device);
}

class BleReceiveDisconnectEvent extends BleReceiveWorksEvent {}

class BleReceiveSubmitAllEvent extends BleReceiveWorksEvent {}

class BleReceiveResetEvent extends BleReceiveWorksEvent {}

// Événements internes — pilotés par les streams BLE.
class _DevicesUpdatedEvent extends BleReceiveWorksEvent {
  final List<BleDeviceEntity> devices;
  _DevicesUpdatedEvent(this.devices);
}

class _JsonReceivedEvent extends BleReceiveWorksEvent {
  final Map<String, dynamic> json;
  _JsonReceivedEvent(this.json);
}

class _ConnectionChangedEvent extends BleReceiveWorksEvent {
  final bool connected;
  _ConnectionChangedEvent(this.connected);
}

class _BleErrorEvent extends BleReceiveWorksEvent {
  final String message;
  _BleErrorEvent(this.message);
}

// ── States ────────────────────────────────────────────────────────────────

sealed class BleReceiveWorksState {}

/// État initial — prêt à scanner.
class BleReceiveIdle extends BleReceiveWorksState {}

/// Scan BLE en cours.
class BleReceiveScanning extends BleReceiveWorksState {
  final List<BleDeviceEntity> devices;
  BleReceiveScanning({this.devices = const []});

  BleReceiveScanning copyWith({List<BleDeviceEntity>? devices}) =>
      BleReceiveScanning(devices: devices ?? this.devices);
}

/// Connexion en cours vers un appareil.
class BleReceiveConnecting extends BleReceiveWorksState {
  final BleDeviceEntity device;
  BleReceiveConnecting(this.device);
}

/// Connecté, en attente de réception des données JSON.
class BleReceiveListening extends BleReceiveWorksState {
  final BleDeviceEntity device;
  BleReceiveListening(this.device);
}

/// Données reçues — prêt pour validation et envoi.
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

/// Erreur BLE ou parsing.
class BleReceiveError extends BleReceiveWorksState {
  final String message;
  BleReceiveError(this.message);
}

// ── BLoC ──────────────────────────────────────────────────────────────────

@injectable
class BleReceiveWorksBloc
    extends Bloc<BleReceiveWorksEvent, BleReceiveWorksState> {
  late final BleRepository _bleRepo;
  final BleReceiveWorksRepository _worksRepo;

  StreamSubscription<List<BleDeviceEntity>>? _scanSub;
  StreamSubscription<Map<String, dynamic>>? _jsonSub;
  StreamSubscription<bool>? _connSub;

  BleReceiveWorksBloc(this._worksRepo) : super(BleReceiveIdle()) {
    _bleRepo = BleRepositoryImpl(WindowsBleClientDataSource());

    on<BleReceiveStartScanEvent>(_onStartScan);
    on<BleReceiveConnectEvent>(_onConnect);
    on<BleReceiveDisconnectEvent>(_onDisconnect);
    on<BleReceiveSubmitAllEvent>(_onSubmitAll);
    on<BleReceiveResetEvent>(_onReset);
    on<_DevicesUpdatedEvent>(_onDevicesUpdated);
    on<_JsonReceivedEvent>(_onJsonReceived);
    on<_ConnectionChangedEvent>(_onConnectionChanged);
    on<_BleErrorEvent>(_onBleError);
  }

  // ── Scan ──────────────────────────────────────────────────────────────────

  Future<void> _onStartScan(
    BleReceiveStartScanEvent event,
    Emitter<BleReceiveWorksState> emit,
  ) async {
    emit(BleReceiveScanning());
    await _scanSub?.cancel();
    _scanSub = _bleRepo.scanResultsStream.listen(
      (devices) => add(_DevicesUpdatedEvent(devices)),
      onError: (Object e) => add(_BleErrorEvent('Erreur scan : $e')),
    );
    try {
      await _bleRepo.startScan();
    } catch (e) {
      add(_BleErrorEvent('Scan impossible : $e'));
    }
  }

  void _onDevicesUpdated(
    _DevicesUpdatedEvent event,
    Emitter<BleReceiveWorksState> emit,
  ) {
    if (state is BleReceiveScanning) {
      emit((state as BleReceiveScanning).copyWith(devices: event.devices));
    }
  }

  // ── Connexion ─────────────────────────────────────────────────────────────

  Future<void> _onConnect(
    BleReceiveConnectEvent event,
    Emitter<BleReceiveWorksState> emit,
  ) async {
    await _scanSub?.cancel();
    _scanSub = null;
    await _bleRepo.stopScan();

    emit(BleReceiveConnecting(event.device));

    await _jsonSub?.cancel();
    _jsonSub = _bleRepo.receivedJsonStream.listen(
      (json) => add(_JsonReceivedEvent(json)),
      onError: (Object e) => add(_BleErrorEvent('Erreur réception : $e')),
    );

    await _connSub?.cancel();
    _connSub = _bleRepo.connectionStateStream.listen(
      (connected) => add(_ConnectionChangedEvent(connected)),
    );

    try {
      await _bleRepo.connectToDevice(event.device);
      emit(BleReceiveListening(event.device));
    } catch (e) {
      await _jsonSub?.cancel();
      await _connSub?.cancel();
      _jsonSub = null;
      _connSub = null;
      emit(BleReceiveError('Connexion échouée : $e'));
    }
  }

  void _onConnectionChanged(
    _ConnectionChangedEvent event,
    Emitter<BleReceiveWorksState> emit,
  ) {
    // Une déconnexion inattendue n'est critique que si on attend encore des données.
    if (!event.connected && state is BleReceiveListening) {
      emit(BleReceiveError('Connexion Bluetooth perdue'));
    }
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
        emit(BleReceiveError('Aucun travail valide dans les données reçues.'));
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

  // ── Reset / Déconnexion ───────────────────────────────────────────────────

  Future<void> _onDisconnect(
    BleReceiveDisconnectEvent event,
    Emitter<BleReceiveWorksState> emit,
  ) async {
    await _cleanup();
    emit(BleReceiveIdle());
  }

  Future<void> _onReset(
    BleReceiveResetEvent event,
    Emitter<BleReceiveWorksState> emit,
  ) async {
    await _cleanup();
    emit(BleReceiveIdle());
  }

  void _onBleError(_BleErrorEvent event, Emitter<BleReceiveWorksState> emit) {
    emit(BleReceiveError(event.message));
  }

  // ── Nettoyage ─────────────────────────────────────────────────────────────

  Future<void> _cleanup() async {
    await _scanSub?.cancel();
    await _jsonSub?.cancel();
    await _connSub?.cancel();
    _scanSub = null;
    _jsonSub = null;
    _connSub = null;
    try {
      await _bleRepo.disconnect();
    } catch (_) {}
  }

  @override
  Future<void> close() async {
    await _cleanup();
    _bleRepo.dispose();
    return super.close();
  }
}
