import 'package:a_little_tap/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// Year arrows over a 3×4 month grid; returns the first of the picked month, or null if dismissed
class MonthPickerSheet extends StatefulWidget {
  final DateTime initial;
  const MonthPickerSheet({super.key, required this.initial});

  static Future<DateTime?> show(BuildContext context, DateTime initial) {
    return showModalBottomSheet<DateTime>(
      context: context,
      backgroundColor: AppColors.surface,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => MonthPickerSheet(initial: initial),
    );
  }

  @override
  State<MonthPickerSheet> createState() => _MonthPickerSheetState();
}

class _MonthPickerSheetState extends State<MonthPickerSheet> {
  // Same range as the calendar's firstDay / lastDay
  static const _minYear = 1980;
  static const _maxYear = 2035;

  late int _year = widget.initial.year;
  // True while the year grid shows in place of the months
  bool _pickingYear = false;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // A null onPressed greys the arrow out at the ends of the range
                IconButton(
                  icon: const Icon(Icons.chevron_left_rounded),
                  color: AppColors.textSecondary,
                  onPressed: _year == _minYear
                      ? null
                      : () => setState(() => _year--),
                ),
                // Tapping the year opens the year grid, tapping again closes it
                TextButton(
                  onPressed: () => setState(() => _pickingYear = !_pickingYear),
                  child: Text(
                    '$_year',
                    style: text.titleMedium?.copyWith(
                      color: AppColors.text,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right_rounded),
                  color: AppColors.textSecondary,
                  onPressed: _year == _maxYear
                      ? null
                      : () => setState(() => _year++),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (_pickingYear)
              SizedBox(
                // Fixed height, since YearPicker scrolls
                height: 240,
                // YearPicker draws a divider on top; this hides it
                child: Theme(
                  data: Theme.of(context).copyWith(
                    dividerTheme: const DividerThemeData(
                      color: Colors.transparent,
                    ),
                  ),
                  child: YearPicker(
                    firstDate: DateTime(_minYear),
                    lastDate: DateTime(_maxYear),
                    selectedDate: DateTime(_year),
                    onChanged: (d) => setState(() {
                      _year = d.year;
                      _pickingYear = false;
                    }),
                  ),
                ),
              )
            else
              // 12 months, 3 per row
              GridView.count(
                crossAxisCount: 3,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                childAspectRatio: 2.2,
                children: [for (var m = 1; m <= 12; m++) _month(m)],
              ),
          ],
        ),
      ),
    );
  }

  Widget _month(int m) {
    final selected = _year == widget.initial.year && m == widget.initial.month;

    return Material(
      color: selected ? AppColors.heart : AppColors.offWhite,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => Navigator.pop(context, DateTime.utc(_year, m, 1)),
        child: Center(
          child: Text(
            DateFormat.MMM().format(DateTime(_year, m)),
            style: TextStyle(
              color: selected ? AppColors.onPrimary : AppColors.text,
              fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}
