library posix_sdk;

import 'dart:async';

import 'package:convert/convert.dart';
import 'package:flutter_blue/flutter_blue.dart';

import 'Uuid.dart';

class PosixSdk {
  late StreamSubscription<BluetoothDeviceState> deviceState;
  final Uuid _UART_UUID = Uuid.parse("6E400001-B5A3-F393-E0A9-E50E24DCCA9E");
  final Uuid _AUTH_UUID = Uuid.parse("955A152A-0FE2-F5AA-A094-84B8D4F3E8AD");
  final Uuid _UART_RX = Uuid.parse("6E400002-B5A3-F393-E0A9-E50E24DCCA9E");
  final Uuid _LED_UUID = Uuid.parse("955A152D-0FE2-F5AA-A094-84B8D4F3E8AD");
  // final Uuid _UART_TX = Uuid.parse("6E400003-B5A3-F393-E0A9-E50E24DCCA9E");

  List<int> _getAuthBytes() {
    return hex.decode("FFFF31323334");
  }

  List<int> _getLedBytes() {
    return hex.decode("1502");
  }

  List<int> _getBytes(String rawHex) {
    return hex.decode(rawHex);
  }

  /// Singleton boilerplate
  PosixSdk._();

  static final PosixSdk _instance = PosixSdk._();

  static PosixSdk get instance => _instance;

  /// Establishes a connection to the Bluetooth Device.
  Future<void> connect({required BluetoothDevice device}) async {
    BluetoothCharacteristic? mRXCharacteristic, mAuthCharacteristic, mLedCharacteristic;
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
                }else{
                  for (var characteristic in service.characteristics) {
                    print('================================ characteristic ${characteristic.uuid.toString().toUpperCase()} ================================');
                    if (_AUTH_UUID.toString().toUpperCase() == characteristic.uuid.toString().toUpperCase()) {
                      print('================================ _AUTH_UUID ${characteristic.uuid.toString().toUpperCase()} ================================');
                      mAuthCharacteristic = characteristic;
                    }
                    if (_LED_UUID.toString().toUpperCase() == characteristic.uuid.toString().toUpperCase()) {
                      print('================================ _LED_UUID ${characteristic.uuid.toString().toUpperCase()} ================================');
                      mLedCharacteristic = characteristic;
                    }
                  }
                }
              }
            });
          });
          Timer(const Duration(seconds: 2), () {
            if (mRXCharacteristic != null) {
              _posixLed(mRXCharacteristic!);
            } else if (mAuthCharacteristic != null && mLedCharacteristic != null) {
              _otherLed(mAuthCharacteristic!, mLedCharacteristic!);
            }
          });

          Timer(const Duration(seconds: 7), () {
            device.disconnect();
          });

          break;
        case BluetoothDeviceState.disconnecting:
          print('================================ disconnecting ================================');
          break;
      }
    });
  }

  void _posixLed(BluetoothCharacteristic rx) async {
    await rx.write(_getAuthBytes(), withoutResponse: true);
    print('================================ Authenticated ${_getLedBytes().toString()} ================================');
    await rx.write(_getLedBytes(), withoutResponse: true);
    print('================================ LED ${_getLedBytes().toString()} ================================');
  }

  void _otherLed(BluetoothCharacteristic auth, BluetoothCharacteristic led) async {
    await auth.write(_getBytes("29568174"), withoutResponse: true);
    print('================================ Authenticated ${_getBytes("29568174").toString()} ================================');
    await led.write(_getBytes("0100"), withoutResponse: true);
    print('================================ LED ${_getBytes("0100").toString()} ================================');
  }
}