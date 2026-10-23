import 'dart:async';
import 'dart:math';

import 'package:a_little_tap/core/theme/app_colors.dart';
import 'package:a_little_tap/features/feelings/models/feeling.dart';
import 'package:a_little_tap/features/feelings/utils/play_vibration.dart';
import 'package:a_little_tap/features/home/widgets/pulsing_icon.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class ReceivedScreen extends StatefulWidget {
  final String partnerName;
  // Changes when another tap arrives while this screen is open
  final ValueListenable<Feeling> feeling;
  final bool vibrate; // the user's Vibration setting

  const ReceivedScreen({
    super.key,
    required this.partnerName,
    required this.feeling,
    this.vibrate = true,
  });

  // Opens the screen and finishes once it has closed
  static Future<void> show(
    BuildContext context, {
    required String partnerName,
    required ValueListenable<Feeling> feeling,
    bool vibrate = true,
  }) {
    return Navigator.of(context).push(
      PageRouteBuilder<void>(
        transitionDuration: const Duration(milliseconds: 700),
        reverseTransitionDuration: const Duration(milliseconds: 1000),
        pageBuilder: (_, _, _) => ReceivedScreen(
          partnerName: partnerName,
          feeling: feeling,
          vibrate: vibrate,
        ),
        transitionsBuilder: (_, animation, _, child) => FadeTransition(
          opacity: CurvedAnimation(
            parent: animation,
            curve: const Interval(0, 0.4, curve: Curves.easeOut),
          ),
          child: child,
        ),
      ),
    );
  }

  @override
  State<ReceivedScreen> createState() => _ReceivedScreenState();
}

class _ReceivedScreenState extends State<ReceivedScreen> {
  Timer? _closeTimer;

  @override
  void initState() {
    super.initState();
    widget.feeling.addListener(_onTap);
    _onTap();
  }

  @override
  void dispose() {
    _closeTimer?.cancel();
    widget.feeling.removeListener(_onTap);
    super.dispose();
  }

  // Plays the tap's pattern and restarts the countdown to close
  void _onTap() {
    final feeling = widget.feeling.value;
    if (widget.vibrate) playVibration(feeling.vibration);

    _closeTimer?.cancel();
    _closeTimer = Timer(
      Duration(milliseconds: max(2500, feeling.totalVibrationMs)),
      _close,
    );
  }

  // Only pops while this screen is on top, so nothing else gets closed
  void _close() {
    if (!mounted) return;
    if (ModalRoute.of(context)?.isCurrent ?? false) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return Scaffold(
      body: ValueListenableBuilder<Feeling>(
        valueListenable: widget.feeling,
        builder: (_, feeling, _) => GestureDetector(
          // Tap anywhere to close early
          behavior: HitTestBehavior.opaque,
          onTap: _close,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            decoration: BoxDecoration(gradient: feeling.background),
            child: SafeArea(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Center(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: PulsingIcon(
                        // A moment's feeling id is the moment id, so every tap swaps in fresh
                        key: ValueKey(feeling.id),
                        // Unique tag, so Home's heart doesn't fly in
                        heroTag: 'received-${feeling.id}',
                        size: 200,
                        icon: feeling.icon,
                        iconColor: feeling.color,
                        backgroundColor: feeling.circleColor,
                        ringColor: feeling.ringColor,
                      ),
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
                            'From ${widget.partnerName}',
                            style: text.bodyMedium?.copyWith(
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 6),
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 250),
                            child: Text(
                              feeling.title,
                              key: ValueKey(feeling.id),
                              style: text.titleLarge?.copyWith(
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.topRight,
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: IconButton(
                        icon: const Icon(Icons.close_rounded),
                        color: AppColors.textSecondary,
                        onPressed: _close,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
