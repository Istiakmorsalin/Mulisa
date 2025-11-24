import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import 'package:mulisa/core/di/injector.dart';
import 'package:mulisa/features/patient/model/patient.dart';
import 'package:mulisa/features/vitals/vm/vitals_cubit.dart';
import 'package:mulisa/features/vitals/vm/vitals_state.dart';

class VitalsModal {
  /// Opens a scrollable, keyboard-safe bottom sheet.
  /// Returns `true` if a vitals record was saved/updated, else null/false.
  static Future<bool?> show(
      BuildContext context, {
        required int patientId,
        Patient? patient,
      }) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      constraints: const BoxConstraints(maxWidth: 720),
      builder: (ctx) {
        final viewInsets = MediaQuery.of(ctx).viewInsets.bottom;
        return BlocProvider(
          create: (_) => getIt<VitalsCubit>()..loadLatest(patientId: patientId),
          child: Padding(
            padding: EdgeInsets.only(bottom: viewInsets),
            child: _VitalsForm(patientId: patientId, patient: patient),
          ),
        );
      },
    );
  }
}

class _VitalsForm extends StatefulWidget {
  final int patientId;
  final Patient? patient;
  const _VitalsForm({required this.patientId, this.patient});

  @override
  State<_VitalsForm> createState() => _VitalsFormState();
}

class _VitalsFormState extends State<_VitalsForm> {
  final _formKey = GlobalKey<FormState>();

  final _hrCtrl = TextEditingController();
  final _sysCtrl = TextEditingController();
  final _diaCtrl = TextEditingController();
  final _heightCtrl = TextEditingController(text: '0'); // allowed to be 0
  final _weightCtrl = TextEditingController(text: '0'); // allowed to be 0
  final _tempCtrl = TextEditingController();
  final _spo2Ctrl = TextEditingController();
  final _rrCtrl = TextEditingController();

  DateTime _recordedAt = DateTime.now().toUtc();
  bool _prefilled = false; // ensure we prefill only once per open

  @override
  void dispose() {
    _hrCtrl.dispose();
    _sysCtrl.dispose();
    _diaCtrl.dispose();
    _heightCtrl.dispose();
    _weightCtrl.dispose();
    _tempCtrl.dispose();
    _spo2Ctrl.dispose();
    _rrCtrl.dispose();
    super.dispose();
  }

  String? _reqInt(String? v, {int? min, int? max}) {
    if (v == null || v.trim().isEmpty) return 'Required';
    final n = int.tryParse(v);
    if (n == null) return 'Invalid number';
    if (min != null && n < min) return 'Min $min';
    if (max != null && n > max) return 'Max $max';
    return null;
  }

