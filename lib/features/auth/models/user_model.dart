import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String email;
  final String? name;
  final String? photoUrl;
  final String? coupleId; // null until paired
  final String? lastFeelingId;
  final String? inviteCode;
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.email,
    this.name,
    this.photoUrl,
    this.coupleId,
    this.lastFeelingId,
    this.inviteCode,
    required this.createdAt,
  });

  bool get isPaired => coupleId != null;

  // "Varsha", or "varsha.k" from the email if no name yet
  String get displayName => name ?? email.split('@').first;

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
    createdAt: (map['createdAt'] as Timestamp).toDate(),
  );
}
