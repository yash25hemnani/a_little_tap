import 'package:a_little_tap/core/theme/app_colors.dart';
import 'package:a_little_tap/features/feelings/constants/vibration_limits.dart';
import 'package:a_little_tap/features/feelings/models/vibration_step.dart';
import 'package:a_little_tap/features/feelings/utils/play_vibration.dart';
import 'package:flutter/material.dart';
import 'package:vibration/vibration.dart';

class WaveformEditor extends StatefulWidget {
  final List<VibrationStep> steps;
  final Color color;
  final ValueChanged<List<VibrationStep>> onChanged;

  const WaveformEditor({
    super.key,
    required this.steps,
    required this.color,
    required this.onChanged,
  });

  @override
  State<WaveformEditor> createState() => _WaveformEditorState();
}

class _WaveformEditorState extends State<WaveformEditor>
    with SingleTickerProviderStateMixin {
  late List<VibrationStep> _steps = [...widget.steps];
  int? _selected;
  bool _hasAmp = true;
  // 0 to 1 across the pattern while it plays
  late final _playhead = AnimationController(vsync: this);

  int get _totalMs => _steps.fold(0, (sum, s) => sum + s.ms);

  bool get canAdd =>
      _steps.length < maxVibrationSteps &&
      _totalMs + minStepMs <= maxVibrationMs;

  // Longest step i can be without going over 2000 ms total
  int _maxMsFor(int i) => maxVibrationMs - (_totalMs - _steps[i].ms);

  @override
  void initState() {
    super.initState();
    _checkAmplitudeControl();
  }

  @override
  void dispose() {
    _playhead.dispose();
    super.dispose();
  }

  void _play() {
    _playhead.duration = Duration(milliseconds: _totalMs);
    _playhead.forward(from: 0);
    playVibration(_steps);
  }

  // Lets the user feel the buzz they just adjusted
  void _playSelected() {
    final step = _steps[_selected!];
    if (!step.isPause) playVibration([step]);
  }

  void _update(List<VibrationStep> next, {int? select}) {
    setState(() {
      _steps = next;
      _selected = select ?? _selected;
    });

    widget.onChanged([...next]);
  }

  void _add({required bool pause}) {
    if (!canAdd) return;

    final remaining = maxVibrationMs - _totalMs;
    final ms = (pause ? 100 : 150).clamp(minStepMs, remaining);
    final amp = pause ? 0 : (_hasAmp ? 180 : maxAmp);
    // Right after the selected step, or at the end when nothing is selected
    final index = _selected == null ? _steps.length : _selected! + 1;

    _update(
      [..._steps]..insert(index, VibrationStep(ms: ms, amp: amp)),
      select: index,
    );
  }

  void _setMs(double v) {
    final i = _selected!;
    final ms = ((v / 10).round() * 10).clamp(minStepMs, _maxMsFor(i));

    _update([..._steps]..[i] = VibrationStep(ms: ms, amp: _steps[i].amp));
  }

  void _setAmp(double v) {
    final i = _selected!;
    final amp = v.round().clamp(1, maxAmp);

    _update([..._steps]..[i] = VibrationStep(ms: _steps[i].ms, amp: amp));
  }

  void _deleteSelected() {
    final i = _selected;
    if (i == null || _steps.length == 1) return;

    setState(() {
      _selected = null;
    });

    _update([..._steps]..removeAt(i));
  }

  // Turns a tap position into a step index, null if past the last step
  void _selectAt(double dx, double width) {
    final tappedMs = dx / width * maxVibrationMs;

    var end = 0;
    for (var i = 0; i < _steps.length; i++) {
      end += _steps[i].ms;
      if (tappedMs < end) {
        setState(() => _selected = i);
        return;
      }
    }

    setState(() => _selected = null);
  }

  Future<void> _checkAmplitudeControl() async {
    final hasAmp = await Vibration.hasAmplitudeControl();

    if (!mounted) return;

    setState(() {
      _hasAmp = hasAmp;
    });
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final selected = _selected == null ? null : _steps[_selected!];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.border),
          ),
          child: LayoutBuilder(
            builder: (context, box) => GestureDetector(
              onTapDown: (d) => _selectAt(d.localPosition.dx, box.maxWidth),
              child: CustomPaint(
                size: Size(box.maxWidth, 124),
                painter: _WaveformPainter(
                  steps: _steps,
                  selected: _selected,
                  color: widget.color,
                  hasAmp: _hasAmp,
                  playhead: _playhead,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Text(
              '${(_totalMs / 1000).toStringAsFixed(2)}s / 2.00s'
              '${canAdd ? '' : ' · full'}',
              style: text.bodySmall?.copyWith(color: AppColors.textSecondary),
            ),
            const Spacer(),
            TextButton.icon(
              onPressed: _play,
              icon: const Icon(Icons.play_arrow_rounded),
              label: const Text('Play'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (selected == null)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              'Tap a bar to edit it',
              textAlign: TextAlign.center,
              style: text.bodySmall?.copyWith(color: AppColors.textSecondary),
            ),
          )
        else ...[
          _SliderRow(
            label: selected.isPause ? 'Pause' : 'Length',
            value: '${(selected.ms / 1000).toStringAsFixed(2)}s',
            slider: Slider(
              min: minStepMs.toDouble(),
              max: _maxMsFor(_selected!).toDouble(),
              value: selected.ms.toDouble(),
              activeColor: widget.color,
              onChanged: _setMs,
              onChangeEnd: (_) => _playSelected(),
            ),
          ),
          if (_hasAmp && !selected.isPause)
            _SliderRow(
              label: 'Strength',
              value: '${(selected.amp / maxAmp * 100).round()}%',
              slider: Slider(
                min: 1,
                max: maxAmp.toDouble(),
                value: selected.amp.toDouble(),
                activeColor: widget.color,
                onChanged: _setAmp,
                onChangeEnd: (_) => _playSelected(),
              ),
            ),
        ],
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: canAdd ? () => _add(pause: false) : null,
                icon: const Icon(Icons.add_rounded),
                label: const Text('Buzz'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: canAdd ? () => _add(pause: true) : null,
                icon: const Icon(Icons.add_rounded),
                label: const Text('Pause'),
              ),
            ),
            const SizedBox(width: 8),
            IconButton.outlined(
              onPressed: selected == null || _steps.length == 1
                  ? null
                  : _deleteSelected,
              icon: const Icon(Icons.delete_outline_rounded),
              tooltip: 'Delete step',
              color: AppColors.primary,
            ),
          ],
        ),
      ],
    );
  }
}

