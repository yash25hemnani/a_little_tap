import 'package:vibration/vibration.dart';

class TapHaptics {
  TapHaptics._();

  static Future<void> heartbeat() async {
    // pattern = [wait, buzz, wait, buzz] in ms
    // intensities = strength for each entry, 0–255
    await Vibration.vibrate(
      pattern: [0, 60, 120, 40],
      intensities: [0, 255, 0, 120],
    );
  }
}
