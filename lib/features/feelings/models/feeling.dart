import 'package:a_little_tap/features/feelings/constants/feelings.dart';
import 'package:flutter/material.dart';

class Feeling {
  final String id;
  final String title;
  final String subtitle;
  final String iconKey;
  final int colorValue; // firestore field 'color'
  final int order;

  const Feeling({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.iconKey,
    required this.colorValue,
    required this.order,
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
  };

  factory Feeling.fromMap(String id, Map<String, dynamic> map) => Feeling(
    id: id,
    title: map['title'] as String? ?? '',
    subtitle: map['subtitle'] as String? ?? '',
    iconKey: map['iconKey'] as String? ?? 'heart',
    colorValue: map['color'] as int? ?? 0xFFF2546B, // heart
    order: map['order'] as int? ?? 0, // moments have no order
  );
}
