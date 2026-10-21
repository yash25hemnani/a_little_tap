import 'dart:async';
import 'dart:math';
import 'package:a_little_tap/features/feelings/models/feeling.dart';
import 'package:a_little_tap/core/theme/app_colors.dart';
import 'package:a_little_tap/features/feelings/utils/play_vibration.dart';
import 'package:a_little_tap/features/home/widgets/pulsing_icon.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class SendingScreen extends StatelessWidget {
  final String partnerName;
  final Feeling feeling;
  // Flips to true once the write lands, switching the label to "Sent to"
  final ValueListenable<bool> sent;

  const SendingScreen({
    super.key,
    required this.partnerName,
    required this.feeling,
    required this.sent,
  });

  // Opens the screen, waits for the send (at least 2.2s, at most 5s),
  // shows "Sent" for a moment on success, then closes it.
  // The heart flies from Home to the centre via the Hero in PulsingIcon.
  static Future<void> show(
    BuildContext context, {
    required String partnerName,
    required Feeling feeling,
    required Future<void> Function() send,
    bool vibrate = true, // the user's Vibration setting
  }) async {
    final sent = ValueNotifier(false);

    final route = PageRouteBuilder<void>(
      transitionDuration: const Duration(milliseconds: 700),
      reverseTransitionDuration: const Duration(milliseconds: 1000),
      pageBuilder: (_, _, _) =>
          SendingScreen(partnerName: partnerName, feeling: feeling, sent: sent),
      transitionsBuilder: (_, animation, _, child) => FadeTransition(
        opacity: CurvedAnimation(
          parent: animation,
          curve: const Interval(0, 0.4, curve: Curves.easeOut),
        ),
        child: child,
      ),
    );

    Navigator.of(context).push(route);

    String? error;
    try {
      await Future.wait([
        send().timeout(const Duration(seconds: 5)),
        Future.delayed(const Duration(milliseconds: 2200)),
      ]);
    } on TimeoutException {
      // Firestore keeps the write queued and sends it once back online
      error = "You're offline. It'll send when you're back online";
    } catch (e, st) {
      debugPrint('send failed: $e\n$st');
      error = "Couldn't send, try again";
    }

    // Hold "Sent" for at least 0.7s, or until the pattern finishes
    if (error == null) {
      if (vibrate) playVibration(feeling.vibration);
      sent.value = true;
      final holdMs = vibrate ? max(700, feeling.totalVibrationMs) : 700;
      await Future.delayed(Duration(milliseconds: holdMs));
    }

    // Home's context, checked because we awaited
    if (!context.mounted) return;

    if (error != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error)));
    }

    // Skip if the user already backed out, so Home isn't popped
    if (route.isCurrent) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

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
                      ValueListenableBuilder<bool>(
                        valueListenable: sent,
                        builder: (_, done, _) => AnimatedSwitcher(
                          duration: const Duration(milliseconds: 250),
                          child: Text(
                            done
                                ? 'Sent to $partnerName'
                                : 'Sending to $partnerName',
                            // New key so the switcher fades between the two
                            key: ValueKey(done),
                            style: text.bodyMedium?.copyWith(
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
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
