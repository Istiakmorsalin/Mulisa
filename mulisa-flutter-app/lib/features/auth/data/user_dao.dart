import 'package:sqflite/sqflite.dart';

import '../../auth/model/user.dart';

class UserDao {
  final Database db;
  UserDao(this.db);

  Future<User> insertLocalUser({
    required String id,
    required String name,
    required String email,
    required String password,
    String token = '',
  }) async {
    await db.insert('users', {
      'id': id,
      'name': name,
      'token': token,
      'email': email,
      'password': password, // ⚠️ hash in production
      'created_at': DateTime.now().millisecondsSinceEpoch,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
    return User(id: id, name: name, token: token);
  }

  Future<User?> findByEmail(String email) async {
    final rows = await db.query(
      'users',
      columns: ['id', 'name', 'token', 'email'],
      where: 'email = ?',
      whereArgs: [email],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    final r = rows.first;
    return User(
      id: r['id'] as String,
      name: (r['name'] as String?) ?? 'User',
      token: (r['token'] as String?) ?? '',
    );
  }

  Future<bool> verifyCredentials(String email, String password) async {
    final rows = await db.query(
      'users',
      columns: ['password'],
      where: 'email = ?',
      whereArgs: [email],
      limit: 1,
    );
    if (rows.isEmpty) return false;
    return (rows.first['password'] as String) == password;
  }

  Future<void> upsertFromRemote(User user, {String? email}) async {
    await db.insert('users', {
      'id': user.id,
      'name': user.name,
      'token': user.token,
      'email': email, // may be null if server didn’t return it
      'created_at': DateTime.now().millisecondsSinceEpoch,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> updateToken(String userId, String token) async {
    await db.update(
      'users',
      {'token': token},
      where: 'id = ?',
      whereArgs: [userId],
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
  }
}
