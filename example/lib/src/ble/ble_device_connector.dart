import 'dart:async';

import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:flutter_reactive_ble_example/src/ble/reactive_state.dart';

class BleDeviceConnector extends ReactiveState<ConnectionStateUpdate> {
  BleDeviceConnector(this._ble);

  final FlutterReactiveBle _ble;

  @override
  Stream<ConnectionStateUpdate> get state => _deviceConnectionController.stream;

  final _deviceConnectionController = StreamController<ConnectionStateUpdate>();

  StreamSubscription<ConnectionStateUpdate> _connection;

  Future<void> connect(String deviceId) async {
    if (_connection != null) {
      await _connection.cancel();
    }
    _connection = _ble.connectToDevice(id: deviceId).listen(
          _deviceConnectionController.add,
        );
  }

  Future<void> disconnect(String deviceId) async {
    if (_connection != null) {
      try {
        await _connection.cancel();
      } on Exception catch (e, _) {
        print("Error disconnecting from a device: $e");
      } finally {
        // Since [_connection] subscription is terminated, the "disconnected" state cannot be received and propagated
        _deviceConnectionController.add(
          ConnectionStateUpdate(
            deviceId: deviceId,
            connectionState: DeviceConnectionState.disconnected,
            failure: null,
          ),
        );
      }
    }
  }

  Future<void> discoverServices(String deviceId) async {
    await _ble.discoverServices(deviceId).then(
          (value) => print('Services discovered: $value'),
        );
  }

  Future<void> writeByte(String deviceId) async {
    final characteristic = QualifiedCharacteristic(
        serviceId: Uuid.parse("ffe0"),
        characteristicId: Uuid.parse("ffe1"),
        deviceId: deviceId);
    List<int> _list = [41];
    await _ble
        .writeCharacteristicWithoutResponse(characteristic, value: _list)
        .then((value) => print('data write'));
  }

  Future<void> dispose() async {
    await _deviceConnectionController.close();
  }
}
