import 'package:a_little_tap/features/feelings/constants/vibration_limits.dart';

class VibrationStep {
  final int ms;
  final int amp; // 0 = pause, 1-255 = strength

  const VibrationStep({required this.ms, required this.amp});

  bool get isPause => amp == 0;

  Map<String, dynamic> toMap() => {'ms': ms, 'amp': amp};

  // Clamped so a bad doc can't produce an invalid pattern
  factory VibrationStep.fromMap(Map<String, dynamic> map) => VibrationStep(
    ms: ((map['ms'] as num?)?.toInt() ?? minStepMs).clamp(
      minStepMs,
      maxVibrationMs,
    ),
    amp: ((map['amp'] as num?)?.toInt() ?? 0).clamp(0, maxAmp),
  );
}
