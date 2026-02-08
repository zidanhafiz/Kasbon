import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/app_user.dart';

/// Data model for user with JSON serialization support
class UserModel {
  final String id;
  final String email;
  final String? fullName;
  final String? phone;
  final String tier;
  final DateTime createdAt;
  final DateTime? lastSignInAt;

  const UserModel({
    required this.id,
    required this.email,
    this.fullName,
    this.phone,
    this.tier = 'free',
    required this.createdAt,
    this.lastSignInAt,
  });

  /// Create UserModel from Supabase User object
  factory UserModel.fromSupabaseUser(User user) {
    final metadata = user.userMetadata ?? {};

    return UserModel(
      id: user.id,
      email: user.email ?? '',
      fullName: metadata['full_name'] as String?,
      phone: user.phone ?? metadata['phone'] as String?,
      tier: metadata['tier'] as String? ?? 'free',
      createdAt: DateTime.parse(user.createdAt),
      lastSignInAt: user.lastSignInAt != null
          ? DateTime.tryParse(user.lastSignInAt!)
          : null,
    );
  }

  /// Create UserModel from JSON map (e.g., from local storage)
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      fullName: json['full_name'] as String?,
      phone: json['phone'] as String?,
      tier: json['tier'] as String? ?? 'free',
      createdAt: DateTime.parse(json['created_at'] as String),
      lastSignInAt: json['last_sign_in_at'] != null
          ? DateTime.parse(json['last_sign_in_at'] as String)
          : null,
    );
  }

  /// Convert to JSON map for local storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'phone': phone,
      'tier': tier,
      'created_at': createdAt.toIso8601String(),
      'last_sign_in_at': lastSignInAt?.toIso8601String(),
    };
  }

  /// Convert to AppUser domain entity
  AppUser toEntity() {
    return AppUser(
      id: id,
      email: email,
      fullName: fullName,
      phone: phone,
      tier: _parseTier(tier),
      createdAt: createdAt,
      lastSignInAt: lastSignInAt,
    );
  }

  /// Parse tier string to UserTier enum
  UserTier _parseTier(String tier) {
    switch (tier.toLowerCase()) {
      case 'premium':
        return UserTier.premium;
      default:
        return UserTier.free;
    }
  }

  /// Create UserModel from AppUser entity
  factory UserModel.fromEntity(AppUser user) {
    return UserModel(
      id: user.id,
      email: user.email,
      fullName: user.fullName,
      phone: user.phone,
      tier: user.tier.name,
      createdAt: user.createdAt,
      lastSignInAt: user.lastSignInAt,
    );
  }
}
