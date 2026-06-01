import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_easyloading_plus/flutter_easyloading_plus.dart';
// flutter_blue_plus_windows bridges flutter_blue_plus ↔ win_ble pour Windows.
// L'API est identique à flutter_blue_plus — seul l'import change.
import 'package:flutter_blue_plus_windows/flutter_blue_plus_windows.dart';
import 'package:injectable/injectable.dart';

import '../entities/ble_device_entity.dart';

// UUIDs identiques côté Android (serveur) et Windows (client)
const String _kServiceUuid = 'd8f6a510-a37b-4f2d-9f8d-5c7b8d2e4a11';
const String _kCharUuid = 'd8f6a511-a37b-4f2d-9f8d-5c7b8d2e4a11';
const String _kMessageIdKey = '_BLE_MESSAGE_ID';
const String _kAckIdKey = '_BLE_ACK_ID';
const String _kAckType = 'BLE_ACK';
const List<String> _kAdvertisingNamePrefixes = ['RDX-', 'RONDEX-'];

/// Comparaison UUID tolérante aux formats retournés par le stack BLE Windows.
/// win_ble peut retourner une forme complète 128-bit avec/sans accolades,
/// ou une forme courte pour les UUID Bluetooth SIG.
bool _uuidMatches(Guid uuid, String expected) {
  final raw = uuid
      .toString()
      .toLowerCase()
      .replaceAll('{', '')
      .replaceAll('}', '');
  final exp = expected.toLowerCase();

  // Correspondance directe (cas normal)
  if (raw == exp) return true;

  // Extraire les 4 hex significatifs de l'UUID Bluetooth SIG 128-bit
  // Ex : "0000xxxx-0000-1000-8000-00805f9b34fb" → "xxxx"
  final sigMatch = RegExp(
    r'^0000([0-9a-f]{4})-0000-1000-8000-00805f9b34fb$',
  ).firstMatch(exp);

  if (sigMatch != null) {
    final short4 = sigMatch.group(1)!;
    // Accepter : "xxxx", "0000xxxx", "0000xxxx-...", etc.
    if (raw == short4) return true;
    if (raw == '0000$short4') return true;
    if (raw.startsWith('0000$short4')) return true;
  }
  return false;
}

const int _kDefaultChunkSize = 20;
const int _kMaxChunkSize = 244;
const int _kScanSeconds = 30;
const Duration _kRemoveIfGone = Duration(seconds: 20);
const Duration _kAckTimeout = Duration(seconds: 20);

abstract class BleDataSource {
  Stream<List<BleDeviceEntity>> get scanResultsStream;
  Stream<Map<String, dynamic>> get receivedJsonStream;
  Stream<bool> get connectionStateStream;

  Future<void> startScan();
  Future<void> stopScan();
  Future<void> connectToDevice(BleDeviceEntity device);
  Future<void> sendJson(Map<String, dynamic> data);
  Future<void> disconnect();
  void dispose();
}

/// Implémentation Windows du client BLE via flutter_blue_plus_windows.
/// Le PC Windows agit en tant que Central (Client) et le smartphone Android
/// agit en tant que Peripheral (Serveur).
@LazySingleton(as: BleDataSource)
class WindowsBleClientDataSource implements BleDataSource {
  BluetoothDevice? _connectedDevice;
  BluetoothCharacteristic? _characteristic;
  int _writeChunkSize = _kDefaultChunkSize;
  int _messageSequence = 0;

  StreamSubscription<List<ScanResult>>? _scanSubscription;
  StreamSubscription<List<int>>? _characteristicSubscription;
  StreamSubscription<BluetoothConnectionState>? _connectionStateSubscription;
  int _disconnectProbeToken = 0;

  /// Stocke les BluetoothDevice bruts trouvés lors du scan (clé = remoteId).
  final Map<String, BluetoothDevice> _foundDevicesMap = {};

  /// Buffer applicatif pour le re-assemblage des chunks entrants (Android → Windows).
  final List<int> _receiveBuffer = [];

