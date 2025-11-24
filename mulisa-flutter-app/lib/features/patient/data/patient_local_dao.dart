// lib/features/patient/data/patient_local_dao.dart
import '../../../core/db/app_database.dart';
import '../model/patient.dart';
import 'ipatient_repo.dart';

class PatientLocalDao implements IPatientRepo {
  final AppDatabase _appDb;
  PatientLocalDao(this._appDb);

  @override
  Future<List<Patient>> getAll() async {
    final res = await _appDb.db.query('patients', orderBy: 'id DESC');
    return res.map((e) => Patient.fromDbMap(e)).toList();
  }

  @override
  Future<Patient> add(Patient p) async {
    final data = Map<String, Object?>.from(p.toDbMap())..remove('id');
    final id = await _appDb.db.insert('patients', data);
    return p.copyWith(id: id);
  }

  @override
  Future<Patient> update(Patient p) async {
    if (p.id == null) throw ArgumentError('Cannot update Patient without id');
    final data = Map<String, Object?>.from(p.toDbMap())..remove('id');
    final count = await _appDb.db.update(
      'patients',
      data,
      where: 'id = ?',
      whereArgs: [p.id],
    );
    if (count == 0) {
      throw StateError('No row updated for id=${p.id}');
    }
    return p;
  }

  @override
  Future<void> delete(int id) async {
    await _appDb.db.delete('patients', where: 'id = ?', whereArgs: [id]);
  }
}
