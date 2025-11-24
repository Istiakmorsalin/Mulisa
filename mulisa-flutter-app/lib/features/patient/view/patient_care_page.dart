import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart' show BlocSelector;
import 'package:mulisa/features/patient/view/profile/patient_profile_page.dart';
import 'package:mulisa/features/vitals/view/vitals_entry_page.dart'; // Add this import
import '../model/patient.dart';
import '../vm/patient_cubit.dart';
import '../vm/patient_state.dart';

// Keep as StatelessWidget, but derive patient from bloc
class PatientCarePage extends StatelessWidget {
  static const routeName = '/patient-care';
  final Patient patient; // only used for the id

  const PatientCarePage({super.key, required this.patient});

  static Widget fromArgs(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments;
    if (args is Patient) return PatientCarePage(patient: args);
    throw ArgumentError('PatientCarePage requires a Patient as arguments');
  }

  @override
  Widget build(BuildContext context) {
    return BlocSelector<PatientCubit, PatientState, Patient?>(
      selector: (s) => s.patients.firstWhere(
            (p) => p.id == patient.id,
        orElse: () => patient, // fallback to initial
      ),
      builder: (context, live) {
        final p = live ?? patient;
        return _PatientCareScaffold(patient: p);
      },
    );
  }
}

// Extracted original UI into a separate widget
class _PatientCareScaffold extends StatelessWidget {
  final Patient patient;
  const _PatientCareScaffold({required this.patient});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const tiles = [
      _CareTileData('Patient Profile', Icons.person_outline),
      _CareTileData('Vital Logs', Icons.monitor_heart_outlined),
      _CareTileData('Lab e‑Report', Icons.science_outlined),
      _CareTileData('Medication Tracker', Icons.medication_outlined),
      _CareTileData('One‑Click Ambulance', Icons.local_hospital_outlined),
      _CareTileData('AI e‑Prescription', Icons.psychology_alt_outlined),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('${patient.name} • Care'),
        // (style choice) titleTextStyle: theme.textTheme.labelMedium,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                elevation: 0,
                color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.4),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 22,
                        child: Text(
                          patient.name.isNotEmpty ? patient.name[0].toUpperCase() : '?',
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          '${patient.name}  •  ${patient.gender}, ${patient.age}',
                          style: theme.textTheme.titleMedium,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: GridView.builder(
                  itemCount: tiles.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 14,
                    crossAxisSpacing: 14,
                    childAspectRatio: 1.10,
                  ),
                  itemBuilder: (context, i) {
                    final t = tiles[i];
                    return _CareActionCard(
                      label: t.label,
                      icon: t.icon,
                      onTap: () => _handleTap(context, t.label, patient),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleTap(BuildContext context, String label, Patient patient) async {
    switch (label) {
      case 'Patient Profile':
        await Navigator.pushNamed(
          context,
          PatientProfilePage.routeName,
          arguments: patient,
        );
        return;

      case 'Vital Logs':
      // Show vitals modal for viewing/adding vitals
        if (patient.id != null) {
          final saved = await VitalsModal.show(
            context,
            patientId: patient.id!,
            patient: patient,
          );
          if (saved == true) {
            // Vitals saved/updated successfully
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.white),
                      SizedBox(width: 8),
                      Text('Vitals saved successfully'),
                    ],
                  ),
                  backgroundColor: Colors.green,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Patient ID not available'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;

    // Add other cases as needed...
      case 'Lab e‑Report':
      case 'Medication Tracker':
      case 'One‑Click Ambulance':
      case 'AI e‑Prescription':
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$label (coming soon)')),
        );
        return;
    }
  }
}

class _CareTileData {
  final String label;
  final IconData icon;
  const _CareTileData(this.label, this.icon);
}

class _CareActionCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback? onTap;

  const _CareActionCard({super.key, required this.label, required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.primaryContainer.withOpacity(0.25),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 34, color: theme.colorScheme.primary),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: Text(
                    label,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}