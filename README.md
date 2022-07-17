
## Introduction

Posix SDK is a bluetooth plugin for [Flutter](https://flutter.dev), a new app SDK to help developers build modern multi-platform apps.
Sample app [Github](https://github.com/SentraxSupport/posix_sdk/tree/main/example) link.

## Cross-Platform Bluetooth LE
Posix SDK aims to offer the most from both platforms (iOS and Android).

Using the Posix SDK instance, you can scan for and check LED to nearby devices ([BluetoothDevice](#bluetoothdevice-api)).

## Usage
### Obtain an instance
```dart
PosixSdk posixSdk = PosixSdk.instance;
```

### Check LED for devices
```dart
// Start scanning
posixSdk.connect(device: result.device);
```

## Getting Started
### Change the minSdkVersion for Android

Flutter_blue is compatible only from version 19 of Android SDK so you should change this in **android/app/build.gradle**:
```dart
Android {
  defaultConfig {
     minSdkVersion: 19
```
### Add permissions for Bluetooth
We need to add the permission to use Bluetooth and access location:

#### **Android**
In the **android/app/src/main/AndroidManifest.xml** let’s add:

```xml 
	 <uses-permission android:name="android.permission.BLUETOOTH" />  
	 <uses-permission android:name="android.permission.BLUETOOTH_ADMIN" />  
	 <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>  
 <application
```
#### **IOS**
In the **ios/Runner/Info.plist** let’s add:

```dart 
	<dict>  
	    <key>NSBluetoothAlwaysUsageDescription</key>  
	    <string>Need BLE permission</string>  
	    <key>NSBluetoothPeripheralUsageDescription</key>  
	    <string>Need BLE permission</string>  
	    <key>NSLocationAlwaysAndWhenInUseUsageDescription</key>  
	    <string>Need Location permission</string>  
	    <key>NSLocationAlwaysUsageDescription</key>  
	    <string>Need Location permission</string>  
	    <key>NSLocationWhenInUseUsageDescription</key>  
	    <string>Need Location permission</string>
```

For location permissions on iOS see more at: [https://developer.apple.com/documentation/corelocation/requesting_authorization_for_location_services](https://developer.apple.com/documentation/corelocation/requesting_authorization_for_location_services)

