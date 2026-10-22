import 'package:a_little_tap/core/theme/app_colors.dart';
import 'package:a_little_tap/features/auth/providers/auth_provider.dart';
import 'package:a_little_tap/features/auth/providers/user_provider.dart';
import 'package:a_little_tap/features/couple/providers/couple_provider.dart';
import 'package:a_little_tap/features/feelings/models/feeling.dart';
import 'package:a_little_tap/features/home/screens/home_screen.dart';
import 'package:a_little_tap/features/home/screens/received_screen.dart';
import 'package:a_little_tap/features/moments/models/moment.dart';
import 'package:a_little_tap/features/moments/providers/moment_provider.dart';
import 'package:a_little_tap/features/moments/screens/moments_screen.dart';
import 'package:a_little_tap/features/keepsakes/screens/keepsakes_screen.dart';
import 'package:a_little_tap/features/notifications/providers/push_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MainLayout extends ConsumerStatefulWidget {
  const MainLayout({super.key});

  @override
  ConsumerState<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends ConsumerState<MainLayout> {
  int _index = 0;
  final _openedAt = DateTime.now();
  ValueNotifier<Feeling>? _received; // set while ReceivedScreen is open

  static const _barRadius = BorderRadius.vertical(top: Radius.circular(24));

  @override
  void initState() {
    super.initState();

    final uid = ref.read(authServiceProvider).currentUser?.uid;

    if (uid != null) {
      ref.read(pushServiceProvider).init(uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<Moment?>(lastReceivedProvider, (prev, next) async {
      if (next == null) return; // No tap yet
      if (next.id == prev?.id) return; // Same tap as before
      // The tap is older than when the app opened
      if (next.createdAt.isBefore(_openedAt)) return;

      // Screen already open: swap in the new tap
      if (_received != null) {
        _received?.value = next.feeling;
        return;
      }

      final uid = ref.read(authStateProvider).value?.uid;

      if (uid == null) return;

      final vibrationEnabled = ref
          .read(userProvider(uid))
          .value
          ?.vibrationEnabled;

      final partnerName = ref.read(partnerProvider)?.displayName ?? '';

      _received = ValueNotifier(next.feeling);

      await ReceivedScreen.show(
        context,
        partnerName: partnerName,
        feeling: _received!,
        vibrate: vibrationEnabled ?? true,
      );

      // The screen has closed and stopped listening
      _received!.dispose();
      _received = null;
    });

    return Scaffold(
      backgroundColor: AppColors.surface,
      // keeps every screen alive, so the heart doesn't restart on tab switch
      body: IndexedStack(
        index: _index,
        children: const [HomeScreen(), MomentsScreen(), KeepsakesScreen()],
      ),
      extendBody: true,
      bottomNavigationBar: Container(
        foregroundDecoration: BoxDecoration(
          border: Border.all(color: AppColors.divider),
          borderRadius: _barRadius,
        ),
        child: ClipRRect(
          borderRadius: _barRadius,
          child: NavigationBar(
            selectedIndex: _index,
            onDestinationSelected: (i) => setState(() {
              _index = i;
            }),
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.favorite_outline_rounded),
                selectedIcon: Icon(Icons.favorite_rounded),
                label: 'Home',
              ),
              NavigationDestination(
                icon: Icon(Icons.auto_awesome_outlined),
                selectedIcon: Icon(Icons.auto_awesome),
                label: 'Moments',
              ),
              NavigationDestination(
                icon: Icon(Icons.inventory_2_outlined),
                selectedIcon: Icon(Icons.inventory_2_rounded),
                label: 'Keepsakes',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
