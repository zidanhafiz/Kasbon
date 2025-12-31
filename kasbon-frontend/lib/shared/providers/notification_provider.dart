import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider for notification count
///
/// Simple StateProvider for notification badge count.
/// In the future, this can be upgraded to fetch from local DB or backend.
final notificationCountProvider = StateProvider<int>((ref) {
  // Default: no notifications
  return 0;
});

/// Provider to check if there are unread notifications
final hasUnreadNotificationsProvider = Provider<bool>((ref) {
  return ref.watch(notificationCountProvider) > 0;
});
