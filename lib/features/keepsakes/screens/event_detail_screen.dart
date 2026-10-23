import 'package:a_little_tap/core/theme/app_colors.dart';
import 'package:a_little_tap/core/utils/format_event_day.dart';
import 'package:a_little_tap/features/auth/providers/auth_provider.dart';
import 'package:a_little_tap/features/auth/providers/user_provider.dart';
import 'package:a_little_tap/features/couple/providers/couple_provider.dart';
import 'package:a_little_tap/features/keepsakes/models/keepsake_event.dart';
import 'package:a_little_tap/features/keepsakes/providers/event_provider.dart';
import 'package:a_little_tap/features/keepsakes/widgets/add_event_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

// One calendar event with its details, and Delete at the bottom
class EventDetailScreen extends ConsumerWidget {
  final KeepsakeEvent event;
  // The UTC day it was opened for; sets the year count on yearly events
  final DateTime day;

  const EventDetailScreen({super.key, required this.event, required this.day});

  static Future<void> show(
    BuildContext context,
    KeepsakeEvent event,
    DateTime day,
  ) {
    return Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => EventDetailScreen(event: event, day: day),
      ),
    );
  }

  // Opens the add sheet filled in; saving updates the event for both partners
  Future<void> _edit(
    BuildContext context,
    WidgetRef ref,
    KeepsakeEvent current,
  ) async {
    final picked = await AddEventSheet.show(
      context,
      current.date,
      initial: current,
    );
    if (picked == null || !context.mounted) return;

    final uid = ref.read(authStateProvider).value?.uid;
    if (uid == null) return;

    final coupleId = ref.read(userProvider(uid)).value?.coupleId;
    if (coupleId == null) return;

    // Read now, in case the screen closes before the save finishes
    final messenger = ScaffoldMessenger.of(context);

    // Finishes once the server has the change
    try {
      await ref
          .read(eventRepositoryProvider)
          .update(
            coupleId: coupleId,
            eventId: current.id,
            title: picked.title,
            date: picked.date,
            type: picked.type,
            yearly: picked.yearly,
          );

      messenger.showSnackBar(const SnackBar(content: Text('Event updated')));
    } catch (e) {
      debugPrint('event: update failed $e');
      messenger.showSnackBar(
        const SnackBar(content: Text("Couldn't save changes")),
      );
    }
  }

  // Asks first, then removes the event for both partners and closes the screen
  Future<void> _delete(
    BuildContext context,
    WidgetRef ref,
    KeepsakeEvent current,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        title: const Text('Delete date?'),
        content: Text(
          current.yearly
              ? '"${current.title}" will be removed from every year.'
              : '"${current.title}" will be removed.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.primary),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    // Dismissing the dialog returns null
    if (confirmed != true) return;

    final uid = ref.read(authStateProvider).value?.uid;
    if (uid == null) return;

    final coupleId = ref.read(userProvider(uid)).value?.coupleId;
    if (coupleId == null) return;

    ref.read(eventRepositoryProvider).delete(coupleId, current.id);

    if (context.mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = Theme.of(context).textTheme;

    final uid = ref.watch(authStateProvider).value?.uid;
    final partnerName = ref.watch(partnerProvider)?.displayName ?? 'partner';

    // The live copy, so edits from either phone show straight away
    final event =
        ref
            .watch(eventsProvider)
            .value
            ?.where((e) => e.id == this.event.id)
            .firstOrNull ??
        this.event;

    final now = DateTime.now();
    final today = DateTime.utc(now.year, now.month, now.day);
    final next = event.nextOn(today);

    // If an edit moved the event off the day it was opened for, count years from its next day
    final shownDay = event.isOn(day) ? day : (next ?? event.date);
    final years = event.yearly ? event.yearsOn(shownDay) : 0;

    return Scaffold(
      backgroundColor: AppColors.offWhite,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        foregroundColor: AppColors.text,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Column(
            children: [
              CircleAvatar(
                radius: 44,
                backgroundColor: AppColors.lavenderSoft,
                child: Icon(event.type.icon, size: 40, color: AppColors.lavender),
              ),
              const SizedBox(height: 16),
              Text(
                event.type.label,
                style: text.bodyMedium?.copyWith(
                  color: AppColors.lavender,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                event.title,
                textAlign: TextAlign.center,
                style: text.headlineSmall?.copyWith(
                  color: AppColors.text,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 24),
              // Details in a white card
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  children: [
                    _row(
                      context,
                      Icons.calendar_today_rounded,
                      DateFormat('EEEE, d MMMM yyyy').format(event.date),
                    ),
                    if (event.yearly)
                      _row(
                        context,
                        Icons.repeat_rounded,
                        years > 0
                            ? 'Every year • ${years == 1 ? '1 year' : '$years years'}'
                            : 'Every year',
                      ),
                    if (next != null)
                      _row(
                        context,
                        Icons.schedule_rounded,
                        'Next: ${formatEventDay(next)}',
                      ),
                    _row(
                      context,
                      Icons.person_outline_rounded,
                      event.createdBy == uid
                          ? 'Added by you'
                          : 'Added by $partnerName',
                    ),
                  ],
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () => _edit(context, ref, event),
                  icon: const Icon(Icons.edit_outlined),
                  label: const Text('Edit'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _delete(context, ref, event),
                  icon: const Icon(Icons.delete_outline_rounded),
                  label: const Text('Delete'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primaryLight),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _row(BuildContext context, IconData icon, String label) {
    return ListTile(
      leading: Icon(icon, color: AppColors.lavender),
      title: Text(
        label,
        style: Theme.of(
          context,
        ).textTheme.bodyMedium?.copyWith(color: AppColors.text),
      ),
    );
  }
}
