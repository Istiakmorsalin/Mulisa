import 'package:mulisa/core/network/%20api_endpoints.dart';

import '../../../core/network/dio_client.dart';
import '../model/user.dart';
import 'user_dao.dart';

class AuthService {
  final DioClient client;
  final UserDao userDao;
  AuthService(this.client, this.userDao);

  /// Online-first login; falls back to local verification if server fails.
  Future<User> login(String email, String password) async {
    try {
      final res = await client.post(
        ApiEndpoints.login,
        data: {'email': email, 'password': password},
        requireAuth: false,
      );

      final user = User.fromJson(res.data as Map<String, dynamic>);
      // sync to local DB
      await userDao.upsertFromRemote(user, email: email);
      return user;
    } catch (_) {
      // Offline/failed → fallback to local DB
      final ok = await userDao.verifyCredentials(email, password);
      if (!ok) throw Exception('Invalid credentials (offline)');
      final local = await userDao.findByEmail(email);
      if (local == null) throw Exception('User not found locally');
      return local;
    }
  }

  /// Sign up: try server first; if offline, create user locally.
  Future<User> signUp(String email, String password) async {
    try {
      final res = await client.post(
        ApiEndpoints.signup,
        data: {'email': email, 'password': password},
        requireAuth: false,
      );

      final user = User.fromJson(res.data as Map<String, dynamic>);
      await userDao.insertLocalUser(
        id: user.id,
        name: user.name,
        email: email,
        password: password,
        token: user.token,
      );
      return user;
    } catch (_) {
      // Offline fallback → create local-only user
      final localId = DateTime.now().millisecondsSinceEpoch.toString();
      return userDao.insertLocalUser(
        id: localId,
        name: 'User',
        email: email,
        password: password,
        token: '',
      );
    }
  }

  Future<void> logout() async {
    try {
      await client.post(ApiEndpoints.logout, requireAuth: true);
    } catch (_) {
      // ignore if offline
    }
  }
}
