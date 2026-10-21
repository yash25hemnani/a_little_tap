import 'package:a_little_tap/features/feelings/constants/vibration_limits.dart';
import 'package:a_little_tap/features/feelings/models/vibration_step.dart';
import 'package:vibration/vibration.dart';

Future<void> playVibration(List<VibrationStep> steps) async {
  if (steps.isEmpty || !(await Vibration.hasVibrator())) return;

  // Patterns over the limits are skipped, the editor never saves them
  if (steps.length > maxVibrationSteps) return;
  if (steps.fold(0, (sum, s) => sum + s.ms) > maxVibrationMs) return;

  if (await Vibration.hasAmplitudeControl()) {
    // Every step is its own segment, amp 0 is silent
    Vibration.vibrate(
      pattern: [0, ...steps.map((s) => s.ms)],
      intensities: [0, ...steps.map((s) => s.amp)],
    );
  } else {
    Vibration.vibrate(pattern: _waitBuzzPattern(steps));
  }
}

// Without amplitude control the pattern must alternate wait, buzz, wait, ...
// Back-to-back buzzes (or pauses) are joined into one segment
List<int> _waitBuzzPattern(List<VibrationStep> steps) {
  final pattern = [0];
  var nextIsBuzz = true;

  for (final step in steps) {
    if (step.isPause != nextIsBuzz) {
      pattern.add(step.ms);
      nextIsBuzz = !nextIsBuzz;
    } else {
      pattern.last += step.ms;
    }
  }

  return pattern;
}
