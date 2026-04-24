import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
// flutter_blue_plus_windows bridges flutter_blue_plus ↔ win_ble pour Windows.
// L'API est identique à flutter_blue_plus — seul l'import change.
import 'package:flutter_blue_plus_windows/flutter_blue_plus_windows.dart';
import 'package:injectable/injectable.dart';

import '../entities/ble_device_entity.dart';

// UUIDs identiques côté Android (serveur) et Windows (client)
const String _kServiceUuid = '0000ffe0-0000-1000-8000-00805f9b34fb';
const String _kCharUuid = '0000ffe1-0000-1000-8000-00805f9b34fb';

/// Comparaison UUID tolérante aux formats retournés par le stack BLE Windows.
/// win_ble peut retourner : forme courte "ffe0", forme 8-char "0000ffe0",
/// ou forme complète 128-bit avec/sans accolades et en majuscules.
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
  // Ex : "0000ffe0-0000-1000-8000-00805f9b34fb" → "ffe0"
  final sigMatch = RegExp(
    r'^0000([0-9a-f]{4})-0000-1000-8000-00805f9b34fb$',
  ).firstMatch(exp);

  if (sigMatch != null) {
    final short4 = sigMatch.group(1)!; // "ffe0"
    // Accepter : "ffe0", "0000ffe0", "0000ffe0-...", etc.
    if (raw == short4) return true;
    if (raw == '0000$short4') return true;
    if (raw.startsWith('0000$short4')) return true;
  }
  return false;
}

const int _kChunkSize = 250;
const int _kChunkDelayMs = 30;

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
@Injectable(as: BleDataSource)
class WindowsBleClientDataSource implements BleDataSource {
  BluetoothDevice? _connectedDevice;
  BluetoothCharacteristic? _characteristic;

  StreamSubscription<List<ScanResult>>? _scanSubscription;
  StreamSubscription<List<int>>? _characteristicSubscription;
  StreamSubscription<BluetoothConnectionState>? _connectionStateSubscription;

  /// Stocke les BluetoothDevice bruts trouvés lors du scan (clé = remoteId).
  final Map<String, BluetoothDevice> _foundDevicesMap = {};

  /// Buffer applicatif pour le re-assemblage des chunks entrants (Android → Windows).
  final List<int> _receiveBuffer = [];

  final _scanController = StreamController<List<BleDeviceEntity>>.broadcast();
  final _jsonController = StreamController<Map<String, dynamic>>.broadcast();
  final _connectionController = StreamController<bool>.broadcast();

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

    await FlutterBluePlus.startScan(
      withServices: [Guid(_kServiceUuid)],
      timeout: const Duration(seconds: 15),
    );

    _scanSubscription = FlutterBluePlus.scanResults.listen((results) {
      for (final r in results) {
        _foundDevicesMap[r.device.remoteId.toString()] = r.device;
      }
      final entities = results
          .map(
            (r) => BleDeviceEntity(
              id: r.device.remoteId.toString(),
              name: r.device.platformName.isNotEmpty
                  ? r.device.platformName
                  : 'Appareil BLE',
              rssi: r.rssi,
            ),
          )
          .toList();
      if (!_scanController.isClosed) _scanController.add(entities);
    }, onError: (Object e) => debugPrint('BLE — Erreur scan : $e'));
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
    await _connectedDevice!.connect(autoConnect: false);

    debugPrint('BLE — Connecté à ${deviceEntity.name} (${deviceEntity.id})');

    // Surveillance de l'état de connexion
    await _connectionStateSubscription?.cancel();
    _connectionStateSubscription = _connectedDevice!.connectionState.listen((
      state,
    ) {
      final connected = state == BluetoothConnectionState.connected;
      if (!_connectionController.isClosed) {
        _connectionController.add(connected);
      }
      if (!connected) {
        _characteristic = null;
        _receiveBuffer.clear();
        debugPrint('BLE — Déconnecté.');
      }
    });

    // Découverte des services et abonnement aux notifications
    final services = await _connectedDevice!.discoverServices();

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
  }

  // ── Réception (Android → Windows) ────────────────────────────────────────

  Future<void> _subscribeToNotifications() async {
    await _characteristicSubscription?.cancel();
    await _characteristic!.setNotifyValue(true);

    _characteristicSubscription = _characteristic!.lastValueStream.listen((
      bytes,
    ) {
      if (bytes.isNotEmpty) _processChunk(bytes);
    }, onError: (Object e) => debugPrint('BLE — Erreur notification : $e'));

    debugPrint('BLE — Écoute des notifications activée sur $_kCharUuid');
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
      if (!_jsonController.isClosed) _jsonController.add(json);
      _receiveBuffer.clear();
    } on FormatException {
      // JSON ou UTF-8 incomplet → attendre le prochain chunk
    } catch (e) {
      debugPrint('BLE — Erreur parsing JSON : $e');
      _receiveBuffer.clear();
    }
  }

  // ── Envoi (Windows → Android) ─────────────────────────────────────────────

  // ── Envoi (Windows → Android) ─────────────────────────────────────────────

  @override
  Future<void> sendJson(Map<String, dynamic> data) async {
    if (_characteristic == null) {
      throw Exception("Impossible d'envoyer : aucune connexion BLE active.");
    }

    final bytes = utf8.encode(jsonEncode(data));
    debugPrint('BLE — Envoi de ${bytes.length} octets vers Android...');

    // On utilise la limite standard universelle et sûre de 20 octets si on ne connaît
    // pas le MTU exact du Windows, mais ici 250 est correct si les deux OS sont récents.
    for (int i = 0; i < bytes.length; i += _kChunkSize) {
      final end = (i + _kChunkSize < bytes.length)
          ? i + _kChunkSize
          : bytes.length;

      // OPTIMISATION : En conservant withoutResponse: false, on s'assure que
      // Windows a reçu l'acquittement (ACK) d'Android avant d'envoyer le chunk suivant.
      // Le Future "await" joue lui-même le rôle de régulateur (throttle).
      await _characteristic!.write(
        bytes.sublist(i, end),
        withoutResponse: false,
      );

      // OPTIMISATION : Suppression du Future.delayed inutile qui bridait les performances
      // car le withoutResponse: false impose déjà une attente synchrone.
    }

    debugPrint('BLE — Transmission complète vers Android.');
  }

  // ── Déconnexion ───────────────────────────────────────────────────────────

  @override
  Future<void> disconnect() async {
    await _characteristicSubscription?.cancel();
    _characteristicSubscription = null;
    await _connectionStateSubscription?.cancel();
    _connectionStateSubscription = null;

    await _connectedDevice?.disconnect();
    _connectedDevice = null;
    _characteristic = null;
    _receiveBuffer.clear();
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
  }
}
