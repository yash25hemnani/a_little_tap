import 'package:a_little_tap/features/feelings/constants/feelings.dart';
import 'package:a_little_tap/features/feelings/models/vibration_step.dart';
import 'package:flutter/material.dart';

// Two heartbeats, used when a feeling has no saved pattern
// Each beat is a soft "lub" then a stronger "dub" (940ms total)
const defaultVibration = <VibrationStep>[
  VibrationStep(ms: 80, amp: 180),
  VibrationStep(ms: 100, amp: 0),
  VibrationStep(ms: 140, amp: 255),
  VibrationStep(ms: 300, amp: 0),
  VibrationStep(ms: 80, amp: 150),
  VibrationStep(ms: 100, amp: 0),
  VibrationStep(ms: 140, amp: 220),
];

class Feeling {
  final String id;
  final String title;
  final String subtitle;
  final String iconKey;
  final int colorValue; // firestore field 'color'
  final int order;
  final List<VibrationStep> vibration;

  const Feeling({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.iconKey,
    required this.colorValue,
    required this.order,
    this.vibration = defaultVibration,
  });

  IconData get icon => feelingIcons[iconKey] ?? Icons.favorite_rounded;

  Color get color => Color(colorValue);
  Color get ringColor => color;
  Color get circleColor => Color.lerp(color, Colors.white, 0.88)!;

  Gradient get background => LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color.lerp(color, Colors.white, 0.95)!, circleColor],
  );

  Map<String, dynamic> toMap() => {
    'title': title,
    'subtitle': subtitle,
    'iconKey': iconKey,
    'color': colorValue,
    'order': order,
    'vibration': vibration.map((v) => v.toMap()).toList(),
  };

  int get totalVibrationMs => vibration.fold(0, (sum, step) => sum + step.ms);

  factory Feeling.fromMap(String id, Map<String, dynamic> map) => Feeling(
    id: id,
    title: map['title'] as String? ?? '',
    subtitle: map['subtitle'] as String? ?? '',
    iconKey: map['iconKey'] as String? ?? 'heart',
    colorValue: map['color'] as int? ?? 0xFFF2546B, // heart
    order: map['order'] as int? ?? 0, // moments have no order
    // Missing falls back to the default heartbeat
    vibration:
        (map['vibration'] as List<dynamic>?)
            ?.map((s) => VibrationStep.fromMap(s as Map<String, dynamic>))
            .toList() ??
        defaultVibration,
  );
}
