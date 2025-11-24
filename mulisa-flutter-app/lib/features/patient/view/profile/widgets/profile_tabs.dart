// lib/features/patient/view/profile/widgets/profile_tabs.dart
import 'package:flutter/material.dart';
import 'package:mulisa/features/patient/model/patient.dart';
import 'package:mulisa/features/patient/view/profile/widgets/patient_appointments_tab.dart';

class ProfileTabs extends StatelessWidget {
  final Patient patient;

  const ProfileTabs({
    super.key,
    required this.patient,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DefaultTabController(
      length: 3,
      initialIndex: 0, // Start on first tab (which is now Consultation)
      child: Column(
        children: [
          TabBar(
            isScrollable: false,
            labelStyle: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
            tabs: const [
              Tab(text: 'Consultation'),    // Moved to first
              Tab(text: 'Medications'),     // Second
              Tab(text: 'Latest report'),   // Third
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 400, // Increased height for appointments
            child: TabBarView(
              children: [
                // Consultation tab - FIRST
                PatientAppointmentsTab(
                  patientId: patient.id != null ? patient.id.toString() : '',
                ),

                // Medications tab - SECOND
                const _PlaceholderCard(text: 'No medications found'),

                // Latest report tab - THIRD
                const _LatestReportList(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LatestReportList extends StatelessWidget {
  const _LatestReportList();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Widget row(String title, String date) {
      return Card(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        child: ListTile(
          leading: const Icon(Icons.insert_drive_file_outlined),
          title: Text(title, style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700)),
          subtitle: Text(date),
          trailing: const Icon(Icons.more_horiz),
          onTap: () {},
        ),
      );
    }

    return Column(
      children: [
        row('General  report', 'Jul 10, 2023'),
        row('General  report', 'Jul 5, 2023'),
      ],
    );
  }
}

class _PlaceholderCard extends StatelessWidget {
  final String text;
  const _PlaceholderCard({required this.text});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Center(child: Text(text, style: theme.textTheme.bodyMedium)),
    );
  }
}