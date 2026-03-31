import '../entities/ble_device_entity.dart';

/// Interface du dépôt BLE — contrat entre domaine et couche données.
abstract class BleRepository {
  /// Flux des appareils découverts pendant le scan (liste cumulative).
  Stream<List<BleDeviceEntity>> get scanResultsStream;

  /// Flux des objets JSON entièrement assemblés reçus de l'Android.
  Stream<Map<String, dynamic>> get receivedJsonStream;

  /// Flux de l'état de connexion : true = connecté, false = déconnecté.
  Stream<bool> get connectionStateStream;

  /// Démarre le scan BLE (filtre sur le service UUID défini).
  Future<void> startScan();

  /// Arrête le scan en cours.
  Future<void> stopScan();

  /// Se connecte au périphérique et active les notifications JSON.
  Future<void> connectToDevice(BleDeviceEntity device);

  /// Envoie un JSON vers l'Android en découpant en chunks de 250 octets.
  Future<void> sendJson(Map<String, dynamic> data);

  /// Déconnecte le périphérique et libère les ressources.
  Future<void> disconnect();

  /// Libère toutes les ressources (StreamControllers, subscriptions).
  void dispose();
}
