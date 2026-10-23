import 'dart:convert';

import 'package:a_little_tap/core/theme/app_theme.dart';
import 'package:a_little_tap/features/feelings/models/vibration_step.dart';
import 'package:a_little_tap/features/feelings/utils/play_vibration.dart';
import 'package:a_little_tap/features/notifications/services/tap_notifier.dart';
import 'package:a_little_tap/features/splash/screens/splash_screen.dart';
import 'package:a_little_tap/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

@pragma('vm:entry-point')
Future<void> _onBackgroundMessage(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final data = message.data; // Map<String, dynamic>, every value is a String

  await TapNotifier.init();

  if (_isReminder(message)) {
    await _showReminder(message);
    return;
  }

  final colorValue = int.tryParse(data['color'] as String? ?? '');
  await TapNotifier.show(
    data['title'] ?? '',
    data['body'] ?? '',
    color: colorValue == null ? null : Color(colorValue),
  );

  final raw = data['vibration'] as String? ?? '';

  if (raw.isEmpty) return;

  final steps = (jsonDecode(raw) as List)
      .map((s) => VibrationStep.fromMap(s as Map<String, dynamic>))
      .toList();

  await playVibration(steps);
}

bool _isReminder(RemoteMessage message) => message.data['type'] == 'reminder';

Future<void> _showReminder(RemoteMessage message) {
  final data = message.data;

  return TapNotifier.showReminder(
    data['title'] ?? '',
    data['body'] ?? '',
    data['eventId'] ?? '',
  );
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await TapNotifier.init();
  FirebaseMessaging.onBackgroundMessage(_onBackgroundMessage);

  // Data-only pushes show nothing while the app is open; taps are handled by
  // the Firestore listener, so only reminders need showing here
  FirebaseMessaging.onMessage.listen((message) {
    if (_isReminder(message)) _showReminder(message);
  });
  runApp(ProviderScope(child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'A Little Tap',
      theme: AppTheme.light,
      home: SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
