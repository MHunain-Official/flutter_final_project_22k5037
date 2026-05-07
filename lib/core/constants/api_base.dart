import 'package:flutter/foundation.dart';

/// Host the Node server runs on (see `server/server.js`).
const int kApiPort = 3000;

/// Android emulator maps this to the machine's localhost.
const String _androidLoopback = 'http://10.0.2.2:$kApiPort';

/// Desktop, iOS simulator, and physical devices on same LAN use loopback or LAN IP.
const String _desktopLoopback = 'http://127.0.0.1:$kApiPort';

/// Base URL for Dio — must not be `10.0.2.2` on Linux/macOS/Windows or requests never reach the server.
String resolveApiBase() {
  if (kIsWeb) return _desktopLoopback;
  switch (defaultTargetPlatform) {
    case TargetPlatform.android:
      return _androidLoopback;
    default:
      return _desktopLoopback;
  }
}
