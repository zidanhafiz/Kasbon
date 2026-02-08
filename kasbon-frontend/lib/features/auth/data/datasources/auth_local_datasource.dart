import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../models/user_model.dart';

/// Local data source for caching auth data securely
abstract class AuthLocalDataSource {
  /// Cache user data locally
  Future<void> cacheUser(UserModel user);

  /// Get cached user data
  Future<UserModel?> getCachedUser();

  /// Clear cached user data
  Future<void> clearCachedUser();

  /// Check if user is cached
  Future<bool> hasCache();
}

/// Implementation of AuthLocalDataSource using FlutterSecureStorage
class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final FlutterSecureStorage _secureStorage;

  static const String _userKey = 'cached_user';

  AuthLocalDataSourceImpl(this._secureStorage);

  @override
  Future<void> cacheUser(UserModel user) async {
    final jsonString = jsonEncode(user.toJson());
    await _secureStorage.write(key: _userKey, value: jsonString);
  }

  @override
  Future<UserModel?> getCachedUser() async {
    final jsonString = await _secureStorage.read(key: _userKey);
    if (jsonString == null) return null;

    try {
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      return UserModel.fromJson(json);
    } catch (e) {
      // If parsing fails, clear the invalid cache
      await clearCachedUser();
      return null;
    }
  }

  @override
  Future<void> clearCachedUser() async {
    await _secureStorage.delete(key: _userKey);
  }

  @override
  Future<bool> hasCache() async {
    final value = await _secureStorage.read(key: _userKey);
    return value != null;
  }
}
