import 'package:a_little_tap/core/theme/app_theme.dart';
import 'package:a_little_tap/features/splash/screens/splash_screen.dart';
import 'package:a_little_tap/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
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
