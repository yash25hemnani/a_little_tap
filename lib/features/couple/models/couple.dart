import 'package:cloud_firestore/cloud_firestore.dart';

class Couple {
  final String id;
  final List<String> members;
  final DateTime createdAt;

  const Couple({
    required this.id,
    required this.members,
    required this.createdAt,
  });

  factory Couple.fromMap(String id, Map<String, dynamic> map) => Couple(
    id: id,
    members: (map['members'] as List).cast<String>(),
    createdAt: (map['createdAt'] as Timestamp).toDate(),
  );

  // member who is not me
  String partnerOf(String uid) => members.firstWhere((m) => m != uid);
}
