import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/datasources/ble_data_source.dart';
import '../../data/repositories/ble_repository_impl.dart';
import '../../domain/entities/ble_device_entity.dart';
import '../../domain/repositories/ble_repository.dart';

// ── Events ────────────────────────────────────────────────────────────────

sealed class BleEvent {}

/// Lance un scan BLE de 15 secondes.
class BleScanStartEvent extends BleEvent {}

/// Arrête le scan en cours et revient à l'état initial.
class BleStopScanEvent extends BleEvent {}

/// Initie la connexion vers l'appareil sélectionné.
class BleConnectDeviceEvent extends BleEvent {
  final BleDeviceEntity device;
  BleConnectDeviceEvent(this.device);
}

/// Déconnecte l'appareil connecté.
class BleDisconnectEvent extends BleEvent {}

/// Envoie un JSON vers l'Android connecté (chunked).
class BleSendJsonEvent extends BleEvent {
  final Map<String, dynamic> data;
  BleSendJsonEvent(this.data);
}

/// Réinitialise vers l'état initial.
class BleResetEvent extends BleEvent {}

// Événements internes — pilotés par les streams de la datasource.
class _DevicesUpdatedEvent extends BleEvent {
  final List<BleDeviceEntity> devices;
  _DevicesUpdatedEvent(this.devices);
}

class _JsonReceivedEvent extends BleEvent {
  final Map<String, dynamic> json;
  _JsonReceivedEvent(this.json);
}

class _ConnectionChangedEvent extends BleEvent {
  final bool connected;
  _ConnectionChangedEvent(this.connected);
}

class _ErrorOccurredEvent extends BleEvent {
  final String message;
  _ErrorOccurredEvent(this.message);
}

// ── States ────────────────────────────────────────────────────────────────

sealed class BleState {}

/// État initial — aucun scan, aucune connexion.
class BleInitial extends BleState {}

/// Scan en cours — liste des appareils découverts mise à jour en temps réel.
class BleScanning extends BleState {
  final List<BleDeviceEntity> devices;
  BleScanning({this.devices = const []});

  BleScanning copyWith({List<BleDeviceEntity>? devices}) =>
      BleScanning(devices: devices ?? this.devices);
}

/// Connexion en cours vers un appareil.
class BleConnecting extends BleState {
  final BleDeviceEntity device;
  BleConnecting(this.device);
}

/// Connecté — échanges JSON actifs, historique disponible.
class BleConnected extends BleState {
  final BleDeviceEntity device;
  final List<BleJsonRecord> history;

  BleConnected({required this.device, this.history = const []});

  BleConnected copyWith({
    BleDeviceEntity? device,
    List<BleJsonRecord>? history,
  }) => BleConnected(
        device: device ?? this.device,
        history: history ?? this.history,
      );
}

/// Envoi JSON en cours (chunking).
class BleSending extends BleState {
  final BleDeviceEntity device;
  final List<BleJsonRecord> history;
  BleSending({required this.device, this.history = const []});
}

/// Déconnecté (volontairement ou inattendu).
class BleDisconnected extends BleState {
  final String? reason;
  BleDisconnected({this.reason});
}

/// Erreur BLE.
class BleError extends BleState {
  final String message;
  BleError(this.message);
}

// ── BLoC ──────────────────────────────────────────────────────────────────

class BleBloc extends Bloc<BleEvent, BleState> {
  late final BleRepository _repository;

  StreamSubscription<List<BleDeviceEntity>>? _scanSub;
  StreamSubscription<Map<String, dynamic>>? _jsonSub;
  StreamSubscription<bool>? _connSub;

  BleBloc() : super(BleInitial()) {
    _repository = BleRepositoryImpl(WindowsBleClientDataSource());

    on<BleScanStartEvent>(_onScanStart);
    on<BleStopScanEvent>(_onStopScan);
    on<BleConnectDeviceEvent>(_onConnectDevice);
    on<BleDisconnectEvent>(_onDisconnect);
    on<BleSendJsonEvent>(_onSendJson);
    on<BleResetEvent>(_onReset);

    // Événements internes (stream → BLoC)
    on<_DevicesUpdatedEvent>(_onDevicesUpdated);
    on<_JsonReceivedEvent>(_onJsonReceived);
    on<_ConnectionChangedEvent>(_onConnectionChanged);
    on<_ErrorOccurredEvent>(_onError);
  }

  // ── Scan ──────────────────────────────────────────────────────────────────

