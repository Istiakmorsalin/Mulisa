import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../model/contact_info.dart';
import '../model/medical_profile.dart';
import '../model/patient.dart';
// Removed: import '../model/vitals.dart';

class PatientEditorSheet extends StatefulWidget {
  final Patient? existing;

  const PatientEditorSheet({super.key, this.existing});

  /// Helper to show as a modal bottom sheet and return Patient on save.
  static Future<Patient?> show(BuildContext context, {Patient? existing}) {
    return showModalBottomSheet<Patient?>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => PatientEditorSheet(existing: existing),
    );
  }

  @override
  State<PatientEditorSheet> createState() => _PatientEditorSheetState();
}

class _PatientEditorSheetState extends State<PatientEditorSheet> {
  final _formKey = GlobalKey<FormState>();
  final _picker = ImagePicker();

  // Basic
  late final TextEditingController _nameCtrl;
  late final TextEditingController _ageCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _notesCtrl;
  late final ValueNotifier<String> _gender;
  late final ValueNotifier<String?> _photoPath; // local path or URL

  // Medical only (vitals removed)
  late final TextEditingController _bloodGroupCtrl;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;

    _nameCtrl  = TextEditingController(text: e?.name ?? '');
    _ageCtrl   = TextEditingController(text: e?.age != null ? e!.age.toString() : '');
    _phoneCtrl = TextEditingController(text: e?.contact.phone ?? '');
    _notesCtrl = TextEditingController(text: e?.notes ?? '');
    _gender    = ValueNotifier<String>(e?.gender ?? 'Male');
    _photoPath = ValueNotifier<String?>(e?.photoUrl);

    _bloodGroupCtrl = TextEditingController(text: e?.medical.bloodGroup ?? '');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _ageCtrl.dispose();
    _phoneCtrl.dispose();
    _notesCtrl.dispose();
    _gender.dispose();
    _photoPath.dispose();
    _bloodGroupCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final picked = await _picker.pickImage(
      source: source,
      maxWidth: 1024,
      imageQuality: 85,
    );
    if (picked != null) _photoPath.value = picked.path;
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final e = widget.existing;

    // Parse optionals safely
    int? _tryInt(String s) => s.trim().isEmpty ? null : int.tryParse(s.trim());
    String? _tryString(String s) => s.trim().isEmpty ? null : s.trim();

    final name   = _nameCtrl.text.trim();
    final age    = int.parse(_ageCtrl.text);
    final gender = _gender.value;

    final phone  = _tryString(_phoneCtrl.text);
    final notes  = _tryString(_notesCtrl.text);
    final photo  = _tryString(_photoPath.value ?? '');

    // Medical only (no vitals here)
    final blood  = _tryString(_bloodGroupCtrl.text);

    final contact = (e?.contact ?? const ContactInfo()).copyWith(phone: phone);
    final medical = (e?.medical ?? const MedicalProfile()).copyWith(bloodGroup: blood);

    // Build patient WITHOUT touching vitals
    final patient = (e ?? Patient(
      id: null,
      externalId: null,
      name: name,
      age: age,
      gender: gender,
      contact: contact,
      medical: medical,
      photoUrl: photo,
      notes: notes,
    )).copyWith(
      name: name,
      age: age,
      gender: gender,
      contact: contact,
      medical: medical,
      photoUrl: photo,
      notes: notes,
    );

    Navigator.of(context).pop(patient);
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        bottom: media.viewInsets.bottom + 16,
        top: 16,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text(
              widget.existing == null ? 'Add Patient' : 'Edit Patient',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 16),

            // Avatar + actions
            ValueListenableBuilder<String?>(
              valueListenable: _photoPath,
              builder: (context, path, _) {
                ImageProvider avatarImage;
                if (path != null && path.isNotEmpty) {
                  if (path.startsWith('http')) {
                    avatarImage = NetworkImage(path);
                  } else {
                    avatarImage = FileImage(File(path));
                  }
                } else {
                  // Fallback to your asset (ensure it's in pubspec.yaml)
                  avatarImage = const AssetImage('assets/images/patient.jpg');
                }
                return Column(children: [
                  CircleAvatar(radius: 40, backgroundImage: avatarImage),
                  const SizedBox(height: 8),
                  Wrap(spacing: 8, children: [
                    OutlinedButton.icon(
                      icon: const Icon(Icons.photo_library_outlined),
                      label: const Text('Gallery'),
                      onPressed: () => _pickImage(ImageSource.gallery),
                    ),
                    OutlinedButton.icon(
                      icon: const Icon(Icons.photo_camera_outlined),
                      label: const Text('Camera'),
                      onPressed: () => _pickImage(ImageSource.camera),
                    ),
                    if (path != null && path.isNotEmpty)
                      TextButton.icon(
                        icon: const Icon(Icons.close),
                        label: const Text('Remove'),
                        onPressed: () => _photoPath.value = null,
                      ),
                  ]),
                ]);
              },
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller: _nameCtrl,
              decoration: const InputDecoration(
                labelText: 'Full Name',
                prefixIcon: Icon(Icons.person_outline),
              ),
              textInputAction: TextInputAction.next,
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: 12),

            Row(children: [
              Expanded(
                child: TextFormField(
                  controller: _ageCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Age',
                    prefixIcon: Icon(Icons.calendar_month_outlined),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Required';
                    final n = int.tryParse(v);
                    if (n == null || n <= 0 || n > 120) return 'Enter a valid age';
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ValueListenableBuilder<String>(
                  valueListenable: _gender,
                  builder: (context, value, _) {
                    return DropdownButtonFormField<String>(
                      value: value,
                      items: const [
                        DropdownMenuItem(value: 'Male', child: Text('Male')),
                        DropdownMenuItem(value: 'Female', child: Text('Female')),
                        DropdownMenuItem(value: 'Other', child: Text('Other')),
                      ],
                      onChanged: (v) {
                        if (v != null) _gender.value = v;
                      },
                      decoration: const InputDecoration(labelText: 'Gender'),
                    );
                  },
                ),
              ),
            ]),
            const SizedBox(height: 12),

            TextFormField(
              controller: _phoneCtrl,
              decoration: const InputDecoration(
                labelText: 'Phone (optional)',
                prefixIcon: Icon(Icons.phone_outlined),
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 12),

            TextFormField(
              controller: _notesCtrl,
              decoration: const InputDecoration(
                labelText: 'Notes (optional)',
                prefixIcon: Icon(Icons.note_alt_outlined),
              ),
              minLines: 2,
              maxLines: 4,
            ),

            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _submit,
                child: Text(widget.existing == null ? 'Add' : 'Update'),
              ),
            ),
            const SizedBox(height: 8),
          ]),
        ),
      ),
    );
  }
}
