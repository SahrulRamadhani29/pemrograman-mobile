import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'data/config.dart';
import 'messaging/push_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await prepareDevelopmentTls();
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  runApp(const ProviderScope(child: CampusApp()));
}
