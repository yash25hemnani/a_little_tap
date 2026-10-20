import 'package:cloud_firestore/cloud_firestore.dart';

// pairRequests/{fromUid}_{toUid}
class PairRequest {
  final String id;
  final String fromUid;
  final String fromName;
  final String toUid;
  final String toName;
  final DateTime createdAt;

  const PairRequest({
    required this.id,
    required this.fromUid,
    required this.fromName,
    required this.toUid,
    required this.toName,
    required this.createdAt,
  });

  // One doc per pair, so sending twice doesn't make duplicates
  static String idFor(String fromUid, String toUid) => "${fromUid}_$toUid";

  // id isn't stored: it's already the doc's name
  Map<String, dynamic> toMap() => {
    'fromUid': fromUid,
    'fromName': fromName,
    'toUid': toUid,
    'toName': toName,
    'createdAt': Timestamp.fromDate(createdAt),
  };

  factory PairRequest.fromMap(String id, Map<String, dynamic> map) =>
      PairRequest(
        id: id,
        fromUid: map['fromUid'],
        fromName: map['fromName'],
        toUid: map['toUid'],
        toName: map['toName'],
        // Firestore gives back a Timestamp, not a DateTime
        createdAt: (map['createdAt'] as Timestamp).toDate(),
      );
}
