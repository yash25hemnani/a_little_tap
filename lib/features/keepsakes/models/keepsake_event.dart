import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

// Fixed list of event categories, stored in Firestore as `type` (the enum's name)
enum EventType {
  date('Date', Icons.favorite_rounded),
  birthday('Birthday', Icons.cake_rounded),
  anniversary('Anniversary', Icons.celebration_rounded),
  trip('Trip', Icons.flight_rounded),
  other('Other', Icons.event_rounded);

  final String label;
  final IconData icon;
  const EventType(this.label, this.icon);

  // Missing or unknown keys (older events) read as other
  static EventType fromKey(String? key) =>
      values.where((t) => t.name == key).firstOrNull ?? other;

  // Birthdays and anniversaries come back every year by default
  bool get yearlyByDefault => this == birthday || this == anniversary;
}

class KeepsakeEvent {
  final String id;
  final String title;
  final DateTime date;
  final EventType type;
  final bool yearly;
  final String createdBy;
  final DateTime createdAt;

  const KeepsakeEvent({
    required this.id,
    required this.title,
    required this.date,
    required this.type,
    required this.yearly,
    required this.createdBy,
    required this.createdAt,
  });

  // `id` isn't written and the server sets createdAt
  Map<String, dynamic> toMap() => {
    'title': title,
    'date': Timestamp.fromDate(date),
    'type': type.name,
    'yearly': yearly,
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
      type: EventType.fromKey(map['type']),
      yearly: map['yearly'] as bool? ?? false,
      createdBy: map['createdBy'] as String? ?? '',
      // Null until the server confirms a write we just made
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  // Whether this event shows on `day` (a UTC day).
  // Yearly events match month and day, but only from their first date onwards
  bool isOn(DateTime day) {
    if (!yearly) return day == date;

    return !day.isBefore(date) &&
        day.month == date.month &&
        day.day == date.day;
  }

  // The next day this event falls on, from `today` onwards; null for a past one-off
  DateTime? nextOn(DateTime today) {
    if (!date.isBefore(today)) return date; // first time is still ahead

    if (!yearly) return null;

    final thisYear = DateTime.utc(today.year, date.month, date.day);
    if (!thisYear.isBefore(today)) return thisYear; // still ahead this year

    return DateTime.utc(today.year + 1, date.month, date.day);
  }

  // Which year this is, e.g. 3 on the third anniversary
  int yearsOn(DateTime day) => day.year - date.year;
}
