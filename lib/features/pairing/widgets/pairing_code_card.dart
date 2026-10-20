import 'package:a_little_tap/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class PairingCodeCard extends StatelessWidget {
  final String code;
  const PairingCodeCard({super.key, required this.code});

  String get _pretty => '${code.substring(0, 4)}-${code.substring(4)}';

  Future<void> _copy(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: _pretty));

    if (!context.mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(content: Text('Code copied')));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 8, 14),
      decoration: BoxDecoration(
        color: AppColors.softPink,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              _pretty,
              style: GoogleFonts.poppins(
                fontSize: 26,
                fontWeight: FontWeight.w700,
                letterSpacing: 3,
                color: AppColors.text,
              ),
            ),
          ),
          IconButton(
            onPressed: () => _copy(context),
            tooltip: 'Copy code',
            color: AppColors.primary,
            icon: const Icon(Icons.copy_rounded),
          ),
        ],
      ),
    );
  }
}
