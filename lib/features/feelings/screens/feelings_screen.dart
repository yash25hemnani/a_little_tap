import 'package:a_little_tap/core/theme/app_colors.dart';
import 'package:a_little_tap/features/feelings/models/feeling.dart';
import 'package:a_little_tap/features/feelings/provider/feeling_provider.dart';
import 'package:a_little_tap/features/feelings/screens/edit_feeling_screen.dart';
import 'package:a_little_tap/features/home/widgets/info_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FeelingsScreen extends ConsumerWidget {
  const FeelingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final feelings = ref.watch(feelingProvider).value;
    // List is sorted by order, so the last one has the highest
    final nextOrder = (feelings?.lastOrNull?.order ?? -1) + 1;

    void open([Feeling? feeling]) => Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => EditFeelingScreen(
          feeling: feeling,
          nextOrder: nextOrder,
          canDelete: (feelings?.length ?? 0) > 1,
        ),
      ),
    );

    return Scaffold(
      backgroundColor: AppColors.offWhite,
      appBar: AppBar(
        title: const Text('Feelings'),
        backgroundColor: AppColors.offWhite,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            tooltip: 'New feeling',
            onPressed: feelings == null ? null : open,
          ),
        ],
      ),
      body: feelings == null
          ? const Center(child: CircularProgressIndicator())
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: feelings.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, i) {
                final f = feelings[i];
                return InfoCard(
                  icon: f.icon,
                  iconColor: f.color,
                  iconBackground: f.circleColor,
                  title: f.title,
                  subtitle:
                      '${f.subtitle} • ${(f.totalVibrationMs / 1000).toStringAsFixed(1)}s',
                  onTap: () => open(f),
                );
              },
            ),
    );
  }
}
