import 'package:a_little_tap/core/theme/app_colors.dart';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/material.dart';

class PulsingHeart extends StatelessWidget {
  final double size;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const PulsingHeart({super.key, this.size = 160, this.onTap, this.onLongPress});

  @override
  Widget build(BuildContext context) {
    return AvatarGlow(
      glowColor: AppColors.primary,
      glowCount: 3,
      glowRadiusFactor: 0.4,
      duration: const Duration(milliseconds: 2400),
      child: GestureDetector(
        onTap: onTap,
        onLongPress: onLongPress,
        child: CircleAvatar(
          radius: size / 2,
          backgroundColor: AppColors.softPink,
          child: Icon(
            Icons.favorite_rounded,
            size: size * 0.45,
            color: AppColors.heart,
          ),
        ),
      ),
    );
  }
}
