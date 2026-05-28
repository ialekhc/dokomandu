import 'dart:convert';

import 'package:dokomandu/app/config/app_config.dart';
import 'package:dokomandu/core/storage/local_cache_service.dart';
import 'package:dokomandu/features/auth/models/demo_auth_user_model.dart';

class AuthLocalStore {
  const AuthLocalStore(this._cache);

  final LocalCacheService _cache;

  Future<List<DemoAuthUserModel>> readUsers() async {
    final raw = await _cache.getString(AppConfig.cacheDemoUsers);
    if (raw == null || raw.isEmpty) {
      final seeded = _seedUsers();
      await saveUsers(seeded);
      return seeded;
    }

    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded
        .whereType<Map>()
        .map(
          (e) => DemoAuthUserModel.fromJson(
            e.map((key, value) => MapEntry(key.toString(), value)),
          ),
        )
        .toList();
  }

  Future<void> saveUsers(List<DemoAuthUserModel> users) async {
    final payload = users.map((e) => e.toJson()).toList();
    await _cache.setString(AppConfig.cacheDemoUsers, jsonEncode(payload));
  }

  Future<DemoAuthUserModel?> findByPhone(String phone) async {
    final needle = _normalizePhone(phone);
    final users = await readUsers();
    for (final user in users) {
      if (_normalizePhone(user.phone) == needle) return user;
    }
    return null;
  }

  Future<void> upsertUser(DemoAuthUserModel user) async {
    final users = await readUsers();
    final normalized = _normalizePhone(user.phone);
    final normalizedUser = DemoAuthUserModel(
      id: user.id,
      fullName: user.fullName,
      phone: normalized,
      password: user.password,
    );
    final index = users.indexWhere(
      (e) => _normalizePhone(e.phone) == normalized,
    );
    if (index >= 0) {
      users[index] = normalizedUser;
    } else {
      users.insert(0, normalizedUser);
    }
    await saveUsers(users);
  }

  List<DemoAuthUserModel> _seedUsers() {
    return const [
      DemoAuthUserModel(
        id: 'demo-user-1',
        fullName: 'Demo Customer',
        phone: '9800000000',
        password: '123456',
      ),
    ];
  }

  String _normalizePhone(String phone) {
    return phone.replaceAll(RegExp(r'[^0-9]'), '');
  }
}
