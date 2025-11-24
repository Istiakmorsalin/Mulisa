// lib/features/scheduler/vm/smart_scheduler_cubit.dart
import 'package:flutter/material.dart'; // ADD THIS
import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/scheduler_repo.dart';
import 'package:mulisa/features/patient/data/ipatient_repo.dart';
import 'smart_scheduler_state.dart';
import '../data/scheduler_models.dart';

class SmartSchedulerCubit extends Cubit<SmartSchedulerState> {
  final SchedulerRepo _schedulerRepo;
  final IPatientRepo _patientRepo;
  final String userId;

  SmartSchedulerCubit({
    required SchedulerRepo schedulerRepo,
    required IPatientRepo patientRepo,
    required this.userId,
  })  : _schedulerRepo = schedulerRepo,
        _patientRepo = patientRepo,
        super(SmartSchedulerState.initial());

  Future<void> init() async {
    emit(state.copyWith(loadingFilters: true, loadingPatients: true, error: null));

    try {
      // Load filters and patients in parallel with proper typing
      final (providers, types, locations, patients) = await (
      _schedulerRepo.getProviders(),
      _schedulerRepo.getAppointmentTypes(),
      _schedulerRepo.getLocations(),
      _patientRepo.getAll(),
      ).wait;

      emit(state.copyWith(
        providers: providers,
        types: types,
        locations: locations,
        patients: patients,
        loadingFilters: false,
        loadingPatients: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        loadingFilters: false,
        loadingPatients: false,
        error: 'Failed to load scheduler data: ${e.toString()}',
      ));
    }
  }

  void setProvider(String providerId) {
    emit(state.copyWith(providerId: providerId, error: null));
  }

  void setType(String typeId) {
    emit(state.copyWith(typeId: typeId, error: null));
  }

  void setLocation(String locationId) {
    emit(state.copyWith(locationId: locationId, error: null));
  }

  void setPatient(String patientId) {
    emit(state.copyWith(patientId: patientId, error: null));
  }

  void setDate(DateTime date) {
    emit(state.copyWith(date: date, error: null));
  }

  void setTime(TimeOfDay time) {
    emit(state.copyWith(time: time, error: null));
  }

  void setNotes(String? notes) {
    emit(state.copyWith(notes: notes, error: null));
  }

  Future<void> bookAppointment() async {
    if (!state.canBook) {
      emit(state.copyWith(error: 'Please fill in all required fields'));
      return;
    }

    emit(state.copyWith(booking: true, error: null));

    try {
      // Combine date and time into a single DateTime
      final appointmentDateTime = DateTime(
        state.date.year,
        state.date.month,
        state.date.day,
        state.time.hour,
        state.time.minute,
      );

      final booking = AppointmentBooking(
        patientId: state.patientId!,
        providerId: state.providerId!,
        appointmentTypeId: state.typeId!,
        locationId: state.locationId!,
        appointmentDateTime: appointmentDateTime,
        notes: state.notes,
      );

      await _schedulerRepo.bookAppointment(booking);

      emit(state.copyWith(booking: false, error: null));
    } catch (e) {
      emit(state.copyWith(
        booking: false,
        error: 'Failed to book appointment: ${e.toString()}',
      ));
    }
  }
}