  String? _reqDouble(String? v, {double? min, double? max}) {
    if (v == null || v.trim().isEmpty) return 'Required';
    final d = double.tryParse(v);
    if (d == null) return 'Invalid number';
    if (min != null && d < min) return 'Min $min';
    if (max != null && d > max) return 'Max $max';
    return null;
  }

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      initialDate: _recordedAt.toLocal(),
    );
    if (date == null) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_recordedAt.toLocal()),
    );
    if (time == null) return;

    setState(() {
      _recordedAt = DateTime(date.year, date.month, date.day, time.hour, time.minute).toUtc();
    });
  }

  void _prefillFromCurrent(Map<String, dynamic> cur) {
    if (_prefilled || cur.isEmpty) return;
    _prefilled = true;

    T? _pick<T>(String snake, String camel) {
      final v = cur[snake] ?? cur[camel];
      return (v is T) ? v : null;
    }

    // Helper to safely get int from either int or num
    int? _getInt(String snake, String camel) {
      final val = cur[snake] ?? cur[camel];
      if (val == null) return null;
      if (val is int) return val;
      if (val is num) return val.toInt();
      return null;
    }

    // Helper to safely get double from either double or num
    double? _getDouble(String snake, String camel) {
      final val = cur[snake] ?? cur[camel];
      if (val == null) return null;
      if (val is double) return val;
      if (val is num) return val.toDouble();
      return null;
    }

    // Populate integer fields
    final hr = _getInt('heart_rate', 'heartRate');
    if (hr != null && hr > 0) _hrCtrl.text = hr.toString();

    final sys = _getInt('bp_sys', 'bpSys');
    if (sys != null && sys > 0) _sysCtrl.text = sys.toString();

    final dia = _getInt('bp_dia', 'bpDia');
    if (dia != null && dia > 0) _diaCtrl.text = dia.toString();

    final spo2 = _getDouble('spo2', 'spo2'); // SpO2 comes as double from API
    if (spo2 != null && spo2 > 0) _spo2Ctrl.text = spo2.toInt().toString();

    final rr = _getInt('respiratory_rate', 'respiratoryRate');
    if (rr != null && rr > 0) _rrCtrl.text = rr.toString();

    // Populate double fields (height, weight, temp)
    final height = _getDouble('height_cm', 'heightCm');
    if (height != null) _heightCtrl.text = height.toInt().toString();

    final weight = _getDouble('weight_kg', 'weightKg');
    if (weight != null) _weightCtrl.text = weight.toInt().toString();

    final temp = _getDouble('temperature_c', 'temperatureC');
    if (temp != null && temp > 0) _tempCtrl.text = temp.toString();

    // Populate recorded_at
    final ra = cur['recorded_at'] ?? cur['recordedAt'];
    if (ra is String) {
      final dt = DateTime.tryParse(ra);
      if (dt != null) _recordedAt = dt.toUtc();
    }
  }

  Future<void> _saveOrUpdate(VitalsState st) async {
    if (!_formKey.currentState!.validate()) return;

    final body = <String, dynamic>{
      "heart_rate": int.parse(_hrCtrl.text),
      "bp_sys": int.parse(_sysCtrl.text),
      "bp_dia": int.parse(_diaCtrl.text),
      "height_cm": int.parse(_heightCtrl.text),
      "weight_kg": int.parse(_weightCtrl.text),
      "temperature_c": double.parse(_tempCtrl.text),
      "spo2": int.parse(_spo2Ctrl.text),
      "respiratory_rate": int.parse(_rrCtrl.text),
      // If backend supports:
      // "recorded_at": _recordedAt.toIso8601String(),
    };

    if (st.editing) {
      final id = st.current!['id'] as int;
      await context.read<VitalsCubit>().update(
        patientId: widget.patientId,
        vitalId: id,
        body: body,
      );
    } else {
      await context.read<VitalsCubit>().add(
        patientId: widget.patientId,
        body: body,
      );
    }

    final after = context.read<VitalsCubit>().state;
    if (mounted && after.error == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(st.editing ? 'Vitals updated' : 'Vitals saved')),
      );
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final df = DateFormat('yyyy-MM-dd  HH:mm');
    return BlocConsumer<VitalsCubit, VitalsState>(
      listenWhen: (p, c) => p.error != c.error && c.error != null,
      listener: (ctx, st) {
        ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text(st.error!)));
      },
      builder: (ctx, st) {

        print('🔍 VitalsForm - loading: ${st.loading}, current: ${st.current}, prefilled: $_prefilled');

        // Prefill once when data is loaded
        if (!_prefilled && st.current != null && !st.loading) {
          print('📝 Prefilling with: ${st.current}');
          _prefillFromCurrent(st.current!);
        }

        final saving = st.saving;
        final title = widget.patient != null
            ? '${st.editing ? "Edit" : "Enter"} Vitals — ${widget.patient!.name}'
            : '${st.editing ? "Edit" : "Enter"} Vitals — Patient ${widget.patientId}';

        return Material(
          color: Theme.of(context).colorScheme.surface,
          child: SafeArea(
            top: false,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Header
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context, false),
                          icon: const Icon(Icons.close),
                          tooltip: 'Close',
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Fields
                    Row(children: [
                      Expanded(
                        child: _Field(
                          controller: _hrCtrl,
                          label: 'Heart Rate (bpm)',
                          validator: (v) => _reqInt(v, min: 20, max: 250),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _Field(
                          controller: _spo2Ctrl,
                          label: 'SpO₂ (%)',
                          validator: (v) => _reqInt(v, min: 50, max: 100),
                        ),
                      ),
                    ]),
                    const SizedBox(height: 12),
                    Row(children: [
                      Expanded(
                        child: _Field(
                          controller: _sysCtrl,
                          label: 'Systolic (mmHg)',
                          validator: (v) => _reqInt(v, min: 50, max: 260),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _Field(
                          controller: _diaCtrl,
                          label: 'Diastolic (mmHg)',
                          validator: (v) => _reqInt(v, min: 30, max: 150),
                        ),
                      ),
                    ]),
                    const SizedBox(height: 12),
                    Row(children: [
                      Expanded(
                        child: _Field(
                          controller: _heightCtrl,
                          label: 'Height (cm)',
                          validator: (v) => _reqInt(v, min: 0, max: 300),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _Field(
                          controller: _weightCtrl,
                          label: 'Weight (kg)',
                          validator: (v) => _reqInt(v, min: 0, max: 500),
                        ),
                      ),
                    ]),
                    const SizedBox(height: 12),
                    Row(children: [
                      Expanded(
                        child: _Field(
                          controller: _tempCtrl,
                          label: 'Temperature (°C)',
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          validator: (v) => _reqDouble(v, min: 30, max: 45),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _Field(
                          controller: _rrCtrl,
                          label: 'Respiratory Rate (breaths/min)',
                          validator: (v) => _reqInt(v, min: 5, max: 80),
                        ),
                      ),
                    ]),
                    const SizedBox(height: 12),

                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Recorded at'),
                      subtitle:
                      Text('${df.format(_recordedAt.toLocal())}  (UTC stored)'),
                      trailing: OutlinedButton.icon(
                        onPressed: _pickDateTime,
                        icon: const Icon(Icons.calendar_today),
                        label: const Text('Change'),
                      ),
                    ),

                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        icon: saving
                            ? const SizedBox(
                          width: 18, height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                            : const Icon(Icons.save),
                        label: Text(st.editing ? 'Update Vitals' : 'Save Vitals'),
                        onPressed: saving ? null : () => _saveOrUpdate(st),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _Field extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;

  const _Field({
    required this.controller,
    required this.label,
    this.keyboardType = TextInputType.number,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration:
      InputDecoration(labelText: label, border: const OutlineInputBorder()),
      keyboardType: keyboardType,
      validator: validator,
    );
  }
}
