import 'package:a_little_tap/core/theme/app_theme.dart';
import 'package:a_little_tap/features/splash/screens/splash_screen.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
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
