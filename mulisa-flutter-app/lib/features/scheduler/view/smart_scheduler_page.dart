// lib/features/scheduler/pages/smart_scheduler_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/di/injector.dart';
import '../../../features/auth/data/auth_local_store.dart';
import 'package:mulisa/features/patient/model/patient.dart';
import '../data/scheduler_models.dart';
import '../vm/smart_scheduler_cubit.dart';
import '../vm/smart_scheduler_state.dart';

class SmartSchedulerPage extends StatelessWidget {
  static const routeName = '/smart-scheduler';

  const SmartSchedulerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: getIt<AuthLocalStore>().readUserId(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Colors.white,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading user session...'),
                ],
              ),
            ),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            backgroundColor: Colors.white,
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(
                      'Error loading user session: ${snapshot.error}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        final userId = snapshot.data;

        if (userId == null || userId.isEmpty) {
          return Scaffold(
            backgroundColor: Colors.white,
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.person_off_outlined, size: 64, color: Colors.orange),
                    const SizedBox(height: 16),
                    const Text(
                      'No user session found',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Please log in to access the scheduler',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14, color: Colors.black54),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.login),
                      label: const Text('Go to Login'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                      onPressed: () {
                        Navigator.of(context).popUntil((route) => route.isFirst);
                      },
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        return BlocProvider(
          create: (_) => getIt<SmartSchedulerCubit>(param1: userId),
          child: const _SmartSchedulerView(),
        );
      },
    );
  }
}

class _SmartSchedulerView extends StatefulWidget {
  const _SmartSchedulerView({super.key});

  @override
  State<_SmartSchedulerView> createState() => _SmartSchedulerViewState();
}

