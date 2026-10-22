import 'package:a_little_tap/core/theme/app_colors.dart';
import 'package:a_little_tap/features/auth/providers/auth_provider.dart';
import 'package:a_little_tap/features/feelings/constants/feelings.dart';
import 'package:a_little_tap/features/feelings/models/feeling.dart';
import 'package:a_little_tap/features/feelings/models/vibration_step.dart';
import 'package:a_little_tap/features/feelings/provider/feeling_provider.dart';
import 'package:a_little_tap/features/feelings/widgets/waveform_editor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EditFeelingScreen extends ConsumerStatefulWidget {
  final Feeling? feeling; // null = new
  final int nextOrder;
  final bool canDelete;

  const EditFeelingScreen({
    super.key,
    this.feeling,
    required this.nextOrder,
    this.canDelete = false,
  });

  @override
  ConsumerState<EditFeelingScreen> createState() => _EditFeelingScreenState();
}

class _EditFeelingScreenState extends ConsumerState<EditFeelingScreen> {
  late final _title = TextEditingController(text: widget.feeling?.title);
  late final _subtitle = TextEditingController(text: widget.feeling?.subtitle);
  late String _iconKey = widget.feeling?.iconKey ?? 'heart';
  late int _color =
      widget.feeling?.colorValue ?? feelingColors.first.toARGB32();
  late List<VibrationStep> _steps =
      widget.feeling?.vibration ?? defaultVibration;

  @override
  void dispose() {
    _title.dispose();
    _subtitle.dispose();
    super.dispose();
  }

  void _save() {
    final uid = ref.read(authStateProvider).value?.uid;

    if (uid == null) return;

    final feeling = Feeling(
      id: widget.feeling?.id ?? '',
      title: _title.text.trim(),
      subtitle: _subtitle.text.trim(),
      iconKey: _iconKey,
      colorValue: _color,
      order: widget.feeling?.order ?? widget.nextOrder,
      vibration: _steps,
    );

    widget.feeling == null
        ? ref.read(feelingRepositoryProvider).addFeeling(uid, feeling)
        : ref.read(feelingRepositoryProvider).updateFeeling(uid, feeling);

    Navigator.of(context).pop();
  }

  Future<void> _delete() async {
    final uid = ref.read(authStateProvider).value?.uid;
    final id = widget.feeling?.id;

    if (uid == null || id == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete feeling?'),
        content: Text('"${widget.feeling!.title}" will be removed.'),
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

    // Dismissing the dialog returns null, the screen may be gone after the await
    if (confirmed != true || !mounted) return;

    ref.read(feelingRepositoryProvider).deleteFeeling(uid, id);

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final color = Color(_color);
    final circleColor = Color.lerp(color, Colors.white, 0.88)!;
    final isNew = widget.feeling == null;

    return Scaffold(
      backgroundColor: AppColors.offWhite,
      appBar: AppBar(
        title: Text(isNew ? 'New feeling' : 'Edit feeling'),
        backgroundColor: AppColors.offWhite,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Preview of the chosen icon and colour
          Center(
            child: CircleAvatar(
              radius: 40,
              backgroundColor: circleColor,
              child: Icon(
                feelingIcons[_iconKey] ?? Icons.favorite_rounded,
                size: 40,
                color: color,
              ),
            ),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _title,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(labelText: 'Title'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _subtitle,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(labelText: 'Message'),
          ),
          const SizedBox(height: 24),
          _Label('Icon', text),
          Wrap(
            spacing: 6,
            runSpacing: 8,
            children: [
              for (final entry in feelingIcons.entries)
                _IconChoice(
                  icon: entry.value,
                  color: color,
                  background: circleColor,
                  selected: entry.key == _iconKey,
                  onTap: () => setState(() => _iconKey = entry.key),
                ),
            ],
          ),
          const SizedBox(height: 24),
          _Label('Colour', text),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final c in feelingColors)
                _ColorChoice(
                  color: c,
                  selected: c.toARGB32() == _color,
                  onTap: () => setState(() => _color = c.toARGB32()),
                ),
            ],
          ),
          const SizedBox(height: 24),
          _Label('Vibration', text),
          // Only stores the steps, the editor redraws itself
          WaveformEditor(
            steps: _steps,
            color: color,
            onChanged: (s) => _steps = s,
          ),
          const SizedBox(height: 32),
          ListenableBuilder(
            listenable: _title,
            builder: (context, _) => FilledButton(
              onPressed: _title.text.trim().isEmpty ? null : _save,
              child: const Text('Save'),
            ),
          ),
          if (!isNew && widget.canDelete) ...[
            const SizedBox(height: 8),
            TextButton(
              onPressed: _delete,
              style: TextButton.styleFrom(foregroundColor: AppColors.primary),
              child: const Text('Delete'),
            ),
          ],
        ],
      ),
    );
  }
}

class _Label extends StatelessWidget {
  final String label;
  final TextTheme text;

  const _Label(this.label, this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        label,
        style: text.bodySmall?.copyWith(
          color: AppColors.textSecondary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// Tinted circle, ringed in the feeling colour when selected
class _IconChoice extends StatelessWidget {
  final IconData icon;
  final Color color;
  final Color background;
  final bool selected;
  final VoidCallback onTap;

  const _IconChoice({
    required this.icon,
    required this.color,
    required this.background,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkResponse(
      onTap: onTap,
      radius: 26,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: selected ? background : AppColors.surface,
          border: Border.all(
            color: selected ? color : AppColors.border,
            width: selected ? 2 : 1,
          ),
        ),
        child: Icon(
          icon,
          size: 24,
          color: selected ? color : AppColors.textSecondary,
        ),
      ),
    );
  }
}

// Solid swatch with a check when selected
class _ColorChoice extends StatelessWidget {
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  const _ColorChoice({
    required this.color,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkResponse(
      onTap: onTap,
      radius: 22,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        child: selected
            ? const Icon(Icons.check_rounded, color: Colors.white, size: 22)
            : null,
      ),
    );
  }
}
