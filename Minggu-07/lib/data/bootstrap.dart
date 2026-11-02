import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import 'api/config.dart';
import 'services/push_background_handler.dart';

Future<void> initializeInfrastructure() async {
  debugPrint('Campus startup: preparing TLS');
  await prepareDevelopmentTls();
  debugPrint('Campus startup: initializing Firebase');
  await Firebase.initializeApp();
  debugPrint('Campus startup: registering background handler');
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
}
