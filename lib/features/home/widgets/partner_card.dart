import 'package:a_little_tap/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PartnerCard extends StatelessWidget {
  final String name;
  final bool isOnline;
  final DateTime? lastSeen;
  final VoidCallback? onTap;

  const PartnerCard({
    super.key,
    required this.name,
    required this.isOnline,
    this.lastSeen,
    this.onTap,
  });

  String get _status {
    if (isOnline) return 'Online';
    if (lastSeen == null) return 'Offline';

    final diff = DateTime.now().difference(lastSeen!);

    if (diff.inMinutes < 1) return 'Last seen just now';
    if (diff.inHours < 1) return 'Last seen ${diff.inMinutes}m ago';
    if (diff.inDays < 1) return 'Last seen ${diff.inHours}h ago';

    return 'Last seen ${diff.inDays}d ago';
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return Material(
      color: Colors.transparent, // shows whatever is behind it
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias, // keeps the ripple inside the corners
      child: InkWell(
        onTap: onTap,
        child: Padding(
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
                    Text(
                      _status,
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
        ),
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
