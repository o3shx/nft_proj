import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:http/http.dart';
import 'package:location/location.dart';

class DevicePairingPage extends StatefulWidget {
  const DevicePairingPage({Key? key}) : super(key: key);

  @override
  State<DevicePairingPage> createState() => _DevicePairingPageState();
}

class _DevicePairingPageState extends State<DevicePairingPage> {
  bool _foundDeviceWaitingToConnect = false;
  String _url =
      "https://lh3.googleusercontent.com/LM1nakX82b3z6fK5ii8gjQaVG7AwjCrMimmQ-f65pEk2fZ5CenZWGE9_pZrFoGEYKoaZKwUOTyLLuHnB5hcj1g8uugPvn_T_ZlEdJA";
  bool _scanStarted = false;
  bool _connected = false;
  List<int> hexList = [];
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

  // void getDummyImage() async {
  //   Uri url = Uri.parse(
  //       "https://lh3.googleusercontent.com/LM1nakX82b3z6fK5ii8gjQaVG7AwjCrMimmQ-f65pEk2fZ5CenZWGE9_pZrFoGEYKoaZKwUOTyLLuHnB5hcj1g8uugPvn_T_ZlEdJA"); // <-- 1
  //   var response = await get(url);
  //   final bytes = response.bodyBytes;
  //   hexList = bytes;
  //   // String img64 = base64Encode(bytes);
  //   // print(img64);
  // }

  void _sendData() async {
    Uri url = Uri.parse(
        "https://lh3.googleusercontent.com/LM1nakX82b3z6fK5ii8gjQaVG7AwjCrMimmQ-f65pEk2fZ5CenZWGE9_pZrFoGEYKoaZKwUOTyLLuHnB5hcj1g8uugPvn_T_ZlEdJA"); // <-- 1
    var response = await get(url);
    final bytes = response.bodyBytes;
    debugPrint(bytes.toString());
    if (_connected) {
      flutterReactiveBle
          .writeCharacteristicWithResponse(_rxCharacteristic, value: bytes)
          .whenComplete(() => debugPrint("Complete"))
          .catchError((onError) {
        debugPrint(onError.toString());
      }).onError((error, stackTrace) => debugPrint(error.toString()));
    }
  }

  void _readData() {
    if (_connected) {
      flutterReactiveBle.readCharacteristic(_rxCharacteristic).then((value) {
        for (var element in value) {
          print(element);
        }
      });
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
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.network(
                _url,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) {
                    return child;
                  }
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                            : null,
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            const Text("Device Connected"),
            const SizedBox(
              height: 10,
            ),
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
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("Device Found"),
              const SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Name: "),
                  Text(_nftDevice.name.toString()),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("ID: "),
                  Text(_nftDevice.id.toString()),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              // Text(_nftDevice.manufacturerData.toString()),
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
            child: Text("Scanning for device"),
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
