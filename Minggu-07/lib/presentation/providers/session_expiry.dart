import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

final sessionExpiryProvider = Provider<StreamController<void>>((ref) {
  final events = StreamController<void>.broadcast();
  ref.onDispose(() => unawaited(events.close()));
  return events;
});
