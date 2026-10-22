import 'package:a_little_tap/core/theme/app_colors.dart';
import 'package:a_little_tap/features/feelings/models/feeling.dart';
import 'package:flutter/material.dart';

class PickerSheet extends StatelessWidget {
  final List<Feeling> feelings;
  const PickerSheet({super.key, required this.feelings});

  static Future<Feeling?> show(BuildContext context, List<Feeling> feelings) {
    return showModalBottomSheet<Feeling>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => PickerSheet(feelings: feelings),
    );
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Choose a feeling',
                style: text.titleMedium?.copyWith(color: AppColors.text),
              ),
              const SizedBox(height: 16),
              for (final f in feelings)
                _FeelingTile(
                  icon: f.icon,
                  color: f.color,
                  title: f.title,
                  subtitle: f.subtitle,
                  onTap: () => Navigator.pop(context, f),
                ),

              const SizedBox(height: 4),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeelingTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _FeelingTile({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.softPink, width: 1.5),
        ),
        leading: Icon(icon, size: 32, color: color),
        title: Text(title),
        subtitle: Text(
          subtitle,
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        onTap: onTap,
      ),
    );
  }
}
