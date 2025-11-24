import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// --- Domain models / cubits ---
import 'package:mulisa/features/patient/model/patient.dart';
import 'package:mulisa/features/vitals/vm/vitals_cubit.dart';
import 'package:mulisa/features/vitals/vm/vitals_state.dart';
import 'package:mulisa/features/vitals/vitals_extensions.dart';
import 'package:mulisa/core/di/injector.dart';

// --- UI widgets ---
import 'widgets/header_overview.dart';
import 'widgets/vitals_summary_grid.dart';
import 'widgets/blood_pressure_card.dart';
import 'widgets/profile_tabs.dart';
import 'widgets/patient_info_card.dart';
import 'widgets/heart_rate_card.dart';

class PatientProfilePage extends StatelessWidget {
  static const routeName = '/patient-profile';
  final Patient patient;

  const PatientProfilePage({super.key, required this.patient});

  static Widget fromArgs(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments;
    if (args is Patient) return PatientProfilePage(patient: args);
    throw ArgumentError('PatientProfilePage requires a Patient as arguments');
  }

  @override
  Widget build(BuildContext context) {
    // Provide VitalsCubit just for this page (scoped)
    return BlocProvider<VitalsCubit>(
      create: (_) {
        final c = getIt<VitalsCubit>();
        final id = patient.id;
        if (id != null) c.loadLatest(patientId: id);
        return c;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Patient Profile'),
        ),
        body: SafeArea(
          child: RefreshIndicator(
            onRefresh: () => _refreshVitals(context),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                HeaderOverview(patient: patient),
                const SizedBox(height: 12),

                // ==== HEART RATE from backend ====
                _HeartRateSection(patient: patient),

                const SizedBox(height: 12),

                // ==== SUMMARY GRID ====
                _VitalsSummarySection(patient: patient),

                const SizedBox(height: 12),

                // ==== BP CARD from backend ====
                _BloodPressureSection(patient: patient),

                const SizedBox(height: 24),

                ProfileTabs(patient: patient),
                const SizedBox(height: 24),

                // === Beautiful Patient Info Card ===
                PatientInfoCard(patient: patient),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _refreshVitals(BuildContext context) async {
    final id = patient.id;
    if (id != null) {
      await context.read<VitalsCubit>().loadLatest(patientId: id);
    }
  }
}

// ==== EXTRACTED WIDGETS FOR BETTER ORGANIZATION ====

class _HeartRateSection extends StatelessWidget {
  final Patient patient;

  const _HeartRateSection({required this.patient});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<VitalsCubit, VitalsState>(
      builder: (context, state) {
        if (state.loading) {
          return const HeartRateCard.loading();
        }

        if (state.error != null) {
          return HeartRateCard(
            bpm: null,
            isNormal: false,
            subtitle: 'Failed to load vitals',
            errorMessage: state.error,
          );
        }

        // Extension is called automatically on the nullable Map
        final bpm = state.current?.heartRate;
        final isNormal = (bpm != null) ? (bpm >= 60 && bpm <= 100) : null;

        return HeartRateCard(
          bpm: bpm,
          isNormal: isNormal ?? true,
          subtitle: bpm == null ? 'No data available' : null,
        );
      },
    );
  }
}

class _VitalsSummarySection extends StatelessWidget {
  final Patient patient;

  const _VitalsSummarySection({required this.patient});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<VitalsCubit, VitalsState>(
      builder: (context, state) {
        return VitalsSummaryGrid(
          patient: patient,
          vital: state.current,
          isLoading: state.loading,
          hasError: state.error != null,
        );
      },
    );
  }
}

class _BloodPressureSection extends StatelessWidget {
  final Patient patient;

  const _BloodPressureSection({required this.patient});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<VitalsCubit, VitalsState>(
      builder: (context, state) {
        return BloodPressureCard(
          patient: patient,
          systolic: state.current?.systolic,
          diastolic: state.current?.diastolic,
          recordedAt: state.current?.recordedAt,
          loading: state.loading,
          errorText: state.error,
        );
      },
    );
  }
}