import 'dart:io';

import 'package:app_badge_plus/app_badge_plus.dart';
import 'package:legacy_vivo_badge/legacy_vivo_badge.dart';

abstract final class LauncherBadge {
  static bool _legacy = false;
  static Future<bool> isSupported() async {
    _legacy = Platform.isAndroid && await LegacyVivoBadge.isSupported();
    return _legacy || await AppBadgePlus.isSupported();
  }

  static Future<void> update(int count) =>
      _legacy ? LegacyVivoBadge.update(count) : AppBadgePlus.updateBadge(count);
}
