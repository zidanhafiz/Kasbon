import 'package:equatable/equatable.dart';

/// User tier levels for the app
enum UserTier {
  /// Free tier - basic features only
  free,

  /// Premium tier - all features unlocked
  premium,
}

/// App user entity representing an authenticated user
class AppUser extends Equatable {
  final String id;
  final String email;
  final String? fullName;
  final String? phone;
  final UserTier tier;
  final DateTime createdAt;
  final DateTime? lastSignInAt;

  const AppUser({
    required this.id,
    required this.email,
    this.fullName,
    this.phone,
    this.tier = UserTier.free,
    required this.createdAt,
    this.lastSignInAt,
  });

  /// Get display name (full name or email prefix)
  String get displayName {
    if (fullName != null && fullName!.isNotEmpty) {
      return fullName!;
    }
    return email.split('@').first;
  }

  /// Get initials for avatar (1-2 characters)
  String get initials {
    if (fullName != null && fullName!.isNotEmpty) {
      final parts = fullName!.trim().split(' ');
      if (parts.length >= 2) {
        return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
      }
      return parts.first[0].toUpperCase();
    }
    return email[0].toUpperCase();
  }

  /// Check if user is on premium tier
  bool get isPremium => tier == UserTier.premium;

  /// Create a copy of the user with updated fields
  AppUser copyWith({
    String? id,
    String? email,
    String? fullName,
    String? phone,
    UserTier? tier,
    DateTime? createdAt,
    DateTime? lastSignInAt,
  }) {
    return AppUser(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      tier: tier ?? this.tier,
      createdAt: createdAt ?? this.createdAt,
      lastSignInAt: lastSignInAt ?? this.lastSignInAt,
    );
  }

  @override
  List<Object?> get props => [id, email];
}
