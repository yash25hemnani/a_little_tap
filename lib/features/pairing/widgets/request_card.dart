import 'package:a_little_tap/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class RequestCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<Widget> actions;

  const RequestCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.actions,
  });

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 22,
                backgroundColor: AppColors.softPink,
                child: Icon(Icons.favorite_rounded, size: 22, color: AppColors.heart),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: text.titleSmall),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: text.bodySmall?.copyWith(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            spacing: 8,
            children: actions,
          ),
        ],
      ),
    );
  }
}
