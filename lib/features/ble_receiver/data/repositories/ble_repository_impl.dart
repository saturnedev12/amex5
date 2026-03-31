import '../../domain/entities/ble_device_entity.dart';
import '../../domain/repositories/ble_repository.dart';
import '../datasources/ble_data_source.dart';

/// Implémentation du dépôt BLE — délègue intégralement à la datasource.
class BleRepositoryImpl implements BleRepository {
  final BleDataSource _dataSource;

  BleRepositoryImpl(this._dataSource);

  @override
  Stream<List<BleDeviceEntity>> get scanResultsStream =>
      _dataSource.scanResultsStream;

  @override
  Stream<Map<String, dynamic>> get receivedJsonStream =>
      _dataSource.receivedJsonStream;

  @override
  Stream<bool> get connectionStateStream => _dataSource.connectionStateStream;

  @override
  Future<void> startScan() => _dataSource.startScan();

  @override
  Future<void> stopScan() => _dataSource.stopScan();

  @override
  Future<void> connectToDevice(BleDeviceEntity device) =>
      _dataSource.connectToDevice(device);

  @override
  Future<void> sendJson(Map<String, dynamic> data) =>
      _dataSource.sendJson(data);

  @override
  Future<void> disconnect() => _dataSource.disconnect();

  @override
  void dispose() => _dataSource.dispose();
}
