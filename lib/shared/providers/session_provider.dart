import 'dart:convert';

import 'package:dokomandu/core/storage/secure_storage_service.dart';
import 'package:dokomandu/shared/models/user_model.dart';
import 'package:dokomandu/shared/providers/app_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum SessionStatus { unknown, authenticated, unauthenticated }

class SessionState {
  const SessionState({required this.status, this.user});

  const SessionState.unknown() : this(status: SessionStatus.unknown);

  const SessionState.authenticated(UserModel user)
    : this(status: SessionStatus.authenticated, user: user);

  const SessionState.unauthenticated()
    : this(status: SessionStatus.unauthenticated);

  final SessionStatus status;
  final UserModel? user;
}

class SessionNotifier extends StateNotifier<SessionState> {
  SessionNotifier({required SecureStorageService secureStorage})
    : _secureStorage = secureStorage,
      super(const SessionState.unknown()) {
    bootstrap();
  }

  final SecureStorageService _secureStorage;

  Future<void> bootstrap() async {
    final token = await _secureStorage.readAccessToken();
    if (token == null || token.isEmpty) {
      state = const SessionState.unauthenticated();
      return;
    }

    final userJson = await _secureStorage.readUserJson();
    if (userJson == null || userJson.isEmpty) {
      state = const SessionState.unauthenticated();
      return;
    }

    final map = jsonDecode(userJson) as Map<String, dynamic>;
    state = SessionState.authenticated(UserModel.fromJson(map));
  }

  Future<void> setAuthenticated({
    required String accessToken,
    required String refreshToken,
    required UserModel user,
  }) async {
    await _secureStorage.saveTokens(
      accessToken: accessToken,
      refreshToken: refreshToken,
    );
    await _secureStorage.saveUserJson(jsonEncode(user.toJson()));
    state = SessionState.authenticated(user);
  }

  Future<void> updateUser(UserModel user) async {
    await _secureStorage.saveUserJson(jsonEncode(user.toJson()));
    state = SessionState.authenticated(user);
  }

  Future<void> logout() async {
    await _secureStorage.clearSession();
    state = const SessionState.unauthenticated();
  }
}

final sessionProvider = StateNotifierProvider<SessionNotifier, SessionState>(
  (ref) =>
      SessionNotifier(secureStorage: ref.watch(secureStorageServiceProvider)),
);
