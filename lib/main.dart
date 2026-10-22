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

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await TapNotifier.init();
  FirebaseMessaging.onBackgroundMessage(_onBackgroundMessage);
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
