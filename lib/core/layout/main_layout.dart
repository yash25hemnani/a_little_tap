import 'dart:async';

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
import 'package:a_little_tap/features/keepsakes/providers/event_provider.dart';
import 'package:a_little_tap/features/keepsakes/screens/event_detail_screen.dart';
import 'package:a_little_tap/features/keepsakes/screens/keepsakes_screen.dart';
import 'package:a_little_tap/features/notifications/providers/push_provider.dart';
import 'package:a_little_tap/features/notifications/services/tap_notifier.dart';
import 'package:a_little_tap/features/presence/providers/presence_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
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
  bool _openOnLoad = false; // a notification was tapped before moments loaded
  String? _openEventOnLoad; // a reminder was tapped before events loaded
  StreamSubscription<NotificationResponse>? _openedSub;

  static const _barRadius = BorderRadius.vertical(top: Radius.circular(24));

  @override
  void initState() {
    super.initState();

    final uid = ref.read(authServiceProvider).currentUser?.uid;

    if (uid != null) {
      ref.read(pushServiceProvider).init(uid);
      ref.read(presenceServiceProvider).start(uid);
    }

    // Tapped while the app was in the background
    _openedSub = TapNotifier.opened.listen(_onNotificationOpened);

    // Tapped while the app was closed
    TapNotifier.consumeLaunch().then((response) {
      if (response != null && mounted) _onNotificationOpened(response);
    });
  }

  @override
  void dispose() {
    _openedSub?.cancel();
    super.dispose();
  }

  // No payload = a tap notification; a payload = a reminder's eventId
  void _onNotificationOpened(NotificationResponse response) {
    final eventId = response.payload;

    if (eventId == null || eventId.isEmpty) {
      _openFromNotification();
    } else {
      _openEvent(eventId);
    }
  }

  // Opens the event on its next day, so yearly events show the right year count
  void _openEvent(String eventId) {
    final events = ref.read(eventsProvider).value;

    if (events == null) {
      _openEventOnLoad = eventId;
      return;
    }

    // Gone if it was deleted after the reminder was sent
    final event = events.where((e) => e.id == eventId).firstOrNull;
    if (event == null) return;

    final now = DateTime.now();
    final today = DateTime.utc(now.year, now.month, now.day);

    EventDetailScreen.show(context, event, event.nextOn(today) ?? event.date);
  }

  // The tray only holds the newest tap, so open that one
  void _openFromNotification() {
    final moment = ref.read(lastReceivedProvider);

    if (moment == null) {
      _openOnLoad = true;
      return;
    }

    _showReceived(moment);
  }

  Future<void> _showReceived(Moment moment) async {
    // Screen already open: swap in the new tap
    if (_received != null) {
      _received!.value = moment.feeling;
      return;
    }

    final uid = ref.read(authStateProvider).value?.uid;

    if (uid == null) return;

    final vibrationEnabled = ref
        .read(userProvider(uid))
        .value
        ?.vibrationEnabled;

    final partnerName = ref.read(partnerProvider)?.displayName ?? '';

    _received = ValueNotifier(moment.feeling);

    await ReceivedScreen.show(
      context,
      partnerName: partnerName,
      feeling: _received!,
      vibrate: vibrationEnabled ?? true,
    );

    // The screen has closed and stopped listening
    _received!.dispose();
    _received = null;
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<Moment?>(lastReceivedProvider, (prev, next) {
      if (next == null) return; // No tap yet

      // Moments finished loading after a notification was tapped
      if (_openOnLoad) {
        _openOnLoad = false;
        _showReceived(next);
        return;
      }

      if (next.id == prev?.id) return; // Same tap as before
      // The tap is older than when the app opened
      if (next.createdAt.isBefore(_openedAt)) return;

      _showReceived(next);
    });

    // Events finished loading after a reminder was tapped
    ref.listen(eventsProvider, (_, next) {
      final eventId = _openEventOnLoad;
      if (eventId == null || !next.hasValue) return;

      _openEventOnLoad = null;
      _openEvent(eventId);
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
