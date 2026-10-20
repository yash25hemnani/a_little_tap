import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String email;
  final String? name;
  final String? photoUrl;
  final String? coupleId; // null until paired
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.email,
    this.name,
    this.photoUrl,
    this.coupleId,
    required this.createdAt,
  });

  bool get isPaired => coupleId != null;

  Map<String, dynamic> toMap() => {
    'email': email,
    'name': name,
    'photoUrl': photoUrl,
    'coupleId': coupleId,
    'createdAt': Timestamp.fromDate(createdAt),
  };

  factory UserModel.fromMap(String id, Map<String, dynamic> map) => UserModel(
    id: id,
    email: map['email'],
    name: map['name'],
    photoUrl: map['photoUrl'],
    coupleId: map['coupleId'],
    createdAt: (map['createdAt'] as Timestamp).toDate(),
  );
}
