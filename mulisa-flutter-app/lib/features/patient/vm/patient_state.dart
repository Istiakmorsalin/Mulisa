import 'package:equatable/equatable.dart';

import '../model/patient.dart';


class PatientState extends Equatable {
  final bool loading;
  final List<Patient> patients;
  final String? error;

  const PatientState({
    this.loading = false,
    this.patients = const [],
    this.error,
  });

  PatientState copyWith({
    bool? loading,
    List<Patient>? patients,
    String? error,
  }) => PatientState(
    loading: loading ?? this.loading,
    patients: patients ?? this.patients,
    error: error,
  );

  @override
  List<Object?> get props => [loading, patients, error];
}
