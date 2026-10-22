import 'package:a_little_tap/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// Asks for a title for an event on the given day; returns it, or null if dismissed
class AddEventSheet extends StatefulWidget {
  final DateTime day;
  const AddEventSheet({super.key, required this.day});

  static Future<String?> show(BuildContext context, DateTime day) {
    return showModalBottomSheet<String>(
      context: context,
      // Lets the sheet rise above the keyboard
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => AddEventSheet(day: day),
    );
  }

  @override
  State<AddEventSheet> createState() => _AddEventSheetState();
}

class _AddEventSheetState extends State<AddEventSheet> {
  final _title = TextEditingController();

  @override
  void dispose() {
    _title.dispose();
    super.dispose();
  }

  void _save() {
    final title = _title.text.trim();
    if (title.isNotEmpty) Navigator.pop(context, title);
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return SafeArea(
      child: Padding(
        // Keyboard height at the bottom so the field stays visible
        padding: EdgeInsets.fromLTRB(
          24,
          0,
          24,
          16 + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              DateFormat('EEE, MMM d').format(widget.day),
              textAlign: TextAlign.center,
              style: text.titleMedium?.copyWith(color: AppColors.text),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _title,
              autofocus: true,
              textCapitalization: TextCapitalization.sentences,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _save(),
              decoration: const InputDecoration(hintText: 'Movie night'),
            ),
            const SizedBox(height: 16),
            // Disabled until there's a title
            ValueListenableBuilder(
              valueListenable: _title,
              builder: (_, value, _) => FilledButton(
                onPressed: value.text.trim().isEmpty ? null : _save,
                child: const Text('Save'),
              ),
            ),
            const SizedBox(height: 4),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ],
        ),
      ),
    );
  }
}