  final _scanController = StreamController<List<BleDeviceEntity>>.broadcast();
  final _jsonController = StreamController<Map<String, dynamic>>.broadcast();
  final _connectionController = StreamController<bool>.broadcast();
  final _ackController = StreamController<String>.broadcast();

  // ── Streams publics ───────────────────────────────────────────────────────

  @override
  Stream<List<BleDeviceEntity>> get scanResultsStream => _scanController.stream;

  @override
  Stream<Map<String, dynamic>> get receivedJsonStream => _jsonController.stream;

  @override
  Stream<bool> get connectionStateStream => _connectionController.stream;

  // ── Scan ──────────────────────────────────────────────────────────────────

  @override
  Future<void> startScan() async {
    _foundDevicesMap.clear();
    await _scanSubscription?.cancel();
    await FlutterBluePlus.stopScan();
    if (!_scanController.isClosed) _scanController.add(const []);

    await FlutterBluePlus.startScan(
      timeout: const Duration(seconds: _kScanSeconds),
      removeIfGone: _kRemoveIfGone,
    );

    _scanSubscription = FlutterBluePlus.scanResults.listen((results) {
      final entitiesById = <String, BleDeviceEntity>{};

      for (final r in results) {
        if (!_isExpectedAndroidPeripheral(r)) continue;

        final id = r.device.remoteId.toString();
        _foundDevicesMap[id] = r.device;
        entitiesById[id] = BleDeviceEntity(
          id: id,
          name: _displayNameForScanResult(r),
          rssi: r.rssi,
        );
      }

      final entities = entitiesById.values.toList()
        ..sort((a, b) => b.rssi.compareTo(a.rssi));

      if (!_scanController.isClosed) _scanController.add(entities);
    }, onError: (Object e) => debugPrint('BLE — Erreur scan : $e'));
  }

  bool _isExpectedAndroidPeripheral(ScanResult result) {
    final serviceMatch = result.advertisementData.serviceUuids.any(
      (uuid) => _uuidMatches(uuid, _kServiceUuid),
    );
    if (serviceMatch) return true;

    final names = <String>{
      result.advertisementData.advName.trim(),
      result.device.platformName.trim(),
    }..removeWhere((name) => name.isEmpty);

    return names.any(
      (name) => _kAdvertisingNamePrefixes.any(
        (prefix) => name.toUpperCase().startsWith(prefix),
      ),
    );
  }

  String _displayNameForScanResult(ScanResult result) {
    final advName = result.advertisementData.advName.trim();
    if (advName.isNotEmpty) return advName;

    final platformName = result.device.platformName.trim();
    if (platformName.isNotEmpty) return platformName;

    final id = result.device.remoteId.toString();
    final suffix = id.length <= 5 ? id : id.substring(id.length - 5);
    return 'RONDEX $suffix';
  }

  @override
  Future<void> stopScan() async {
    await _scanSubscription?.cancel();
    _scanSubscription = null;
    await FlutterBluePlus.stopScan();
  }

  // ── Connexion ─────────────────────────────────────────────────────────────

  @override
  Future<void> connectToDevice(BleDeviceEntity deviceEntity) async {
    final btDevice = _foundDevicesMap[deviceEntity.id];
    if (btDevice == null) {
      throw Exception(
        "Appareil '${deviceEntity.name}' introuvable dans les résultats du scan.",
      );
    }

    await stopScan();
    _connectedDevice = btDevice;
    _receiveBuffer.clear();

    try {
      final services = await _connectAndDiscoverWithRetry(btDevice);

      debugPrint('BLE — Session GATT ouverte avec ${deviceEntity.name}');
      await _configureWriteChunkSize(btDevice);

      // Debug : afficher tous les services/caractéristiques retournés par Windows
      debugPrint('BLE — ${services.length} service(s) découvert(s) :');
      for (final svc in services) {
        debugPrint('  ├─ Service : ${svc.uuid}');
        for (final chr in svc.characteristics) {
          debugPrint('  │   └─ Char : ${chr.uuid}  props=${chr.properties}');
        }
      }

      for (final svc in services) {
        if (_uuidMatches(svc.uuid, _kServiceUuid)) {
          debugPrint('BLE — Service cible trouvé : ${svc.uuid}');
          for (final chr in svc.characteristics) {
            if (_uuidMatches(chr.uuid, _kCharUuid)) {
              _characteristic = chr;
              debugPrint('BLE — Caractéristique cible trouvée : ${chr.uuid}');
              _validateCharacteristic(chr);
              await _subscribeToNotifications();
              break;
            }
          }
          break;
        }
      }

      if (_characteristic == null) {
        throw Exception(
          'Caractéristique BLE ($_kCharUuid) introuvable sur le serveur Android.',
        );
      }

      if (!_connectionController.isClosed) {
        _connectionController.add(true);
      }
      _startConnectionMonitor(btDevice);
    } catch (_) {
      try {
        await disconnect();
      } catch (_) {}
      rethrow;
    }
  }

