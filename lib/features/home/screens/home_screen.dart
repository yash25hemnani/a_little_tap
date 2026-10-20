import 'package:a_little_tap/core/constants/feelings.dart';
import 'package:a_little_tap/core/theme/app_colors.dart';
import 'package:a_little_tap/features/home/screens/sending_screen.dart';
import 'package:a_little_tap/features/home/widgets/info_card.dart';
import 'package:a_little_tap/features/home/widgets/partner_card.dart';
import 'package:a_little_tap/features/home/widgets/picker_sheet.dart';
import 'package:a_little_tap/features/home/widgets/pulsing_icon.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Feeling _feeling = feelings[0];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.offWhite,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Column(
            children: [
              // extra 8 keeps the header at 24 from the edge; only the cards widen
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: PartnerCard(
                        name: 'Varsha',
                        isOnline: false,
                        lastSeen: DateTime.now().subtract(
                          const Duration(minutes: 2),
                        ),
                        onTap: () {},
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.settings_outlined),
                      color: AppColors.textSecondary,
                      tooltip: 'Settings',
                      onPressed: () {},
                    ),
                  ],
                ),
              ),

              Expanded(
                child: Center(
                  child: PulsingIcon(
                    icon: _feeling.icon,
                    iconColor: _feeling.color,
                    backgroundColor: _feeling.circleColor,
                    ringColor: _feeling.ringColor,
                    // Plain tap sends the last picked feeling
                    onTap: () => SendingScreen.show(
                      context,
                      partnerName: 'Varsha',
                      feeling: _feeling,
                    ),
                    onLongPress: () async {
                      final feeling = await PickerSheet.show(context);
                      if (feeling == null || !context.mounted) {
                        return; // sheet dismissed
                      }
                      setState(() {
                        _feeling = feeling;
                      });
                      SendingScreen.show(
                        context,
                        partnerName: 'Varsha',
                        feeling: feeling,
                      );
                    },
                  ),
                ),
              ),

              // Feeling name and hint read as one label under the icon
              Text(
                '${_feeling.title}',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: _feeling.color,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),

              Text(
                'Tap to send a little something',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 28),

              InfoCard(
                icon: Icons.favorite_rounded,
                title: 'Last tap from Varsha',
                subtitle: 'Thinking of you • 3:24 PM',
                onTap: () {},
              ),
              const SizedBox(height: 12),
              InfoCard(
                icon: Icons.event_rounded,
                iconColor: AppColors.lavender,
                iconBackground: AppColors.lavenderSoft,
                title: 'Movie night',
                subtitle: 'Sat, Oct 25 • in 5 days',
                onTap: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }
}
