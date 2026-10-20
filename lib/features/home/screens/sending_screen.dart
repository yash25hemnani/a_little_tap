import 'package:a_little_tap/core/constants/feelings.dart';
import 'package:a_little_tap/core/theme/app_colors.dart';
import 'package:a_little_tap/features/home/widgets/pulsing_icon.dart';
import 'package:flutter/material.dart';

class SendingScreen extends StatefulWidget {
  final String partnerName;
  final Feeling feeling;

  const SendingScreen({
    super.key,
    required this.partnerName,
    required this.feeling,
  });

  // Fade in while the heart flies from Home to the centre (Hero in PulsingIcon)
  static Future<void> show(
    BuildContext context, {
    required String partnerName,
    required Feeling feeling,
  }) {
    return Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 700),
        reverseTransitionDuration: const Duration(milliseconds: 1000),
        pageBuilder: (_, _, _) =>
            SendingScreen(partnerName: partnerName, feeling: feeling),
        transitionsBuilder: (_, animation, _, child) =>
            FadeTransition(opacity: CurvedAnimation(parent: animation, curve: const Interval(0, 0.4, curve: Curves.easeOut)), child: child),
      ),
    );
  }

  @override
  State<SendingScreen> createState() => _SendingScreenState();
}

class _SendingScreenState extends State<SendingScreen> {
  @override
  void initState() {
    super.initState();
    // TapHaptics.heartbeat();

    // TODO: replace the delay with the real send
    Future.delayed(const Duration(milliseconds: 2200), () {
      if (mounted) Navigator.of(context).pop();
    });
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final feeling = widget.feeling;

    return Scaffold(
      body: Container(
        // Each feeling has its own screen colour
        decoration: BoxDecoration(gradient: feeling.background),
        child: SafeArea(
          // Stack keeps the heart at the true centre while the labels sit at the bottom
          child: Stack(
            fit: StackFit.expand,
            children: [
              Center(
                child: PulsingIcon(
                  size: 200,
                  icon: feeling.icon,
                  iconColor: feeling.color,
                  backgroundColor: feeling.circleColor,
                  ringColor: feeling.ringColor,
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 48),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Sending to ${widget.partnerName}',
                        style: text.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        feeling.title,
                        style: text.titleLarge?.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