class _WaveformPainter extends CustomPainter {
  final List<VibrationStep> steps;
  final int? selected;
  final Color color;
  final bool hasAmp;
  final Animation<double> playhead;

  // Repaints on every playhead tick without rebuilding the editor
  _WaveformPainter({
    required this.steps,
    required this.selected,
    required this.color,
    required this.hasAmp,
    required this.playhead,
  }) : super(repaint: playhead);

  @override
  void paint(Canvas canvas, Size size) {
    // Bottom strip holds the time labels, bars use the rest
    final barsHeight = size.height - 16;

    final guide = Paint()
      ..color = AppColors.divider
      ..strokeWidth = 1;

    // Label every 0.5s from 0 to 2s, faint lines between the ends, plus a baseline
    for (var ms = 0; ms <= maxVibrationMs; ms += 500) {
      final gx = size.width * ms / maxVibrationMs;
      if (ms > 0 && ms < maxVibrationMs) {
        canvas.drawLine(Offset(gx, 0), Offset(gx, barsHeight), guide);
      }

      final label = TextPainter(
        text: TextSpan(
          text: '${(ms / 1000).toStringAsFixed(1)}s',
          style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      // Centred under the line, kept inside the box at the ends
      final lx = (gx - label.width / 2).clamp(0.0, size.width - label.width);
      label.paint(canvas, Offset(lx, barsHeight + 3));
    }
    canvas.drawLine(
      Offset(0, barsHeight),
      Offset(size.width, barsHeight),
      guide,
    );

    var x = 0.0;

    for (var i = 0; i < steps.length; i++) {
      final s = steps[i];

      // Fixed scale, so empty space on the right is unused time
      final w = size.width * s.ms / maxVibrationMs;

      final double h;
      if (s.isPause) {
        h = 4;
      } else {
        h = !hasAmp ? barsHeight : barsHeight * s.amp / maxAmp;
      }

      final paint = Paint()
        ..color = i == selected
            ? color
            : (s.isPause ? AppColors.border : color.withValues(alpha: 0.45));

      // Buzzes rounded on top only, so they sit flat on the baseline; pauses square
      final radius = Radius.circular(s.isPause ? 0 : 4);
      final rrect = RRect.fromRectAndCorners(
        Rect.fromLTWH(x + 1, barsHeight - h, w - 2, h),
        topLeft: radius,
        topRight: radius,
      );

      canvas.drawRRect(rrect, paint);
      x += w;
    }

    // x is now the end of the pattern
    if (playhead.isAnimating) {
      final px = x * playhead.value;
      canvas.drawLine(
        Offset(px, 0),
        Offset(px, barsHeight),
        Paint()
          ..color = AppColors.text
          ..strokeWidth = 2,
      );
    }
  }

  @override
  bool shouldRepaint(_WaveformPainter old) {
    return true;
  }
}

// Label, slider and value on one line
class _SliderRow extends StatelessWidget {
  final String label;
  final String value;
  final Widget slider;

  const _SliderRow({
    required this.label,
    required this.value,
    required this.slider,
  });

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return Row(
      children: [
        SizedBox(width: 72, child: Text(label, style: text.bodyMedium)),
        Expanded(child: slider),
        SizedBox(
          width: 56,
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: text.bodySmall?.copyWith(color: AppColors.textSecondary),
          ),
        ),
      ],
    );
  }
}
