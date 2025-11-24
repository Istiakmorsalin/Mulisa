import '../model/patient.dart';

abstract class IPatientRepo {
  Future<List<Patient>> getAll();
  Future<Patient> add(Patient p);
  Future<Patient> update(Patient p);
  Future<void> delete(int id);
}