class _SmartSchedulerViewState extends State<_SmartSchedulerView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<SmartSchedulerCubit>().init();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Book Appointment'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: BlocConsumer<SmartSchedulerCubit, SmartSchedulerState>(
          listenWhen: (prev, curr) => prev.error != curr.error || (prev.booking && !curr.booking),
          listener: (context, state) {
            if (state.error != null && state.error!.isNotEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.error!),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: Colors.red.shade700,
                ),
              );
            }

            if (!state.booking && state.error == null && state.providers.isNotEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('✅ Appointment booked successfully!'),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: Colors.green,
                  duration: Duration(seconds: 2),
                ),
              );
            }
          },
          builder: (context, state) {
            if ((state.loadingFilters || state.loadingPatients) && state.providers.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Loading scheduler...'),
                  ],
                ),
              );
            }

            if (state.error != null && state.providers.isEmpty && !state.loadingFilters && !state.loadingPatients) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 64, color: Colors.red),
                      const SizedBox(height: 16),
                      Text(
                        state.error!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.refresh),
                        label: const Text('Retry'),
                        onPressed: () {
                          context.read<SmartSchedulerCubit>().init();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _BookingForm(
                    loading: state.loadingFilters || state.loadingPatients || state.booking,
                    providers: state.providers,
                    types: state.types,
                    locations: state.locations,
                    patients: state.patients,
                    selectedProviderId: state.providerId,
                    selectedTypeId: state.typeId,
                    selectedLocationId: state.locationId,
                    selectedPatientId: state.patientId,
                    date: state.date,
                    time: state.time,
                    notes: state.notes,
                    onProviderChanged: (id) => context.read<SmartSchedulerCubit>().setProvider(id),
                    onTypeChanged: (id) => context.read<SmartSchedulerCubit>().setType(id),
                    onLocationChanged: (id) => context.read<SmartSchedulerCubit>().setLocation(id),
                    onPatientChanged: (id) => context.read<SmartSchedulerCubit>().setPatient(id),
                    onDateChanged: (d) => context.read<SmartSchedulerCubit>().setDate(d),
                    onTimeChanged: (t) => context.read<SmartSchedulerCubit>().setTime(t),
                    onNotesChanged: (n) => context.read<SmartSchedulerCubit>().setNotes(n),
                    onBook: () => context.read<SmartSchedulerCubit>().bookAppointment(),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _BookingForm extends StatelessWidget {
  final bool loading;
  final List<ProviderSummary> providers;
  final List<AppointmentTypeModel> types;
  final List<LocationModel> locations;
  final List<Patient> patients;
  final String? selectedProviderId;
  final String? selectedTypeId;
  final String? selectedLocationId;
  final String? selectedPatientId;
  final DateTime date;
  final TimeOfDay time;
  final String? notes;
  final ValueChanged<String> onProviderChanged;
  final ValueChanged<String> onTypeChanged;
  final ValueChanged<String> onLocationChanged;
  final ValueChanged<String> onPatientChanged;
  final ValueChanged<DateTime> onDateChanged;
  final ValueChanged<TimeOfDay> onTimeChanged;
  final ValueChanged<String?> onNotesChanged;
  final VoidCallback onBook;

  const _BookingForm({
    required this.loading,
    required this.providers,
    required this.types,
    required this.locations,
    required this.patients,
    required this.selectedProviderId,
    required this.selectedTypeId,
    required this.selectedLocationId,
    required this.selectedPatientId,
    required this.date,
    required this.time,
    required this.notes,
    required this.onProviderChanged,
    required this.onTypeChanged,
    required this.onLocationChanged,
    required this.onPatientChanged,
    required this.onDateChanged,
    required this.onTimeChanged,
    required this.onNotesChanged,
    required this.onBook,
  });

  String _formatPatientDisplay(Patient patient) {
    // Use name field and show age/gender as additional info
    final info = <String>[];
    if (patient.age > 0) info.add('${patient.age}yo');
    if (patient.gender.isNotEmpty && patient.gender != 'Unknown') {
      info.add(patient.gender);
    }

    if (info.isEmpty) {
      return patient.name;
    }
    return '${patient.name} • ${info.join(', ')}';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Patient Selection - First Field
        const Text('Patient', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        _Dropdown<String>(
          value: selectedPatientId,
          hint: 'Select patient',
          items: patients
              .map((p) => DropdownMenuItem(
            value: p.externalId ?? p.id?.toString(),
            child: Text(_formatPatientDisplay(p)),
          ))
              .toList(),
          onChanged: (v) {
            if (v != null) onPatientChanged(v);
          },
        ),
        const SizedBox(height: 20),

        // Provider
        const Text('Provider', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        _Dropdown<String>(
          value: selectedProviderId,
          hint: 'Select provider',
          items: providers
              .map((p) => DropdownMenuItem(
            value: p.id,
            child: Text('${p.name} • ${p.specialty}'),
          ))
              .toList(),
          onChanged: (v) {
            if (v != null) onProviderChanged(v);
          },
        ),
        const SizedBox(height: 16),

        // Appointment Type
        const Text('Appointment Type', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        _Dropdown<String>(
          value: selectedTypeId,
          hint: 'Select type',
          items: types
              .map((t) => DropdownMenuItem(
            value: t.id,
            child: Text('${t.name} (${t.durationMin} min)'),
          ))
              .toList(),
          onChanged: (v) {
            if (v != null) onTypeChanged(v);
          },
        ),
        const SizedBox(height: 16),

        // Location
        const Text('Location', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        _Dropdown<String>(
          value: selectedLocationId,
          hint: 'Select location',
          items: locations
              .map((l) => DropdownMenuItem(
            value: l.id,
            child: Text(l.name),
          ))
              .toList(),
          onChanged: (v) {
            if (v != null) onLocationChanged(v);
          },
        ),
        const SizedBox(height: 16),

        // Date
        const Text('Date', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        InkWell(
          onTap: loading ? null : () async {
            final now = DateTime.now();
            final picked = await showDatePicker(
              context: context,
              initialDate: date,
              firstDate: DateTime(now.year, now.month, now.day),
              lastDate: DateTime(now.year + 1),
            );
            if (picked != null) onDateChanged(picked);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            decoration: BoxDecoration(
              border: Border.all(color: loading ? Colors.grey.shade300 : Colors.grey),
              borderRadius: BorderRadius.circular(8),
              color: loading ? Colors.grey.shade50 : Colors.white,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  MaterialLocalizations.of(context).formatMediumDate(date),
                  style: TextStyle(
                    color: loading ? Colors.grey : Colors.black,
                  ),
                ),
                Icon(
                  Icons.calendar_today,
                  color: loading ? Colors.grey : Colors.black,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Time
        const Text('Time', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        InkWell(
          onTap: loading ? null : () async {
            final picked = await showTimePicker(
              context: context,
              initialTime: time,
            );
            if (picked != null) onTimeChanged(picked);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            decoration: BoxDecoration(
              border: Border.all(color: loading ? Colors.grey.shade300 : Colors.grey),
              borderRadius: BorderRadius.circular(8),
              color: loading ? Colors.grey.shade50 : Colors.white,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  time.format(context),
                  style: TextStyle(
                    color: loading ? Colors.grey : Colors.black,
                  ),
                ),
                Icon(
                  Icons.access_time,
                  color: loading ? Colors.grey : Colors.black,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Notes
        const Text('Notes (Optional)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        TextField(
          enabled: !loading,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'Add any additional notes...',
            border: const OutlineInputBorder(),
            filled: loading,
            fillColor: loading ? Colors.grey.shade50 : Colors.white,
          ),
          onChanged: onNotesChanged,
        ),
        const SizedBox(height: 24),

        // Book Button
        ElevatedButton(
          onPressed: loading ? null : onBook,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            disabledBackgroundColor: Colors.grey.shade400,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: loading
              ? const SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          )
              : const Text('Book Appointment', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }
}

class _Dropdown<T> extends StatelessWidget {
  final T? value;
  final String hint;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;

  const _Dropdown({
    required this.value,
    required this.hint,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isEnabled = items.isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: isEnabled ? Colors.grey : Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
        color: isEnabled ? Colors.white : Colors.grey.shade50,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          isExpanded: true,
          value: value,
          hint: Text(
            hint,
            style: TextStyle(
              color: isEnabled ? Colors.grey.shade700 : Colors.grey.shade400,
            ),
          ),
          items: items,
          onChanged: isEnabled ? onChanged : null,
        ),
      ),
    );
  }
}