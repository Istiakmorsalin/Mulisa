import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mulisa/features/vitals/data/ivitals_repo.dart';
import 'vitals_state.dart';

class VitalsCubit extends Cubit<VitalsState> {
  final IVitalsRepo _repo;
  VitalsCubit(this._repo) : super(VitalsState.initial());

  Future<void> load({
    required int patientId,
    DateTime? from,
    DateTime? to,
  }) async {
    emit(state.copyWith(loading: true, error: null));
    try {
      final list = await _repo.listVitals(patientId: patientId, from: from, to: to);
      emit(state.copyWith(loading: false, items: list, error: null));
    } catch (e) {
      emit(state.copyWith(loading: false, error: e.toString()));
    }
  }

  /// Fetch latest (server should return newest first; if not, sort by created/recorded)
  Future<void> loadLatest({required int patientId}) async {
    emit(state.copyWith(loading: true, error: null));
    try {
      final list = await _repo.listVitals(patientId: patientId);

      // Sort by recordedAt or id to ensure we get the latest
      final sortedList = List<Map<String, dynamic>>.from(list)
        ..sort((a, b) {
          // Try recordedAt first (camelCase from your API)
          final aTime = a['recordedAt'] ?? a['recorded_at'];
          final bTime = b['recordedAt'] ?? b['recorded_at'];

          if (aTime != null && bTime != null) {
            return DateTime.parse(bTime).compareTo(DateTime.parse(aTime));
          }

          // Fall back to id comparison (higher id = newer)
          final aId = a['id'] ?? 0;
          final bId = b['id'] ?? 0;
          return (bId as int).compareTo(aId as int);
        });

      final latest = sortedList.isNotEmpty ? sortedList.first : null;
      emit(state.copyWith(loading: false, items: sortedList, current: latest, error: null));
    } catch (e) {
      emit(state.copyWith(loading: false, error: e.toString()));
    }
  }

  Future<void> add({
    required int patientId,
    required Map<String, dynamic> body,
    DateTime? reloadFrom,
    DateTime? reloadTo,
  }) async {
    emit(state.copyWith(saving: true, error: null));
    try {
      await _repo.createVital(patientId: patientId, body: body);
      await loadLatest(patientId: patientId);
      emit(state.copyWith(saving: false, error: null));
    } catch (e) {
      emit(state.copyWith(saving: false, error: e.toString()));
    }
  }

  Future<void> update({
    required int patientId,
    required int vitalId,
    required Map<String, dynamic> body,
  }) async {
    emit(state.copyWith(saving: true, error: null));
    try {
      await _repo.updateVital(patientId: patientId, vitalId: vitalId, body: body);
      await loadLatest(patientId: patientId);
      emit(state.copyWith(saving: false, error: null));
    } catch (e) {
      emit(state.copyWith(saving: false, error: e.toString()));
    }
  }

  void clearError() => emit(state.copyWith(error: null));
}
