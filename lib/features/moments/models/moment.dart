import 'package:a_little_tap/features/feelings/constants/feelings.dart';
import 'package:a_little_tap/features/feelings/models/feeling.dart';

// One tap in the history; sent = true when you sent it
typedef Moment = ({Feeling feeling, DateTime at, bool sent});

// TODO: remove when the Moments tab reads from Firestore (4c)
final _sample = [
  for (final (i, f) in defaultFeelings.indexed) Feeling.fromMap('sample$i', f),
];

// Sample data until taps come from the backend (newest first)
final sampleMoments = <Moment>[
  (
    feeling: _sample[1],
    at: DateTime.now().subtract(const Duration(hours: 1)),
    sent: false,
  ),
  (
    feeling: _sample[0],
    at: DateTime.now().subtract(const Duration(hours: 3)),
    sent: true,
  ),
  (
    feeling: _sample[2],
    at: DateTime.now().subtract(const Duration(days: 1)),
    sent: false,
  ),
  (
    feeling: _sample[0],
    at: DateTime.now().subtract(const Duration(days: 1, hours: 4)),
    sent: true,
  ),
  (
    feeling: _sample[0],
    at: DateTime.now().subtract(const Duration(days: 6)),
    sent: false,
  ),
];
