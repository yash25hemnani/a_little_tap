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
// vibration steps are {ms, amp}, amp 0 is a pause
const defaultFeelings = <Map<String, Object>>[
  {
    'title': 'Miss you',
    'subtitle': "You're on my mind.",
    'iconKey': 'heart',
    'color': 0xFFF2546B,
    // Two heartbeats, the second softer (940ms)
    'vibration': [
      {'ms': 80, 'amp': 180},
      {'ms': 100, 'amp': 0},
      {'ms': 140, 'amp': 255},
      {'ms': 300, 'amp': 0},
      {'ms': 80, 'amp': 150},
      {'ms': 100, 'amp': 0},
      {'ms': 140, 'amp': 220},
    ],
  },
  {
    'title': 'Thinking of you',
    'subtitle': 'Just wanted to say hi.',
    'iconKey': 'flower',
    'color': 0xFF8E8CE0,
    // Three soft, slow waves that grow a little (1150ms)
    'vibration': [
      {'ms': 250, 'amp': 80},
      {'ms': 150, 'amp': 0},
      {'ms': 250, 'amp': 120},
      {'ms': 150, 'amp': 0},
      {'ms': 350, 'amp': 160},
    ],
  },
  {
    'title': 'Here for you',
    'subtitle': "You're not alone.",
    'iconKey': 'sun',
    'color': 0xFFF5A623,
    // A rising swell held strong, then a gentle squeeze (1350ms)
    'vibration': [
      {'ms': 150, 'amp': 90},
      {'ms': 150, 'amp': 140},
      {'ms': 150, 'amp': 190},
      {'ms': 400, 'amp': 240},
      {'ms': 200, 'amp': 0},
      {'ms': 300, 'amp': 150},
    ],
  },
];
