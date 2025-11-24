// lib/core/db/app_database.dart
import 'dart:async';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class AppDatabase {
  final Database db;
  AppDatabase._(this.db);

  static const _dbName = 'mulisa.db'; // change to 'mulisa_dev.db' if you want a clean slate
  static const _dbVersion = 2;        // Increment version to trigger migration

  /// Create and open the database (fresh schema, no migrations).
  static Future<AppDatabase> create() async {
    final dir = await getApplicationDocumentsDirectory();
    final path = p.join(dir.path, _dbName);
    final database = await openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
      onDowngrade: onDatabaseDowngradeDelete, // if version ever goes down, wipe
    );
    return AppDatabase._(database);
  }

  /// DEV-ONLY: delete the DB file to force a clean start next launch.
  static Future<void> reset() async {
    final dir = await getApplicationDocumentsDirectory();
    final path = p.join(dir.path, _dbName);
    await deleteDatabase(path);
  }

  /// Fresh install schema (v2 layout with user_id in session).
  static FutureOr<void> _onCreate(Database db, int version) async {
    // session
    await db.execute('''
      CREATE TABLE session(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        token TEXT,
        user_id TEXT
      );
    ''');

    // patients (new prefixed schema)
    await db.execute('''
      CREATE TABLE patients(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        externalId TEXT,
        name TEXT NOT NULL,
        age INTEGER NOT NULL,
        gender TEXT NOT NULL,
        photoUrl TEXT,

        -- ContactInfo
        contact_phone TEXT,
        contact_email TEXT,
        contact_address TEXT,

        -- MedicalProfile
        med_bloodGroup TEXT,
        med_allergies TEXT,
        med_history TEXT,
        med_currentMeds TEXT,

        -- EmergencyContact
        emc_name TEXT,
        emc_phone TEXT,
        emc_relationship TEXT,

        -- Vitals
        vital_hr INTEGER,
        vital_bpSys INTEGER,
        vital_bpDia INTEGER,
        vital_heightCm REAL,
        vital_weightKg REAL,

        -- Notes
        notes TEXT
      );
    ''');

    // users
    await db.execute('''
      CREATE TABLE users(
        id TEXT PRIMARY KEY,
        name TEXT,
        token TEXT,
        email TEXT UNIQUE,
        password TEXT,
        created_at INTEGER
      );
    ''');

    // indexes
    await db.execute('CREATE INDEX IF NOT EXISTS idx_patients_externalId ON patients(externalId);');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);');
  }

  /// Migration from v1 to v2: add user_id to session table
  static FutureOr<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Add user_id column to session table
      await db.execute('ALTER TABLE session ADD COLUMN user_id TEXT;');
    }
  }
}