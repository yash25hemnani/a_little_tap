import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class InviteCodeField extends StatelessWidget {
  final TextEditingController controller;
  final String? errorText;
  final VoidCallback? onSubmitted;

  const InviteCodeField({
    super.key,
    required this.controller,
    this.errorText,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      textAlign: TextAlign.center,
      textCapitalization: TextCapitalization.characters,
      autocorrect: false,
      enableSuggestions: false,
      textInputAction: TextInputAction.done,
      onSubmitted: (_) => onSubmitted?.call(),
      inputFormatters: [InviteCodeFormatter()],
      style: GoogleFonts.poppins(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        letterSpacing: 4,
      ),
      decoration: InputDecoration(hintText: 'XXXX-XXXX', errorText: errorText),
    );
  }
}

class InviteCodeFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var raw = newValue.text.toUpperCase().replaceAll(RegExp(r'[^A-Z0-9]'), '');
    if (raw.length > 8) raw = raw.substring(0, 8);

    final text = raw.length > 4
        ? '${raw.substring(0, 4)}-${raw.substring(4)}'
        : raw;

    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}
