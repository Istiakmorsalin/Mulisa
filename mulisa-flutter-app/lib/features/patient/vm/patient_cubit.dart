// lib/features/patient/vm/patient_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/ipatient_repo.dart';
import '../model/patient.dart';
import 'patient_state.dart';

class PatientCubit extends Cubit<PatientState> {
  final IPatientRepo _repo;
  PatientCubit(this._repo) : super(const PatientState());

  Future<void> load() async {
    emit(state.copyWith(loading: true, error: null));
    try {
      final list = await _repo.getAll();
      emit(state.copyWith(loading: false, patients: list));
    } catch (e) {
      emit(state.copyWith(loading: false, error: e.toString()));
    }
  }

  Future<void> add(Patient p) async {
    try {
      final created = await _repo.add(p);
      emit(state.copyWith(patients: [created, ...state.patients]));
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<Patient?> update(Patient p) async {
    try {
      final up = await _repo.update(p);
      final updatedList =
      state.patients.map((e) => e.id == up.id ? up : e).toList();
      emit(state.copyWith(patients: updatedList));
      return up;
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
      return null;
    }
  }

  Future<void> remove(int id) async {
    final before = state.patients;
    emit(state.copyWith(patients: before.where((e) => e.id != id).toList()));
    try {
      await _repo.delete(id);
    } catch (e) {
      emit(state.copyWith(patients: before, error: e.toString()));
    }
  }
}