  Future<List<BluetoothService>> _connectAndDiscoverWithRetry(
    BluetoothDevice device,
  ) async {
    Object? lastError;

    for (var attempt = 1; attempt <= 3; attempt++) {
      try {
        try {
          await device
              .connect(autoConnect: false, timeout: const Duration(seconds: 6))
              .timeout(const Duration(seconds: 6));
        } catch (e) {
          debugPrint(
            'BLE — WinBle.connect tentative $attempt sans confirmation : $e',
          );
        }

        final services = await _discoverServicesWithRetry(device);
        return services;
      } catch (e) {
        lastError = e;
        debugPrint('BLE — Session GATT tentative $attempt échouée : $e');
        try {
          await device.disconnect();
        } catch (_) {}
        await Future.delayed(Duration(milliseconds: 700 * attempt));
      }
    }

    throw Exception(
      'Session GATT BLE impossible après 3 tentatives : $lastError',
    );
  }

  Future<List<BluetoothService>> _discoverServicesWithRetry(
    BluetoothDevice device, {
    int attempts = 3,
    Duration? initialDelay,
  }) async {
    Object? lastError;

    for (var attempt = 1; attempt <= attempts; attempt++) {
      try {
        await Future.delayed(
          initialDelay ?? Duration(milliseconds: 350 * attempt),
        );
        final services = await device
            .discoverServices(timeout: 8)
            .timeout(const Duration(seconds: 8));
        final hasTargetService = services.any(
          (service) => _uuidMatches(service.uuid, _kServiceUuid),
        );
        if (hasTargetService) return services;
        lastError = 'service $_kServiceUuid absent';
      } catch (e) {
        lastError = e;
      }
      debugPrint('BLE — Découverte services tentative $attempt échouée.');
    }

    throw Exception('Service BLE cible introuvable : $lastError');
  }

  Future<void> _configureWriteChunkSize(BluetoothDevice device) async {
    _writeChunkSize = _kDefaultChunkSize;
    try {
      final mtu = await device
          .requestMtu(512)
          .timeout(const Duration(seconds: 3));
      _writeChunkSize = (mtu - 3)
          .clamp(_kDefaultChunkSize, _kMaxChunkSize)
          .toInt();
      debugPrint('BLE — MTU Windows=$mtu, chunks écriture=$_writeChunkSize');
    } catch (e) {
      debugPrint('BLE — MTU indisponible, chunks écriture=20 octets : $e');
    }
  }

  void _validateCharacteristic(BluetoothCharacteristic characteristic) {
    final properties = characteristic.properties;
    if (!properties.notify && !properties.indicate) {
      debugPrint(
        'BLE — Propriétés notify/indicate non confirmées par Windows. '
        'Tentative d’abonnement quand même sur $_kCharUuid.',
      );
    }
    if (!properties.write && !properties.writeWithoutResponse) {
      debugPrint(
        'BLE — Propriétés write non confirmées par Windows. '
        'Tentative d’écriture avec réponse quand même sur $_kCharUuid.',
      );
    }
  }

  void _startConnectionMonitor(BluetoothDevice device) {
    unawaited(_connectionStateSubscription?.cancel());
    _connectionStateSubscription = device.connectionState.listen((state) {
      if (state == BluetoothConnectionState.connected) return;
      final token = ++_disconnectProbeToken;
      unawaited(_probeDisconnect(device, token));
    });
  }

