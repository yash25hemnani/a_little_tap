import 'package:a_little_tap/core/constants/feelings.dart';

// One tap in the history; sent = true when you sent it
typedef Moment = ({Feeling feeling, DateTime at, bool sent});

// Sample data until taps come from the backend (newest first)
final sampleMoments = <Moment>[
  (
    feeling: feelings[1],
    at: DateTime.now().subtract(const Duration(hours: 1)),
    sent: false,
  ),
  (
    feeling: feelings[0],
    at: DateTime.now().subtract(const Duration(hours: 3)),
    sent: true,
  ),
  (
    feeling: feelings[2],
    at: DateTime.now().subtract(const Duration(days: 1)),
    sent: false,
  ),
  (
    feeling: feelings[0],
    at: DateTime.now().subtract(const Duration(days: 1, hours: 4)),
    sent: true,
  ),
  (
    feeling: feelings[0],
    at: DateTime.now().subtract(const Duration(days: 6)),
    sent: false,
  ),
];
