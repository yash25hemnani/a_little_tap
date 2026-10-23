import 'dart:async';
import 'dart:ui' show Color;

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// Shows tap notifications. Vibration is off on the channel
// because the app plays the feeling's own pattern
class TapNotifier {
  static final _plugin = FlutterLocalNotificationsPlugin();

  static const _channel = AndroidNotificationChannel(
    'taps',
    'Taps',
    description: "When your partner sends a tap",
    importance: Importance.high, // high = pops up on screen
    enableVibration: false,
  );

  // Same id every time, so a new tap replaces the last one in the tray
  static const _tapId = 0;

  static final _opened = StreamController<void>.broadcast();

  static Stream<void> get opened => _opened.stream;

  static bool _launchChecked = false;

  static Future<void> init() async {
    await _plugin.initialize(
      settings: InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      ),
      onDidReceiveNotificationResponse: (_) => _opened.add(null),
    );

    await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(_channel);
  }

  // True once, when a tap notification launched the app from closed
  static Future<bool> consumeLaunchTap() async {
    if (_launchChecked) return false;

    _launchChecked = true;

    return (await _plugin.getNotificationAppLaunchDetails())
            ?.didNotificationLaunchApp ??
        false;
  }

  // color tints the small icon and app name; null keeps the default
  static Future<void> show(String title, String body, {Color? color}) async {
    await _plugin.show(
      id: _tapId,
      title: title,
      body: body,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          _channel.id,
          _channel.name,
          importance: Importance.high,
          priority: Priority.high,
          enableVibration: false,
          icon: 'ic_stat_heart', // res/drawable/ic_stat_heart.xml
          color: color,
        ),
      ),
    );
  }
}
