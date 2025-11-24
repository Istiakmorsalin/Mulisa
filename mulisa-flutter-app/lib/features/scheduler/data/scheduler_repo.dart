import 'package:flutter/material.dart'; // ← ADD THIS IMPORT
// lib/features/scheduler/data/scheduler_repo.dart
import 'package:dio/dio.dart';
import 'package:mulisa/core/network/dio_client.dart';
import 'scheduler_models.dart';

class SchedulerRepo {
  final DioClient client;

  SchedulerRepo(this.client);

  // Helper to normalize DRF paginated or plain list responses
  List<Map<String, dynamic>> _extractList(dynamic data) {
    if (data is List) {
      return data.cast<Map<String, dynamic>>();
    }
    if (data is Map<String, dynamic> && data['results'] is List) {
      return (data['results'] as List).cast<Map<String, dynamic>>();
    }
    return const <Map<String, dynamic>>[];
  }

  // --- Appointment Types ---
  Future<List<AppointmentTypeModel>> getAppointmentTypes() async {
    final res = await client.get(
      '/appointment-types/',
      requireAuth: true,
    );
    final list = _extractList(res.data);
    return list.map((json) => AppointmentTypeModel.fromJson(json)).toList();
  }

  // --- Providers ---
  Future<List<ProviderSummary>> getProviders() async {
    final res = await client.get(
      '/providers/',
      requireAuth: true,
    );
    final list = _extractList(res.data);
    return list.map((json) => ProviderSummary.fromJson(json)).toList();
  }

  // --- Locations ---
  Future<List<LocationModel>> getLocations() async {
    final res = await client.get(
      '/locations/',
      requireAuth: true,
    );
    final list = _extractList(res.data);
    return list.map((json) => LocationModel.fromJson(json)).toList();
  }

  // --- Book Appointment (Simplified - no slots) ---
  Future<void> bookAppointment(AppointmentBooking booking) async {
    final res = await client.post(
      '/appointments/',
      requireAuth: true,
      data: booking.toJson(),
    );

  }

  // --- Get All Appointments ---
  Future<List<AppointmentModel>> getAppointments({int page = 1, int pageSize = 10}) async {
    final res = await client.get(
      '/appointments/',
      requireAuth: true,
      queryParameters: {
        'page': page,
        'page_size': pageSize,
      },
    );
    final list = _extractList(res.data);
    return list.map((json) => AppointmentModel.fromJson(json)).toList();
  }

  // --- Get Upcoming Appointments ---
  Future<List<AppointmentModel>> getUpcomingAppointments({int page = 1, int pageSize = 10}) async {
    final res = await client.get(
      '/appointments/upcoming/',
      requireAuth: true,
      queryParameters: {
        'page': page,
        'page_size': pageSize,
      },
    );
    final list = _extractList(res.data);
    return list.map((json) => AppointmentModel.fromJson(json)).toList();
  }

  // --- Get Past Appointments ---
  Future<List<AppointmentModel>> getPastAppointments({int page = 1, int pageSize = 10}) async {
    final res = await client.get(
      '/appointments/past/',
      requireAuth: true,
      queryParameters: {
        'page': page,
        'page_size': pageSize,
      },
    );
    final list = _extractList(res.data);
    return list.map((json) => AppointmentModel.fromJson(json)).toList();
  }

  // --- Cancel Appointment ---
  Future<AppointmentModel> cancelAppointment(String appointmentId) async {
    final res = await client.patch(
      '/appointments/$appointmentId/cancel/',
      requireAuth: true,
    );
    return AppointmentModel.fromJson(res.data as Map<String, dynamic>);
  }

  // --- Delete Appointment ---
  Future<void> deleteAppointment(String appointmentId) async {
    await client.delete(
      '/appointments/$appointmentId/',
      requireAuth: true,
    );
  }

  // --- Get Appointments by Patient ID ---
  Future<List<AppointmentModel>> getPatientAppointments(String patientId, {int page = 1, int pageSize = 10}) async {
    final res = await client.get(
      '/appointments/',
      requireAuth: true,
      queryParameters: {
        'patient_id': patientId,
        'page': page,
        'page_size': pageSize,
      },
    );
    final list = _extractList(res.data);
    return list.map((json) => AppointmentModel.fromJson(json)).toList();
  }
}