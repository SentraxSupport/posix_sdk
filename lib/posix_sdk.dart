library posix_sdk;

import 'dart:async';

import 'package:convert/convert.dart';
import 'package:flutter_blue/flutter_blue.dart';

import 'Uuid.dart';

class PosixSdk {
  late BluetoothCharacteristic? mRXCharacteristic;
  late StreamSubscription<BluetoothDeviceState> deviceState;
  final Uuid _UART_UUID = Uuid.parse("6E400001-B5A3-F393-E0A9-E50E24DCCA9E");
  final Uuid _UART_RX = Uuid.parse("6E400002-B5A3-F393-E0A9-E50E24DCCA9E");
  final Uuid _UART_TX = Uuid.parse("6E400003-B5A3-F393-E0A9-E50E24DCCA9E");

  List<int> _getAuthBytes() {
    return hex.decode("FFFF31323334");
  }

  List<int> _getLedBytes() {
    return hex.decode("1502");
  }

  /// Singleton boilerplate
  PosixSdk._() {
    print("initialized FlutraxLed");
  }

  static final PosixSdk _instance = PosixSdk._();

  static PosixSdk get instance => _instance;

  /// Establishes a connection to the Bluetooth Device.
  Future<void> connect({required BluetoothDevice device}) async {
    await device.connect(autoConnect: false);

    deviceState = device.state.listen((event) async{
      switch (event) {
        case BluetoothDeviceState.disconnected:
          print('================================ disconnected ================================');
          break;
        case BluetoothDeviceState.connecting:
          print('================================ connecting ================================');
          break;
        case BluetoothDeviceState.connected:
          print('================================ connected ================================');

          device.discoverServices().then((services) {
            print('================================ Discovering ================================');
            device.services.listen((services) {
              for (var service in services) {
                if(_UART_UUID.toString().toUpperCase() == service.uuid.toString().toUpperCase()) {
                  for (var characteristic in service.characteristics) {
                    print('================================ ${characteristic.uuid.toString().toUpperCase()} ================================');
                    if (_UART_RX.toString().toUpperCase() == characteristic.uuid.toString().toUpperCase()) {
                      mRXCharacteristic = characteristic;
                    }
                  }
                }
              }
            });
          });

          Timer(const Duration(seconds: 2), () async{
            if(mRXCharacteristic != null){
              await mRXCharacteristic!.write(_getAuthBytes(), withoutResponse: true);
              print('================================ Authenticated ${_getLedBytes().toString()} ================================');
              await mRXCharacteristic!.write(_getLedBytes(), withoutResponse: true);
              print('================================ LED ${_getLedBytes().toString()} ================================');

              device.disconnect();
            }
          });

          Timer(const Duration(seconds: 5), () {
            device.disconnect();
          });

          break;
        case BluetoothDeviceState.disconnecting:
          print('================================ disconnecting ================================');
          break;
      }
    });
  }
}
