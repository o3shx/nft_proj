import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

class DevicePairingPage extends StatefulWidget {
  const DevicePairingPage({Key? key}) : super(key: key);

  @override
  State<DevicePairingPage> createState() => _DevicePairingPageState();
}

class _DevicePairingPageState extends State<DevicePairingPage> {
  bool _foundDeviceWaitingToConnect = false;
  bool _scanStarted = false;
  bool _connected = false;
  late DiscoveredDevice _nftDevice;
  final flutterReactiveBle = FlutterReactiveBle();
  late StreamSubscription<DiscoveredDevice> _scanStream;
  late QualifiedCharacteristic _rxCharacteristic;
  final Uuid serviceUuid = Uuid.parse("4fafc201-1fb5-459e-8fcc-c5c9c331914b");
  final Uuid characteristicUuid =
      Uuid.parse("beb5483e-36e1-4688-b7f5-ea07361b26a8");

  void _startScan() async {
    setState(() {
      _scanStarted = true;
    });

    if (true) {
      _scanStream = flutterReactiveBle
          .scanForDevices(withServices: [serviceUuid]).listen((device) {
        setState(() {
          _nftDevice = device;
          _foundDeviceWaitingToConnect = true;
        });
      });
    }
  }

  void _connectToDevice() {
    _scanStream.cancel();
    Stream<ConnectionStateUpdate> _currentConnectionStream = flutterReactiveBle
        .connectToAdvertisingDevice(
            id: _nftDevice.id,
            prescanDuration: const Duration(seconds: 1),
            withServices: [serviceUuid, characteristicUuid]);
    _currentConnectionStream.listen((event) {
      switch (event.connectionState) {
        case DeviceConnectionState.connected:
          {
            _rxCharacteristic = QualifiedCharacteristic(
                serviceId: serviceUuid,
                characteristicId: characteristicUuid,
                deviceId: event.deviceId);
            setState(() {
              _foundDeviceWaitingToConnect = false;
              _connected = true;
            });
            break;
          }
        case DeviceConnectionState.disconnected:
          {
            break;
          }
        default:
      }
    });
  }

  void _sendData() {
    if (_connected) {
      flutterReactiveBle
          .writeCharacteristicWithResponse(_rxCharacteristic, value: [
            0xff,
          ])
          .whenComplete(() => debugPrint("Complete"))
          .onError((error, stackTrace) => debugPrint(error.toString()));
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (_connected) {
      return Center(
        child: Column(
          children: [
            const Text("Device Connected"),
            ElevatedButton(
              child: const Text("Send Data"),
              onPressed: _sendData,
            ),
          ],
        ),
      );
    } else {
      if (_foundDeviceWaitingToConnect) {
        return Center(
          child: Column(
            children: [
              const Text("Device Found"),
              Text(_nftDevice.name.toString()),
              Text(_nftDevice.id.toString()),
              Text(_nftDevice.manufacturerData.toString()),
              ElevatedButton(
                child: const Text("Connect to Device"),
                onPressed: _connectToDevice,
              ),
            ],
          ),
        );
      } else {
        if (_scanStarted) {
          return const Center(
            child: Text("Scannig for device"),
          );
        } else {
          return Center(
            child: ElevatedButton(
              child: const Text("Start Scan"),
              onPressed: _startScan,
            ),
          );
        }
      }
    }
  }
}