  Future<void> _onScanStart(
    BleScanStartEvent event,
    Emitter<BleState> emit,
  ) async {
    emit(BleScanning());
    await _scanSub?.cancel();
    _scanSub = _repository.scanResultsStream.listen(
      (devices) => add(_DevicesUpdatedEvent(devices)),
      onError: (Object e) =>
          add(_ErrorOccurredEvent('Erreur scan : $e')),
    );
    try {
      await _repository.startScan();
    } catch (e) {
      add(_ErrorOccurredEvent('Scan impossible : $e'));
    }
  }

  Future<void> _onStopScan(
    BleStopScanEvent event,
    Emitter<BleState> emit,
  ) async {
    await _scanSub?.cancel();
    _scanSub = null;
    await _repository.stopScan();
    emit(BleInitial());
  }

  void _onDevicesUpdated(
    _DevicesUpdatedEvent event,
    Emitter<BleState> emit,
  ) {
    if (state is BleScanning) {
      emit((state as BleScanning).copyWith(devices: event.devices));
    }
  }

  // ── Connexion ─────────────────────────────────────────────────────────────

  Future<void> _onConnectDevice(
    BleConnectDeviceEvent event,
    Emitter<BleState> emit,
  ) async {
    emit(BleConnecting(event.device));

    // S'abonne aux JSON reçus et à l'état de connexion avant la connexion
    await _jsonSub?.cancel();
    _jsonSub = _repository.receivedJsonStream.listen(
      (json) => add(_JsonReceivedEvent(json)),
      onError: (Object e) =>
          add(_ErrorOccurredEvent('Erreur réception : $e')),
    );

    await _connSub?.cancel();
    _connSub = _repository.connectionStateStream.listen(
      (connected) => add(_ConnectionChangedEvent(connected)),
    );

    try {
      await _repository.connectToDevice(event.device);
      emit(BleConnected(device: event.device));
    } catch (e) {
      await _jsonSub?.cancel();
      await _connSub?.cancel();
      emit(BleError('Connexion échouée : $e'));
    }
  }

  void _onConnectionChanged(
    _ConnectionChangedEvent event,
    Emitter<BleState> emit,
  ) {
    if (!event.connected && state is BleConnected) {
      emit(BleDisconnected(reason: 'Déconnexion inattendue'));
    }
  }

  // ── Réception JSON ────────────────────────────────────────────────────────

  void _onJsonReceived(
    _JsonReceivedEvent event,
    Emitter<BleState> emit,
  ) {
    final current = state;
    if (current is BleConnected) {
      final record = BleJsonRecord(
        data: event.json,
        timestamp: DateTime.now(),
        direction: BleDirection.received,
      );
      emit(current.copyWith(history: [record, ...current.history]));
    }
  }

  // ── Envoi JSON ────────────────────────────────────────────────────────────

  Future<void> _onSendJson(
    BleSendJsonEvent event,
    Emitter<BleState> emit,
  ) async {
    final current = state;
    if (current is! BleConnected) return;

    emit(BleSending(device: current.device, history: current.history));
    try {
      await _repository.sendJson(event.data);
      final record = BleJsonRecord(
        data: event.data,
        timestamp: DateTime.now(),
        direction: BleDirection.sent,
      );
      emit(
        BleConnected(
          device: current.device,
          history: [record, ...current.history],
        ),
      );
    } catch (e) {
      emit(BleError('Envoi échoué : $e'));
    }
  }

  // ── Déconnexion ───────────────────────────────────────────────────────────

  Future<void> _onDisconnect(
    BleDisconnectEvent event,
    Emitter<BleState> emit,
  ) async {
    await _jsonSub?.cancel();
    _jsonSub = null;
    await _connSub?.cancel();
    _connSub = null;
    await _repository.disconnect();
    emit(BleDisconnected());
  }

  // ── Reset ─────────────────────────────────────────────────────────────────

  void _onReset(BleResetEvent event, Emitter<BleState> emit) =>
      emit(BleInitial());

  // ── Erreur ────────────────────────────────────────────────────────────────

  void _onError(_ErrorOccurredEvent event, Emitter<BleState> emit) =>
      emit(BleError(event.message));

  // ── Fermeture ─────────────────────────────────────────────────────────────

  @override
  Future<void> close() async {
    await _scanSub?.cancel();
    await _jsonSub?.cancel();
    await _connSub?.cancel();
    _repository.dispose();
    return super.close();
  }
}
