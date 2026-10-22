import 'package:a_little_tap/core/theme/app_colors.dart';
import 'package:a_little_tap/features/auth/providers/auth_provider.dart';
import 'package:a_little_tap/features/auth/providers/user_provider.dart';
import 'package:a_little_tap/features/couple/providers/couple_provider.dart';
import 'package:a_little_tap/features/home/widgets/info_card.dart';
import 'package:a_little_tap/features/keepsakes/models/keepsake_event.dart';
import 'package:a_little_tap/features/keepsakes/providers/event_provider.dart';
import 'package:a_little_tap/features/keepsakes/screens/event_detail_screen.dart';
import 'package:a_little_tap/features/keepsakes/widgets/add_event_sheet.dart';
import 'package:a_little_tap/features/keepsakes/widgets/month_picker_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

// The couple's shared calendar: dots on days with events, and the selected day's list below
class KeepsakesScreen extends ConsumerStatefulWidget {
  const KeepsakesScreen({super.key});

  @override
  ConsumerState<KeepsakesScreen> createState() => _KeepsakesScreenState();
}

class _KeepsakesScreenState extends ConsumerState<KeepsakesScreen> {
  DateTime _focusedDay = DateTime.now();
  // UTC day, the same form events are stored in; null after moving to another month
  DateTime? _selectedDay = _utcDay(DateTime.now());

  static DateTime _utcDay(DateTime d) => DateTime.utc(d.year, d.month, d.day);

  Future<void> _addEvent() async {
    final day = _selectedDay;
    if (day == null) return;

    final picked = await AddEventSheet.show(context, day);
    if (picked == null) return;

    final uid = ref.read(authStateProvider).value?.uid;

    if (uid == null) return;

    final coupleId = ref.read(userProvider(uid)).value?.coupleId;

    if (coupleId == null) return;

    ref
        .read(eventRepositoryProvider)
        .add(
          coupleId: coupleId,
          title: picked.title,
          date: day,
          type: picked.type,
          yearly: picked.yearly,
          createdBy: uid,
        );
  }

  // Jumps the calendar to a month picked from the sheet and clears the selected day
  Future<void> _pickMonth(DateTime month) async {
    final picked = await MonthPickerSheet.show(context, month);
    if (picked == null) return;

    setState(() {
      _focusedDay = picked;
      _selectedDay = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final uid = ref.watch(authStateProvider).value?.uid;
    final partnerName = ref.watch(partnerProvider)?.displayName ?? 'partner';
    final byDay = ref.watch(eventsByDayProvider);
    final selected = _selectedDay;
    final dayEvents = selected == null
        ? const <KeepsakeEvent>[]
        : byDay(selected);

    return Scaffold(
      backgroundColor: AppColors.offWhite,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Row(
                  children: [
                    Text(
                      'Keepsakes',
                      style: text.titleLarge?.copyWith(
                        color: AppColors.text,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.add_rounded),
                      color: AppColors.textSecondary,
                      tooltip: 'Add date',
                      // Disabled until a day is selected
                      onPressed: selected == null ? null : _addEvent,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Calendar in a white card
              Container(
                padding: const EdgeInsets.fromLTRB(8, 8, 8, 12),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.border),
                ),
                child: TableCalendar(
                  firstDay: DateTime.utc(1980, 1, 1),
                  lastDay: DateTime.utc(2035, 12, 31),
                  focusedDay: _focusedDay,
                  selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                  onDaySelected: (selected, focused) {
                    setState(() {
                      _selectedDay = _utcDay(selected);
                      _focusedDay = focused;
                    });
                  },
                  eventLoader: byDay,
                  // Swiping to another month clears the selected day too
                  onPageChanged: (focused) => setState(() {
                    _focusedDay = focused;
                    _selectedDay = null;
                  }),
                  startingDayOfWeek: StartingDayOfWeek.monday,
                  headerStyle: HeaderStyle(
                    formatButtonVisible: false,
                    titleCentered: true,
                    leftChevronIcon: const Icon(
                      Icons.chevron_left_rounded,
                      color: AppColors.textSecondary,
                    ),
                    rightChevronIcon: const Icon(
                      Icons.chevron_right_rounded,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  daysOfWeekStyle: DaysOfWeekStyle(
                    weekdayStyle: text.bodySmall!.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    weekendStyle: text.bodySmall!.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                  calendarStyle: CalendarStyle(
                    outsideDaysVisible: false,
                    defaultTextStyle: const TextStyle(color: AppColors.text),
                    weekendTextStyle: const TextStyle(color: AppColors.text),
                    todayDecoration: const BoxDecoration(
                      color: AppColors.softPink,
                      shape: BoxShape.circle,
                    ),
                    todayTextStyle: const TextStyle(
                      color: AppColors.heart,
                      fontWeight: FontWeight.w600,
                    ),
                    selectedDecoration: const BoxDecoration(
                      color: AppColors.heart,
                      shape: BoxShape.circle,
                    ),
                    selectedTextStyle: const TextStyle(
                      color: AppColors.onPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                    // One dot per day, however many events it has
                    markersMaxCount: 1,
                    markerSize: 5,
                    // Raises the dot from the circle's edge to just under the number
                    markersAnchor: 2,
                  ),
                  calendarBuilders: CalendarBuilders(
                    // Tappable month title with a ▾ that opens the month picker
                    headerTitleBuilder: (context, month) => Center(
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () => _pickMonth(month),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                DateFormat('MMMM yyyy').format(month),
                                style: text.titleMedium!.copyWith(
                                  color: AppColors.text,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const Icon(
                                Icons.arrow_drop_down_rounded,
                                color: AppColors.textSecondary,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // White on the selected day's pink circle, pink everywhere else
                    singleMarkerBuilder: (context, day, event) => Container(
                      width: 5,
                      height: 5,
                      margin: const EdgeInsets.symmetric(horizontal: 0.3),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isSameDay(day, _selectedDay)
                            ? AppColors.onPrimary
                            : AppColors.heart,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Selected day's events
              Expanded(
                child: dayEvents.isEmpty
                    ? Center(
                        child: Text(
                          selected == null
                              ? 'Select a date to see events'
                              : 'Nothing planned',
                          style: text.bodyMedium?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.only(bottom: 16),
                        itemCount: dayEvents.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 12),
                        itemBuilder: (_, i) {
                          final e = dayEvents[i];
                          // Yearly events show which year this is, e.g. "3 years"
                          final years = e.yearly ? e.yearsOn(selected!) : 0;
                          final addedBy = e.createdBy == uid
                              ? 'Added by you'
                              : 'Added by $partnerName';

                          return InfoCard(
                            icon: e.type.icon,
                            iconColor: AppColors.lavender,
                            iconBackground: AppColors.lavenderSoft,
                            title: e.title,
                            subtitle: years > 0
                                ? '${years == 1 ? '1 year' : '$years years'} • $addedBy'
                                : addedBy,
                            onTap: () =>
                                EventDetailScreen.show(context, e, selected!),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
