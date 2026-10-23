import 'dart:async';
import 'dart:ui' show Color;

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// Shows tap and reminder notifications. Vibration is off on the taps channel
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

  static const _remindersChannel = AndroidNotificationChannel(
    'reminders',
    'Reminders',
    description: 'Dates coming up in Keepsakes',
    importance: Importance.high,
  );

  // Same id every time, so a new tap replaces the last one in the tray
  static const _tapId = 0;

  static final _opened = StreamController<NotificationResponse>.broadcast();

  // A notification tapped while the app was running; its payload says which kind
  static Stream<NotificationResponse> get opened => _opened.stream;

  static bool _launchChecked = false;

  static Future<void> init() async {
    await _plugin.initialize(
      settings: InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      ),
      onDidReceiveNotificationResponse: _opened.add,
    );

    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    await android?.createNotificationChannel(_channel);
    await android?.createNotificationChannel(_remindersChannel);
  }

  // The notification that launched the app from closed, once; null otherwise
  static Future<NotificationResponse?> consumeLaunch() async {
    if (_launchChecked) return null;

    _launchChecked = true;

    final details = await _plugin.getNotificationAppLaunchDetails();
    if (details == null || !details.didNotificationLaunchApp) return null;

    return details.notificationResponse;
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

  // One per event, so it doesn't replace a tap; "Today" replaces that event's "Tomorrow"
  static Future<void> showReminder(
    String title,
    String body,
    String eventId,
  ) async {
    await _plugin.show(
      id: eventId.hashCode & 0x7fffffff, // must be a positive 32-bit int
      title: title,
      body: body,
      payload: eventId, // tells MainLayout which event to open
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          _remindersChannel.id,
          _remindersChannel.name,
          importance: Importance.high,
          priority: Priority.high,
          icon: 'ic_stat_calendar', // res/drawable/ic_stat_calendar.xml
        ),
      ),
    );
  }
}
