import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus_windows/flutter_blue_plus_windows.dart';
import 'package:injectable/injectable.dart';

import 'entities/ble_device_entity.dart';
import 'repositories/ble_repository.dart';
import 'ble_connect_dialog.dart';

enum BleConnectionState {
  disconnected,
  scanning,
  connecting,
  connected,
  sending,
  error,
}

@singleton
class BleService extends ChangeNotifier {
  final BleRepository _repository;

  BleConnectionState _connectionState = BleConnectionState.disconnected;
  BluetoothAdapterState _adapterState = BluetoothAdapterState.unknown;
  bool _isBluetoothSupported = true;
  BleDeviceEntity? _connectedDevice;
  List<BleDeviceEntity> _scanResults = [];
  final List<String> _history = [];
  String? _errorMessage;

  StreamSubscription? _scanSubscription;
  StreamSubscription? _connectionSubscription;
  StreamSubscription? _jsonSubscription;
  StreamSubscription<BluetoothAdapterState>? _adapterStateSubscription;
  Timer? _scanTimeoutTimer;

  BleService(this._repository) {
    _initAdapterState();
    _initSubscriptions();
  }

  BleConnectionState get connectionState => _connectionState;
  BluetoothAdapterState get adapterState => _adapterState;
  bool get isBluetoothSupported => _isBluetoothSupported;
  bool get isBluetoothOn => _adapterState == BluetoothAdapterState.on;
  bool get isBluetoothReady => _isBluetoothSupported && isBluetoothOn;
  bool get isConnected =>
      _connectionState == BleConnectionState.connected ||
      _connectionState == BleConnectionState.sending;
  BleDeviceEntity? get connectedDevice => _connectedDevice;
  List<BleDeviceEntity> get scanResults => _scanResults;
  List<String> get history => _history;
  String? get errorMessage => _errorMessage;

  Stream<Map<String, dynamic>> get receivedJsonStream =>
      _repository.receivedJsonStream;

  void _initAdapterState() {
    unawaited(
      FlutterBluePlus.isSupported
          .then((supported) {
            _isBluetoothSupported = supported;
            notifyListeners();
          })
          .catchError((Object _) {
            _isBluetoothSupported = false;
            notifyListeners();
          }),
    );

    _adapterStateSubscription = FlutterBluePlus.adapterState.listen((state) {
      _adapterState = state;
      if (state != BluetoothAdapterState.on &&
          _connectionState == BleConnectionState.scanning) {
        _connectionState = BleConnectionState.disconnected;
        _scanTimeoutTimer?.cancel();
      }
      notifyListeners();
    });
  }

  void _initSubscriptions() {
    _scanSubscription = _repository.scanResultsStream.listen((results) {
      _scanResults = results;
      notifyListeners();
    });

    _connectionSubscription = _repository.connectionStateStream.listen((
      isConnected,
    ) {
      if (isConnected) {
        _connectionState = BleConnectionState.connected;
      } else {
        _connectionState = BleConnectionState.disconnected;
        _connectedDevice = null;
      }
      notifyListeners();
    });

    _jsonSubscription = _repository.receivedJsonStream.listen((json) {
      _history.insert(0, 'Received: $json');
      notifyListeners();
    });
  }

  Future<void> startScan() async {
    _errorMessage = null;
    try {
      _isBluetoothSupported = await FlutterBluePlus.isSupported;
      final currentAdapterState = await FlutterBluePlus.adapterState.first
          .timeout(const Duration(seconds: 2), onTimeout: () => _adapterState);
      _adapterState = currentAdapterState;

      if (!_isBluetoothSupported) {
        _connectionState = BleConnectionState.error;
        _errorMessage = 'Bluetooth non supporté sur cet appareil.';
        notifyListeners();
        return;
      }

      if (currentAdapterState != BluetoothAdapterState.on) {
        _connectionState = BleConnectionState.error;
        _errorMessage =
            'Bluetooth désactivé. Activez le Bluetooth avant de scanner.';
        notifyListeners();
        return;
      }

      _connectionState = BleConnectionState.scanning;
      notifyListeners();
      await _repository.startScan();
      _scanTimeoutTimer?.cancel();
      _scanTimeoutTimer = Timer(const Duration(seconds: 26), () {
        if (_connectionState != BleConnectionState.scanning) return;
        _connectionState = BleConnectionState.disconnected;
        if (_scanResults.isEmpty) {
          _errorMessage =
              "Aucun appareil RONDEX détecté. Activez le partage Bluetooth sur Android puis relancez la recherche.";
        }
        notifyListeners();
      });
    } catch (e) {
      _connectionState = BleConnectionState.error;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> stopScan() async {
    _scanTimeoutTimer?.cancel();
    await _repository.stopScan();
    if (_connectionState == BleConnectionState.scanning) {
      _connectionState = BleConnectionState.disconnected;
      notifyListeners();
    }
  }

  Future<void> connectToDevice(BleDeviceEntity device) async {
    _errorMessage = null;
    _connectionState = BleConnectionState.connecting;
    notifyListeners();
    try {
      await _repository.connectToDevice(device);
      _connectedDevice = device;
      _connectionState = BleConnectionState.connected;
    } catch (e) {
      _connectionState = BleConnectionState.error;
      _errorMessage = e.toString();
    }
    notifyListeners();
  }

  Future<void> sendJson(Map<String, dynamic> data) async {
    if (!isConnected) {
      _errorMessage = 'Not connected';
      _connectionState = BleConnectionState.error;
      notifyListeners();
      return;
    }

    final previousState = _connectionState;
    _connectionState = BleConnectionState.sending;
    _history.insert(0, 'Sent: $data');
    notifyListeners();

    try {
      await _repository.sendJson(data);
      _connectionState = previousState;
    } catch (e) {
      _connectionState = BleConnectionState.error;
      _errorMessage = e.toString();
    }
    notifyListeners();
  }

  Future<void> disconnect() async {
    await _repository.disconnect();
    _connectionState = BleConnectionState.disconnected;
    _connectedDevice = null;
    notifyListeners();
  }

  Future<bool> ensureConnected(BuildContext context) async {
    if (isConnected) return true;
    return await showBleConnectDialog(context);
  }

  @override
  void dispose() {
    _scanSubscription?.cancel();
    _connectionSubscription?.cancel();
    _jsonSubscription?.cancel();
    _adapterStateSubscription?.cancel();
    _scanTimeoutTimer?.cancel();
    _repository.dispose();
    super.dispose();
  }
}
