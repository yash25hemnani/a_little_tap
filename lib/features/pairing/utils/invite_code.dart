import 'dart:math';

// No 0/O, 1/I/L so codes are easy to read out loud
const _alphabet = 'ABCDEFGHJKMNPQRSTUVWXYZ23456789';
final _random = Random.secure();

// 8 chars, stored without the dash: "7F3KQ29D"
String generateInviteCode() => List.generate(
  8,
  (_) => _alphabet[_random.nextInt(_alphabet.length)],
).join();

// "7F3KQ29D" → "7F3K-Q29D" for display
String formatInviteCode(String code) =>
    '${code.substring(0, 4)}-${code.substring(4)}';
