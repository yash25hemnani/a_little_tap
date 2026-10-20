import 'package:a_little_tap/core/theme/app_colors.dart';
import 'package:a_little_tap/features/home/screens/home_screen.dart';
import 'package:a_little_tap/features/moments/screens/moments_screen.dart';
import 'package:a_little_tap/features/keepsakes/screens/keepsakes_screen.dart';
import 'package:flutter/material.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _index = 0;

  static const _barRadius = BorderRadius.vertical(top: Radius.circular(24));

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
