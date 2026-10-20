import 'package:flutter/material.dart';

// Shared space for the couple: notes, calendar, images, streaks (coming later)
class KeepsakesScreen extends StatelessWidget {
  const KeepsakesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const SafeArea(child: Center(child: Text('Keepsakes')));
  }
}
