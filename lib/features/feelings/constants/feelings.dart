import 'package:a_little_tap/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

// Firestore stores the key; const IconData only, so tree-shaking keeps working
const feelingIcons = <String, IconData>{
  'heart': Icons.favorite_rounded,
  'flower': Icons.local_florist_rounded,
  'sun': Icons.wb_sunny_rounded,
  'star': Icons.star_rounded,
  'moon': Icons.nightlight_round,
  'hug': Icons.volunteer_activism_rounded,
  'coffee': Icons.coffee_rounded,
  'music': Icons.music_note_rounded,
  'party': Icons.celebration_rounded,
  'spa': Icons.spa_rounded,
  'smile': Icons.emoji_emotions_rounded,
  'cloud': Icons.cloud_rounded,
  'laugh': Icons.sentiment_very_satisfied_rounded,
  'bolt': Icons.bolt_rounded,
  'rainbow': Icons.looks_rounded,
  'gift': Icons.card_giftcard_rounded,
  'food': Icons.restaurant_rounded,
  'bed': Icons.bed_rounded,
  'home': Icons.home_rounded,
  'sparkle': Icons.auto_awesome_rounded,
};

// Base colors offered in the add sheet; ring, circle and gradient derive from these
// Ordered warm → cool → neutral so the swatch row reads as a gradient
const feelingColors = <Color>[
  AppColors.heart,
  AppColors.rose,
  AppColors.berry,
  AppColors.coral,
  AppColors.peach,
  AppColors.tangerine,
  AppColors.sunny,
  AppColors.honey,
  AppColors.lime,
  AppColors.sage,
  AppColors.mint,
  AppColors.teal,
  AppColors.sky,
  AppColors.ocean,
  AppColors.periwinkle,
  AppColors.lavender,
  AppColors.violet,
  AppColors.plum,
  AppColors.mocha,
  AppColors.slate,
];

// Seeded into every new user's feelings subcollection
// color is ARGB as an int (same values as AppColors.heart / lavender / sunny)
const defaultFeelings = <Map<String, Object>>[
  {
    'title': 'Miss you',
    'subtitle': "You're on my mind.",
    'iconKey': 'heart',
    'color': 0xFFF2546B,
  },
  {
    'title': 'Thinking of you',
    'subtitle': 'Just wanted to say hi.',
    'iconKey': 'flower',
    'color': 0xFF8E8CE0,
  },
  {
    'title': 'Here for you',
    'subtitle': "You're not alone.",
    'iconKey': 'sun',
    'color': 0xFFF5A623,
  },
];
