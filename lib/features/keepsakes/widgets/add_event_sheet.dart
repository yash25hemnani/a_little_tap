import 'package:a_little_tap/core/theme/app_colors.dart';
import 'package:a_little_tap/features/keepsakes/models/keepsake_event.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

typedef NewEvent = ({String title, EventType type, bool yearly});

// Asks for a title for an event on the given day; returns it, or null if dismissed
class AddEventSheet extends StatefulWidget {
  final DateTime day;
  const AddEventSheet({super.key, required this.day});

  static Future<NewEvent?> show(BuildContext context, DateTime day) {
    return showModalBottomSheet<NewEvent>(
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
  EventType _type = EventType.date;
  bool _yearly = false; // date isn't yearly by default

  @override
  void dispose() {
    _title.dispose();
    super.dispose();
  }

  void _save() {
    final title = _title.text.trim();
    if (title.isEmpty) return;
    Navigator.pop<NewEvent>(context, (
      title: title,
      type: _type,
      yearly: _yearly,
    ));
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
            DropdownButtonFormField<EventType>(
              initialValue: _type,
              decoration: const InputDecoration(labelText: 'Type'),
              borderRadius: BorderRadius.circular(16),
              dropdownColor: AppColors.surface,
              items: [
                for (final t in EventType.values)
                  DropdownMenuItem(
                    value: t,
                    child: Row(
                      children: [
                        Icon(t.icon, size: 20, color: AppColors.heart),
                        const SizedBox(width: 12),
                        Text(t.label),
                      ],
                    ),
                  ),
              ],
              onChanged: (t) {
                if (t == null) return;
                setState(() {
                  _type = t;
                  _yearly = t.yearlyByDefault;
                });
              },
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Every year'),
              value: _yearly,
              onChanged: (val) => setState(() {
                _yearly = val;
              }),
            ),
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
