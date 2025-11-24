// lib/features/auth/data/auth_local_store.dart
import '../../../core/db/app_database.dart';

class AuthLocalStore {
  final AppDatabase _appDb;
  AuthLocalStore(this._appDb);

  // Save both token and userId together
  Future<void> saveSession(String token, String userId) async {
    final db = _appDb.db;
    await db.delete('session');
    await db.insert('session', {
      'token': token,
      'user_id': userId,
    });
  }

  Future<void> saveToken(String token) async {
    final db = _appDb.db;
    await db.delete('session');
    await db.insert('session', {'token': token});
  }

  Future<String?> readToken() async {
    final db = _appDb.db;
    final res = await db.query('session', limit: 1);
    if (res.isEmpty) return null;
    return res.first['token'] as String?;
  }

  Future<String?> readUserId() async {
    final db = _appDb.db;
    final res = await db.query('session', limit: 1);
    if (res.isEmpty) return null;
    return res.first['user_id'] as String?;
  }

  Future<void> clear() async {
    final db = _appDb.db;
    await db.delete('session');
  }
}