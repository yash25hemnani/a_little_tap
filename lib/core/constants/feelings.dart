import 'package:a_little_tap/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

// color = icon, ringColor = pulse rings, circleColor = behind the icon,
// background = sending screen gradient
typedef Feeling = ({
  IconData icon,
  Color color,
  Color ringColor,
  Color circleColor,
  Gradient background,
  String title,
  String subtitle,
});

const feelings = <Feeling>[
  (
    icon: Icons.favorite_rounded,
    color: AppColors.heart,
    ringColor: AppColors.primary,
    circleColor: AppColors.softPink,
    background: AppColors.backgroundGradient,
    title: 'Miss you',
    subtitle: "You're on my mind.",
  ),
  (
    icon: Icons.local_florist_rounded,
    color: AppColors.lavender,
    ringColor: AppColors.lavender,
    circleColor: AppColors.lavenderSoft,
    background: AppColors.tapBackGradient,
    title: 'Thinking of you',
    subtitle: 'Just wanted to say hi.',
  ),
  (
    icon: Icons.wb_sunny_rounded,
    color: AppColors.sunny,
    ringColor: AppColors.sunny,
    circleColor: AppColors.sunnySoft,
    background: AppColors.sunnyGradient,
    title: 'Here for you',
    subtitle: "You're not alone.",
  ),
];
