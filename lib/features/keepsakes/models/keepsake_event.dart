import 'package:cloud_firestore/cloud_firestore.dart';

class KeepsakeEvent {
  final String id;
  final String title;
  final DateTime date;
  final String createdBy;
  final DateTime createdAt;

  const KeepsakeEvent({
    required this.id,
    required this.title,
    required this.date,
    required this.createdBy,
    required this.createdAt,
  });

  // `id` isn't written and the server sets createdAt
  Map<String, dynamic> toMap() => {
    'title': title,
    'date': Timestamp.fromDate(date),
    'createdBy': createdBy,
    'createdAt': FieldValue.serverTimestamp(),
  };

  factory KeepsakeEvent.fromMap(String id, Map<String, dynamic> map) {
    // Stored as UTC midnight; read back as the same UTC day so every timezone sees one date
    final utc = (map['date'] as Timestamp).toDate().toUtc();

    return KeepsakeEvent(
      id: id,
      title: map['title'] as String? ?? '',
      date: DateTime.utc(utc.year, utc.month, utc.day),
      createdBy: map['createdBy'] as String? ?? '',
      // Null until the server confirms a write we just made
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}
