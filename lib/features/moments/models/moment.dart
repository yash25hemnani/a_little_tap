import 'package:a_little_tap/features/feelings/models/feeling.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// One tap in the history: couples/{coupleId}/moments/{id}
class Moment {
  final String id;
  final String fromUid;
  final Feeling feeling; // copied at send time, so later edits don't change history
  final DateTime createdAt;

  const Moment({
    required this.id,
    required this.fromUid,
    required this.feeling,
    required this.createdAt,
  });

  bool isFrom(String uid) => fromUid == uid;

  // Feeling fields are stored flat
  // `id` isn't written and the server sets the time
  Map<String, dynamic> toMap() => {
    'fromUid': fromUid,
    'title': feeling.title,
    'subtitle': feeling.subtitle,
    'iconKey': feeling.iconKey,
    'color': feeling.colorValue,
    'vibration': feeling.vibration.map((v) => v.toMap()).toList(),
    'createdAt': FieldValue.serverTimestamp(),
  };

  factory Moment.fromMap(String id, Map<String, dynamic> map) => Moment(
    id: id,
    fromUid: map['fromUid'] as String? ?? '',
    // Same field names as a feeling doc
    feeling: Feeling.fromMap(id, map),
    // Null until the server confirms a write we just made
    createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
  );
}