  Future<void> _probeDisconnect(BluetoothDevice device, int token) async {
    await Future.delayed(const Duration(seconds: 2));
    if (token != _disconnectProbeToken || _characteristic == null) return;

    try {
      await _discoverServicesWithRetry(
        device,
        attempts: 1,
        initialDelay: Duration.zero,
      ).timeout(const Duration(seconds: 5));
      debugPrint(
        'BLE — Signal disconnect Windows ignoré, GATT encore joignable.',
      );
    } catch (_) {
      _markDisconnected();
    }
  }

  void _markDisconnected() {
    unawaited(_characteristicSubscription?.cancel());
    _characteristicSubscription = null;
    unawaited(_connectionStateSubscription?.cancel());
    _connectionStateSubscription = null;
    _connectedDevice = null;
    _characteristic = null;
    _receiveBuffer.clear();
    if (!_connectionController.isClosed) {
      _connectionController.add(false);
    }
    debugPrint('BLE — Déconnecté.');
  }

  // ── Réception (Android → Windows) ────────────────────────────────────────

  Future<void> _subscribeToNotifications() async {
    await _characteristicSubscription?.cancel();

    _characteristicSubscription = _characteristic!.onValueReceived.listen((
      bytes,
    ) {
      if (bytes.isNotEmpty) _processChunk(bytes);
    }, onError: (Object e) => debugPrint('BLE — Erreur notification : $e'));

    await _enableNotificationsWithRetry();

    debugPrint('BLE — Écoute des notifications activée sur $_kCharUuid');
  }

  Future<void> _enableNotificationsWithRetry() async {
    Object? lastError;
    for (var attempt = 1; attempt <= 2; attempt++) {
      try {
        await _characteristic!
            .setNotifyValue(true)
            .timeout(const Duration(seconds: 8));
        if (_characteristic!.isNotifying) return;
        lastError = 'isNotifying=false';
      } catch (e) {
        lastError = e;
      }

      debugPrint(
        'BLE — Abonnement notify tentative $attempt incertain : $lastError',
      );
      await Future.delayed(Duration(milliseconds: 350 * attempt));
    }

    if (!_characteristic!.isNotifying) {
      debugPrint(
        "BLE — Abonnement notify non confirmé par le package Windows. "
        "La session GATT reste ouverte, l'ACK applicatif validera la réception réelle.",
      );
    }
  }

  /// Accumule les chunks entrants et émet un JSON complet une fois assemblé.
  void _processChunk(List<int> chunk) {
    _receiveBuffer.addAll(chunk);
    try {
      final jsonStr = utf8.decode(_receiveBuffer);
      final decoded = jsonDecode(jsonStr);

      final Map<String, dynamic> json;
      if (decoded is Map<String, dynamic>) {
        json = decoded;
      } else if (decoded is List) {
        json = {'data': decoded};
      } else {
        throw FormatException('Type JSON inattendu : ${decoded.runtimeType}');
      }

      debugPrint(
        'BLE — JSON reçu et assemblé (${_receiveBuffer.length} octets)',
      );
      _receiveBuffer.clear();

      final ackId = json[_kAckIdKey]?.toString();
      if (json['TYPE'] == _kAckType && ackId != null && ackId.isNotEmpty) {
        if (!_ackController.isClosed) _ackController.add(ackId);
        return;
      }

      final messageId = json[_kMessageIdKey]?.toString();
      if (messageId != null && messageId.isNotEmpty) {
        json.remove(_kMessageIdKey);
        unawaited(_sendAck(messageId));
      }

      if (!_jsonController.isClosed) _jsonController.add(json);
    } on FormatException {
      // JSON ou UTF-8 incomplet → attendre le prochain chunk
    } catch (e) {
      debugPrint('BLE — Erreur parsing JSON : $e');
      _receiveBuffer.clear();
    }
  }

  // ── Envoi (Windows → Android) ─────────────────────────────────────────────

