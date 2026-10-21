import 'package:a_little_tap/features/notifications/services/push_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final pushServiceProvider = Provider((ref) => PushService());