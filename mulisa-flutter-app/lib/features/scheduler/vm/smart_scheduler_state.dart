// lib/features/scheduler/vm/smart_scheduler_state.dart
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import '../data/scheduler_models.dart';
import 'package:mulisa/features/patient/model/patient.dart';

const _sentinel = Object();

class SmartSchedulerState extends Equatable {
  final bool loadingFilters;
  final bool loadingPatients; // Add this
  final bool booking;
  final List<ProviderSummary> providers;
  final List<AppointmentTypeModel> types;
  final List<LocationModel> locations;
  final List<Patient> patients; // Add this
  final String? providerId;
  final String? typeId;
  final String? locationId;
  final String? patientId; // Add this
  final DateTime date;
  final TimeOfDay time;
  final String? notes;
  final String? error;

  const SmartSchedulerState({
    required this.loadingFilters,
    required this.loadingPatients, // Add this
    required this.booking,
    required this.providers,
    required this.types,
    required this.locations,
    required this.patients, // Add this
    required this.providerId,
    required this.typeId,
    required this.locationId,
    required this.patientId, // Add this
    required this.date,
    required this.time,
    required this.notes,
    required this.error,
  });

  factory SmartSchedulerState.initial() {
    final today = DateTime.now();
    return SmartSchedulerState(
      loadingFilters: false,
      loadingPatients: false, // Add this
      booking: false,
      providers: const [],
      types: const [],
      locations: const [],
      patients: const [], // Add this
      providerId: null,
      typeId: null,
      locationId: null,
      patientId: null, // Add this
      date: DateTime(today.year, today.month, today.day),
      time: const TimeOfDay(hour: 9, minute: 0),
      notes: null,
      error: null,
    );
  }

  SmartSchedulerState copyWith({
    bool? loadingFilters,
    bool? loadingPatients, // Add this
    bool? booking,
    List<ProviderSummary>? providers,
    List<AppointmentTypeModel>? types,
    List<LocationModel>? locations,
    List<Patient>? patients, // Add this
    Object? providerId = _sentinel,
    Object? typeId = _sentinel,
    Object? locationId = _sentinel,
    Object? patientId = _sentinel, // Add this
    DateTime? date,
    TimeOfDay? time,
    Object? notes = _sentinel,
    Object? error = _sentinel,
  }) {
    return SmartSchedulerState(
      loadingFilters: loadingFilters ?? this.loadingFilters,
      loadingPatients: loadingPatients ?? this.loadingPatients, // Add this
      booking: booking ?? this.booking,
      providers: providers ?? this.providers,
      types: types ?? this.types,
      locations: locations ?? this.locations,
      patients: patients ?? this.patients, // Add this
      providerId: providerId == _sentinel ? this.providerId : providerId as String?,
      typeId: typeId == _sentinel ? this.typeId : typeId as String?,
      locationId: locationId == _sentinel ? this.locationId : locationId as String?,
      patientId: patientId == _sentinel ? this.patientId : patientId as String?, // Add this
      date: date ?? this.date,
      time: time ?? this.time,
      notes: notes == _sentinel ? this.notes : notes as String?,
      error: error == _sentinel ? this.error : error as String?,
    );
  }

  bool get canBook =>
      providerId != null &&
          typeId != null &&
          locationId != null &&
          patientId != null && // Add this
          !booking;

  @override
  List<Object?> get props => [
    loadingFilters,
    loadingPatients, // Add this
    booking,
    providers,
    types,
    locations,
    patients, // Add this
    providerId,
    typeId,
    locationId,
    patientId, // Add this
    date,
    time,
    notes,
    error,
  ];
}