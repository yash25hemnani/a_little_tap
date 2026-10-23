import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String email;
  final String? name;
  final String? photoUrl;
  final String? coupleId; // null until paired
  final String? lastFeelingId;
  final String? inviteCode;
  final bool online;
  final DateTime? lastSeen;
  final bool pushEnabled;
  final bool vibrationEnabled;
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.email,
    this.name,
    this.photoUrl,
    this.coupleId,
    this.lastFeelingId,
    this.inviteCode,
    this.online = false,
    this.lastSeen,
    this.pushEnabled = true,
    this.vibrationEnabled = true,
    required this.createdAt,
  });

  bool get isPaired => coupleId != null;

  // "Varsha", or "varsha.k" from the email if no name yet
  String get displayName => name ?? email.split('@').first;

  // Online only if the last heartbeat is recent, so a killed app goes offline
  bool get isOnline =>
      online &&
      lastSeen != null &&
      DateTime.now().difference(lastSeen!) < const Duration(minutes: 2);

  Map<String, dynamic> toMap() => {
    'email': email,
    'name': name,
    'photoUrl': photoUrl,
    'coupleId': coupleId,
    'inviteCode': inviteCode,
    'createdAt': Timestamp.fromDate(createdAt),
  };

  factory UserModel.fromMap(String id, Map<String, dynamic> map) => UserModel(
    id: id,
    email: map['email'],
    name: map['name'],
    photoUrl: map['photoUrl'],
    coupleId: map['coupleId'],
    lastFeelingId: map['lastFeelingId'],
    inviteCode: map['inviteCode'],
    online: map['online'] as bool? ?? false,
    // Null while a server timestamp is still pending
    lastSeen: (map['lastSeen'] as Timestamp?)?.toDate(),
    // Missing on older docs, so default to on
    pushEnabled: map['pushEnabled'] as bool? ?? true,
    vibrationEnabled: map['vibrationEnabled'] as bool? ?? true,
    createdAt: (map['createdAt'] as Timestamp).toDate(),
  );
}
