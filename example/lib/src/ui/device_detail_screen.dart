import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:flutter_reactive_ble_example/src/ble/ble_device_connector.dart';
import 'package:provider/provider.dart';

class DeviceDetailScreen extends StatelessWidget {
  final DiscoveredDevice device;

  const DeviceDetailScreen({@required this.device}) : assert(device != null);

  @override
  Widget build(BuildContext context) =>
      Consumer2<BleDeviceConnector, ConnectionStateUpdate>(
        builder: (_, deviceConnector, connectionStateUpdate, __) =>
            _DeviceDetail(
                device: device,
                connectionUpdate: connectionStateUpdate != null &&
                        connectionStateUpdate.deviceId == device.id
                    ? connectionStateUpdate
                    : ConnectionStateUpdate(
                        deviceId: device.id,
                        connectionState: DeviceConnectionState.disconnected,
                        failure: null,
                      ),
                connect: deviceConnector.connect,
                disconnect: deviceConnector.disconnect,
                writeByte: deviceConnector.writeByte,
                discoverServices: deviceConnector.discoverServices),
      );
}

class _DeviceDetail extends StatelessWidget {
  const _DeviceDetail({
    @required this.device,
    @required this.connectionUpdate,
    @required this.connect,
    @required this.disconnect,
    @required this.discoverServices,
    @required this.writeByte,
    Key key,
  })  : assert(device != null),
        assert(connectionUpdate != null),
        assert(connect != null),
        assert(disconnect != null),
        assert(discoverServices != null),
        assert(writeByte != null),
        super(key: key);

  final DiscoveredDevice device;
  final ConnectionStateUpdate connectionUpdate;
  final void Function(String deviceId) connect;
  final void Function(String deviceId) disconnect;
  final void Function(String deviceId) discoverServices;
  final void Function(String deviceId) writeByte;

  bool _deviceConnected() =>
      connectionUpdate.connectionState == DeviceConnectionState.connected;

  @override
  Widget build(BuildContext context) => WillPopScope(
        onWillPop: () async {
          disconnect(device.id);
          return true;
        },
        child: Scaffold(
          appBar: AppBar(
            title: Text(device.name ?? "unknown"),
          ),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "ID: ${connectionUpdate.deviceId}",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "Status: ${connectionUpdate.connectionState}",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ElevatedButton(
                        onPressed: !_deviceConnected()
                            ? () => connect(device.id)
                            : null,
                        child: const Text("Connect"),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ElevatedButton(
                        onPressed: _deviceConnected()
                            ? () => disconnect(device.id)
                            : null,
                        child: const Text("Disconnect"),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ElevatedButton(
                        onPressed: _deviceConnected()
                            ? () => discoverServices(device.id)
                            : null,
                        child: const Text("Services"),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ElevatedButton(
                        onPressed: _deviceConnected()
                            ? () => writeByte(device.id)
                            : null,
                        child: const Text("Toggle LED"),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
}
