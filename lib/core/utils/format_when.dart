import 'package:flutter/material.dart';

// Today → "3:24 PM", yesterday → "Yesterday", older → "Apr 20"
String formatWhen(BuildContext context, DateTime at) {
  final l10n = MaterialLocalizations.of(context);
  final today = DateUtils.dateOnly(DateTime.now());
  final day = DateUtils.dateOnly(at);

  if (day == today) return l10n.formatTimeOfDay(TimeOfDay.fromDateTime(at));
  if (day == today.subtract(const Duration(days: 1))) return 'Yesterday';
  return l10n.formatShortMonthDay(at);
}
