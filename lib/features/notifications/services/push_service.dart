import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

// Keeps this phone's FCM address (FID) in users/{uid}.fcmTokens
class PushService {
  final _db = FirebaseFirestore.instance;
  final _messaging = FirebaseMessaging.instance;

  StreamSubscription<String>? _registeredSub;
  String? _fid; // Phone's FID, once registered

  Future<void> notifyPartner({
    required String coupleId,
    required String momentId,
  }) async {
    try {
      final token = await FirebaseAuth.instance.currentUser?.getIdToken();

      if (token == null) return;

      final res = await http.post(
        Uri.parse('https://worker.little-tap.workers.dev'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'coupleId': coupleId, 'momentId': momentId}),
      );

      // http doesn't throw on 4xx/5xx, so log the result
      debugPrint('push: worker ${res.statusCode} ${res.body}');
    } catch (e) {
      // The tap is already saved, so a failed push is only logged
      debugPrint('push: worker call failed $e');
    }
  }

  // Ask permission, then save the FID whenever FCM hands one out
  Future<void> init(String uid) async {
    try {
      debugPrint('push: init uid=$uid');
      final settings = await _messaging.requestPermission();
      debugPrint('push: permission=${settings.authorizationStatus}');
      if (settings.authorizationStatus == AuthorizationStatus.denied) return;

      // Listen before registering so the first FID isn't missed
      await _registeredSub?.cancel();
      _registeredSub = _messaging.onRegistered.listen((fid) {
        debugPrint('push: onRegistered fid=$fid');
        _fid = fid;
        _saveToUser(uid, fid)
            .then((_) => debugPrint('push: saved'))
            .catchError((Object e) => debugPrint('push: save failed $e'));
      });

      await _messaging.register();
      debugPrint('push: register() done');
    } catch (e) {
      // Push is optional, so the app keeps working without it
      debugPrint('push: init failed $e');
    }
  }

  // Stop pushes to this phone. Call before signing out, while rules still allow the write
  Future<void> removeToken(String uid) async {
    try {
      await _registeredSub?.cancel();
      _registeredSub = null;

      final fid = _fid;
      if (fid != null) {
        await _db.collection('users').doc(uid).update({
          'fcmTokens': FieldValue.arrayRemove([fid]),
        });
      }

      await _messaging.unregister();
      _fid = null;
    } catch (_) {
      // Logging out shouldn't fail because of this
    }
  }

  // arrayUnion skips duplicates, so repeat registrations are harmless
  Future<void> _saveToUser(String uid, String fid) {
    return _db.collection('users').doc(uid).update({
      'fcmTokens': FieldValue.arrayUnion([fid]),
    });
  }
}
