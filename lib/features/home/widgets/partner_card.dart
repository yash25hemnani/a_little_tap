import 'package:a_little_tap/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PartnerCard extends StatelessWidget {
  final String name;
  final bool isOnline;
  final DateTime? lastSeen;
  // Shown when there's no online or last seen status
  final String? subtitle;

  const PartnerCard({
    super.key,
    required this.name,
    required this.isOnline,
    this.lastSeen,
    this.subtitle,
  });

  // Null hides the status line
  String? get _status {
    if (isOnline) return 'Online';
    if (lastSeen == null) return subtitle;

    final diff = DateTime.now().difference(lastSeen!);

    if (diff.inMinutes < 1) return 'Last seen just now';
    if (diff.inHours < 1) return 'Last seen ${diff.inMinutes}m ago';
    if (diff.inDays < 1) return 'Last seen ${diff.inHours}h ago';

    return 'Last seen ${diff.inDays}d ago';
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final status = _status;

    return Padding(
      // no side padding so the avatar lines up with the page edge
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          _Avatar(name: name, isOnline: isOnline),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    textStyle: text.titleMedium,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (status != null)
                  Text(
                    status,
                    style: GoogleFonts.poppins(
                      textStyle: text.bodySmall,
                      color: isOnline
                          ? AppColors.online
                          : AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Initial in a pink circle with a green presence dot in the corner.
class _Avatar extends StatelessWidget {
  final String name;
  final bool isOnline;

  const _Avatar({required this.name, required this.isOnline});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        CircleAvatar(
          radius: 24,
          backgroundColor: AppColors.softPink,
          child: Text(
            name.isEmpty ? '?' : name[0].toUpperCase(),
            style: GoogleFonts.poppins(
              fontSize: 18,
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),

        if (isOnline)
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                color: AppColors.online,
                shape: BoxShape.circle,
                // ring in the card colour so the dot stands out against the avatar
                border: Border.all(color: AppColors.offWhite, width: 2),
              ),
            ),
          ),
      ],
    );
  }
}