  @override
  Future<void> sendJson(Map<String, dynamic> data) async {
    if (_characteristic == null) {
      throw Exception("Impossible d'envoyer : aucune connexion BLE active.");
    }

    final messageId = _nextMessageId();
    final document = Map<String, dynamic>.from(data)
      ..putIfAbsent(_kMessageIdKey, () => messageId);
    Future<void>? ackFuture;
    final bytes = utf8.encode(jsonEncode(document));
    debugPrint('BLE — Envoi de ${bytes.length} octets vers Android...');

    EasyLoading.showProgress(0.0, status: 'Envoi des données...');

    try {
      ackFuture = _waitForAck(messageId);
      final withoutResponse =
          !_characteristic!.properties.write &&
          _characteristic!.properties.writeWithoutResponse;

      for (int i = 0; i < bytes.length; i += _writeChunkSize) {
        final end = (i + _writeChunkSize < bytes.length)
            ? i + _writeChunkSize
            : bytes.length;

        // OPTIMISATION : En conservant withoutResponse: false, on s'assure que
        // Windows a reçu l'acquittement (ACK) d'Android avant d'envoyer le chunk suivant.
        // Le Future "await" joue lui-même le rôle de régulateur (throttle).
        await _characteristic!.write(
          bytes.sublist(i, end),
          withoutResponse: withoutResponse,
        );

        final progress = end / bytes.length;
        EasyLoading.showProgress(
          progress.clamp(0.0, 1.0),
          status: 'Envoi des données...',
        );

        // OPTIMISATION : Suppression du Future.delayed inutile qui bridait les performances
        // car le withoutResponse: false impose déjà une attente synchrone.
      }

      await ackFuture;
      debugPrint('BLE — Transmission complète vers Android.');
    } catch (e) {
      if (ackFuture != null) {
        unawaited(ackFuture.catchError((Object _) {}));
      }
      rethrow;
    } finally {
      EasyLoading.dismiss();
    }
  }

  String _nextMessageId() {
    _messageSequence++;
    return "${DateTime.now().microsecondsSinceEpoch}-$_messageSequence";
  }

  Future<void> _waitForAck(String messageId) async {
    await _ackController.stream
        .where((ackId) => ackId == messageId)
        .first
        .timeout(
          _kAckTimeout,
          onTimeout: () => throw TimeoutException(
            "Android n'a pas accusé réception du message BLE.",
            _kAckTimeout,
          ),
        );
  }

  Future<void> _sendAck(String messageId) async {
    final characteristic = _characteristic;
    if (characteristic == null) return;

    try {
      final bytes = utf8.encode(
        jsonEncode({'TYPE': _kAckType, _kAckIdKey: messageId}),
      );
      final withoutResponse =
          !characteristic.properties.write &&
          characteristic.properties.writeWithoutResponse;

      for (int i = 0; i < bytes.length; i += _writeChunkSize) {
        final end = (i + _writeChunkSize < bytes.length)
            ? i + _writeChunkSize
            : bytes.length;
        await characteristic.write(
          bytes.sublist(i, end),
          withoutResponse: withoutResponse,
        );
      }
    } catch (e) {
      debugPrint('BLE — ACK impossible pour $messageId : $e');
    }
  }

  // ── Déconnexion ───────────────────────────────────────────────────────────

  @override
  Future<void> disconnect() async {
    await _characteristicSubscription?.cancel();
    _characteristicSubscription = null;
    await _connectionStateSubscription?.cancel();
    _connectionStateSubscription = null;

    await _connectedDevice?.disconnect();
    _markDisconnected();
  }

  // ── Nettoyage ─────────────────────────────────────────────────────────────

  @override
  void dispose() {
    _scanSubscription?.cancel();
    _characteristicSubscription?.cancel();
    _connectionStateSubscription?.cancel();
    _connectedDevice?.disconnect();

    if (!_scanController.isClosed) _scanController.close();
    if (!_jsonController.isClosed) _jsonController.close();
    if (!_connectionController.isClosed) _connectionController.close();
    if (!_ackController.isClosed) _ackController.close();
  }
}
