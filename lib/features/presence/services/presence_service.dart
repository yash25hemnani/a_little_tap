import 'dart:async';

import 'package:a_little_tap/features/auth/repositories/user_repository.dart';
import 'package:flutter/material.dart';

// Keeps users/{uid}.online and lastSeen current while the app is open
class PresenceService {
  final UserRepository _userRepository;
  PresenceService(this._userRepository);

  static const _beat = Duration(seconds: 60);

  String? _uid;
  Timer? _heartbeat;
  AppLifecycleListener? _lifecycle;

  // Online now, every minute while open, and offline when the app is hidden
  void start(String uid) {
    _uid = uid;
    _lifecycle?.dispose();
    _lifecycle = AppLifecycleListener(onShow: _goOnline, onHide: _goOffline);

    _goOnline();
  }

  // Call before signing out, while rules still allow the write
  Future<void> stop() async {
    _lifecycle?.dispose();
    _lifecycle = null;

    await _goOffline();
    _uid = null;
  }

  void _goOnline() {
    _write(true);

    _heartbeat?.cancel();
    _heartbeat = Timer.periodic(_beat, (_) => _write(true));
  }

  Future<void> _goOffline() async {
    _heartbeat?.cancel();
    _heartbeat = null;

    await _write(false);
  }

  Future<void> _write(bool online) async {
    final uid = _uid;
    if (uid == null) return;

    try {
      await _userRepository.setPresence(uid, online);
    } catch (e) {
      // Presence is optional, so the app keeps working without it
      debugPrint('presence: write failed $e');
    }
  }
}
