import 'package:flutter/services.dart';

abstract final class LegacyVivoBadge {
  static const _channel = MethodChannel('campus_notify/legacy_vivo_badge');
  static Future<bool> isSupported() async =>
      await _channel.invokeMethod<bool>('supported') ?? false;
  static Future<void> update(int count) =>
      _channel.invokeMethod<void>('update', count);
  static Future<Map<String, dynamic>> audioStatus() async =>
      Map<String, dynamic>.from(
        await _channel.invokeMapMethod<String, dynamic>('audio') ?? {},
      );
}
