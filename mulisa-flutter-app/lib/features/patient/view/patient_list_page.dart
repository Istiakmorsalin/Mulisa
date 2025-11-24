import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mulisa/features/patient/view/patient_care_page.dart';
import 'package:mulisa/features/patient/view/patient_editor_sheet.dart';
import '../../vitals/view/vitals_entry_page.dart';

import '../model/patient.dart';
import '../vm/patient_cubit.dart';
import '../vm/patient_state.dart';

class PatientListPage extends StatefulWidget {
  static const routeName = '/patients';
  const PatientListPage({super.key});

  @override
  State<PatientListPage> createState() => _PatientListPageState();
}

class _PatientListPageState extends State<PatientListPage> {
  String _query = '';

  @override
  void initState() {
    super.initState();
    // Trigger initial fetch -> hits /patients/ via your DAO/Cubit
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PatientCubit>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Patient Care'),
        actions: [
          IconButton(
            onPressed: () => _openEditor(context),
            icon: const Icon(Icons.person_add_alt_1),
            tooltip: 'Add patient',
          ),
        ],
      ),
      body: BlocListener<PatientCubit, PatientState>(
        listenWhen: (prev, curr) => prev.error != curr.error && curr.error != null,
        listener: (context, state) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.error!)),
          );
        },
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: SearchAnchor(
                builder: (BuildContext context, SearchController controller) {
                  return SearchBar(
                    controller: controller,
                    padding: const MaterialStatePropertyAll<EdgeInsets>(
                      EdgeInsets.symmetric(horizontal: 16),
                    ),
                    hintText: 'Search patients...',
                    leading: const Icon(Icons.search),
                    onChanged: (val) => setState(() => _query = val.toLowerCase()),
                  );
                },
                suggestionsBuilder: (context, controller) => const <Widget>[],
              ),
            ),
            Expanded(
              child: BlocBuilder<PatientCubit, PatientState>(
                builder: (context, state) {
                  if (state.loading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final patients = state.patients.where((p) {
                    return p.name.toLowerCase().contains(_query) ||
                        p.gender.toLowerCase().contains(_query) ||
                        p.age.toString().contains(_query);
                  }).toList();

                  if (patients.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('No patients found.'),
                          const SizedBox(height: 12),
                          OutlinedButton.icon(
                            icon: const Icon(Icons.person_add_alt_1),
                            label: const Text('Add a patient'),
                            onPressed: () => _openEditor(context),
                          ),
                        ],
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () => context.read<PatientCubit>().load(),
                    child: ListView.separated(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(12),
                      itemCount: patients.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, i) {
                        final p = patients[i];

                        return Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            leading: SizedBox(
                              width: 56,
                              height: 56,
                              child: ClipOval(
                                child: (p.photoUrl != null && p.photoUrl!.isNotEmpty)
                                    ? Image.network(
                                  p.photoUrl!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Image.asset(
                                    'assets/images/patient.jpg',
                                    fit: BoxFit.cover,
                                  ),
                                )
                                    : Image.asset(
                                  'assets/images/patient.jpg',
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            title: Text(
                              p.name,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w600),
                            ),
                            subtitle: Text(
                              '${p.gender}, Age: ${p.age}',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(color: Colors.grey[700]),
                            ),
                            onTap: () {
                              Navigator.of(context).pushNamed(
                                PatientCarePage.routeName,
                                arguments: p,
                              );
                            },
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  tooltip: 'Add vitals',
                                  onPressed: () async {
                                    final saved = await VitalsModal.show(
                                      context,
                                      patientId: p.id!,     // ensure not null
                                      patient: p,           // optional (for title)
                                    );
                                    if (saved == true) {
                                      // If you want to refresh patient details or history after save, do it here.
                                      // e.g., context.read<VitalsCubit>().load(patientId: p.id!);
                                    }
                                  },
                                  icon: const Icon(Icons.monitor_heart, color: Colors.redAccent),
                                ),
                                IconButton(
                                  tooltip: 'Edit',
                                  onPressed: () => _openEditor(context, existing: p),
                                  icon: const Icon(Icons.edit, color: Colors.blueGrey),
                                ),
                                IconButton(
                                  tooltip: 'Delete',
                                  onPressed: () async {
                                    if (p.id == null) return;
                                    final confirm = await showDialog<bool>(
                                      context: context,
                                      builder: (_) => AlertDialog(
                                        title: const Text('Delete patient?'),
                                        content: Text('Remove ${p.name}? This cannot be undone.'),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.pop(context, false),
                                            child: const Text('Cancel'),
                                          ),
                                          FilledButton(
                                            onPressed: () => Navigator.pop(context, true),
                                            child: const Text('Delete'),
                                          ),
                                        ],
                                      ),
                                    );
                                    if (confirm == true) {
                                      await context.read<PatientCubit>().remove(p.id!);
                                    }
                                  },
                                  icon: const Icon(Icons.delete, color: Colors.grey),
                                ),
                              ],
                            ),

                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openEditor(BuildContext context, {Patient? existing}) async {
    final result = await PatientEditorSheet.show(context, existing: existing);
    if (result == null) return;

    if (existing == null) {
      await context.read<PatientCubit>().add(result);
      // Optionally re-load to reflect server-side defaults
      // await context.read<PatientCubit>().load();
    } else {
      await context.read<PatientCubit>().update(result);
    }
  }
}
