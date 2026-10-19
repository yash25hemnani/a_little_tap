import 'package:a_little_tap/core/theme/app_colors.dart';
import 'package:a_little_tap/features/home/haptics/tap_haptics.dart';
import 'package:a_little_tap/features/home/widgets/pulsing_heart.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: Center(child: PulsingHeart(onTap: TapHaptics.heartbeat)),
      ),
    );
  }
}
