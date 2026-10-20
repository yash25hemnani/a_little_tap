import 'package:a_little_tap/core/theme/app_colors.dart';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/material.dart';

class PulsingIcon extends StatelessWidget {
  final double size;
  final IconData icon;
  final Color iconColor;
  final Color backgroundColor;
  final Color ringColor;
  final int ringCount;
  final double ringSpread;
  final Duration pulseDuration;
  final Object heroTag;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const PulsingIcon({
    super.key,
    this.size = 160,
    this.icon = Icons.favorite_rounded,
    this.iconColor = AppColors.heart,
    this.backgroundColor = AppColors.softPink,
    this.ringColor = AppColors.primary,
    this.ringCount = 3,
    this.ringSpread = 0.4,
    this.pulseDuration = const Duration(milliseconds: 2400),
    this.heroTag = 'heart',
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: heroTag,
      // Fly a still icon; the rings restart on the screen it lands on
      flightShuttleBuilder: (_, _, _, _, _) => FittedBox(child: _avatar()),
      child: AvatarGlow(
        glowColor: ringColor,
        glowCount: ringCount,
        glowRadiusFactor: ringSpread,
        duration: pulseDuration,
        child: GestureDetector(
          onTap: onTap,
          onLongPress: onLongPress,
          child: _avatar(),
        ),
      ),
    );
  }

  Widget _avatar() {
    return CircleAvatar(
      radius: size / 2,
      backgroundColor: backgroundColor,
      child: Icon(icon, size: size * 0.45, color: iconColor),
    );
  }
}
