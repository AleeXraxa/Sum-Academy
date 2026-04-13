import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class SecureScreenService {
  static const MethodChannel _channel = MethodChannel('secure_screen');
  static int _refCount = 0;

  static Future<void> enable() async {
    if (kIsWeb) return;
    _refCount += 1;
    if (_refCount != 1) return;
    try {
      await _channel.invokeMethod('enable');
    } catch (_) {}
  }

  static Future<void> disable() async {
    if (kIsWeb) return;
    if (_refCount > 0) {
      _refCount -= 1;
    }
    if (_refCount != 0) return;
    try {
      await _channel.invokeMethod('disable');
    } catch (_) {}
  }

  static Future<void> reset() async {
    if (kIsWeb) return;
    _refCount = 0;
    try {
      await _channel.invokeMethod('disable');
    } catch (_) {}
  }
}
