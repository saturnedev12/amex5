import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
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
  BleDeviceEntity? _connectedDevice;
  List<BleDeviceEntity> _scanResults = [];
  final List<String> _history = [];
  String? _errorMessage;

  StreamSubscription? _scanSubscription;
  StreamSubscription? _connectionSubscription;
  StreamSubscription? _jsonSubscription;

  BleService(this._repository) {
    _initSubscriptions();
  }

  BleConnectionState get connectionState => _connectionState;
  bool get isConnected => _connectionState == BleConnectionState.connected || _connectionState == BleConnectionState.sending;
  BleDeviceEntity? get connectedDevice => _connectedDevice;
  List<BleDeviceEntity> get scanResults => _scanResults;
  List<String> get history => _history;
  String? get errorMessage => _errorMessage;

  Stream<Map<String, dynamic>> get receivedJsonStream => _repository.receivedJsonStream;

  void _initSubscriptions() {
    _scanSubscription = _repository.scanResultsStream.listen((results) {
      _scanResults = results;
      notifyListeners();
    });

    _connectionSubscription = _repository.connectionStateStream.listen((isConnected) {
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
    _connectionState = BleConnectionState.scanning;
    notifyListeners();
    try {
      await _repository.startScan();
    } catch (e) {
      _connectionState = BleConnectionState.error;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> stopScan() async {
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
    _repository.dispose();
    super.dispose();
  }
}
