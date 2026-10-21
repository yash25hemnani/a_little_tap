import 'package:a_little_tap/core/theme/app_colors.dart';
import 'package:a_little_tap/features/auth/providers/auth_provider.dart';
import 'package:a_little_tap/features/home/screens/home_screen.dart';
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
