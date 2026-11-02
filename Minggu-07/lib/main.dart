import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'data/bootstrap.dart';
import 'presentation/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  debugPrint('Campus startup: bindings ready');
  await initializeInfrastructure();
  debugPrint('Campus startup: infrastructure ready');
  runApp(const ProviderScope(child: CampusApp()));
}
