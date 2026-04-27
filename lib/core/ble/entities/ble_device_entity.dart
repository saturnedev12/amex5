import 'dart:convert';

/// Représente un périphérique BLE trouvé lors du scan.
class BleDeviceEntity {
  final String id;
  final String name;
  final int rssi;

  const BleDeviceEntity({
    required this.id,
    required this.name,
    required this.rssi,
  });

  @override
  bool operator ==(Object other) => other is BleDeviceEntity && other.id == id;

  @override
  int get hashCode => id.hashCode;

  BleDeviceEntity copyWith({String? id, String? name, int? rssi}) =>
      BleDeviceEntity(
        id: id ?? this.id,
        name: name ?? this.name,
        rssi: rssi ?? this.rssi,
      );
}

/// Sens de transmission d'un échange JSON via BLE.
enum BleDirection { received, sent }

/// Entrée du journal BLE : un JSON envoyé ou reçu avec horodatage.
class BleJsonRecord {
  final Map<String, dynamic> data;
  final DateTime timestamp;
  final BleDirection direction;

  const BleJsonRecord({
    required this.data,
    required this.timestamp,
    required this.direction,
  });

  String get prettyJson {
    const encoder = JsonEncoder.withIndent('  ');
    return encoder.convert(data);
  }

  void test() {}
}
