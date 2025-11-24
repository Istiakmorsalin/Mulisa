import 'package:flutter/material.dart';

class DemographicsSection extends StatelessWidget {
  final bool isEditing;
  final TextEditingController nameCtrl;
  final TextEditingController ageCtrl;
  final String gender;
  final ValueChanged<String> onGenderChanged;

  const DemographicsSection({
    super.key,
    required this.isEditing,
    required this.nameCtrl,
    required this.ageCtrl,
    required this.gender,
    required this.onGenderChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Demographics', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        TextFormField(
          controller: nameCtrl,
          enabled: isEditing,
          decoration: const InputDecoration(labelText: 'Full Name', prefixIcon: Icon(Icons.person_outline)),
          validator: (v) => (v == null || v.trim().isEmpty) ? 'Name is required' : null,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: ageCtrl,
                enabled: isEditing,
                decoration: const InputDecoration(labelText: 'Age', prefixIcon: Icon(Icons.calendar_month_outlined)),
                keyboardType: TextInputType.number,
                validator: (v) => (v == null || int.tryParse(v) == null) ? 'Enter a valid age' : null,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: DropdownButtonFormField<String>(
                value: gender,
                items: const [
                  DropdownMenuItem(value: 'Male', child: Text('Male')),
                  DropdownMenuItem(value: 'Female', child: Text('Female')),
                  DropdownMenuItem(value: 'Other', child: Text('Other')),
                ],
                onChanged: isEditing ? (v) { if (v != null) onGenderChanged(v); } : null,
                decoration: const InputDecoration(labelText: 'Gender', prefixIcon: Icon(Icons.wc_outlined)),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class ContactsSection extends StatelessWidget {
  final bool isEditing;
  final TextEditingController phoneCtrl;

  const ContactsSection({
    super.key,
    required this.isEditing,
    required this.phoneCtrl,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Contacts', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        TextFormField(
          controller: phoneCtrl,
          enabled: isEditing,
          decoration: const InputDecoration(labelText: 'Phone', prefixIcon: Icon(Icons.call_outlined)),
          keyboardType: TextInputType.phone,
        ),
      ],
    );
  }
}

class NotesSection extends StatelessWidget {
  final bool isEditing;
  final TextEditingController notesCtrl;

  const NotesSection({
    super.key,
    required this.isEditing,
    required this.notesCtrl,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Notes', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        TextFormField(
          controller: notesCtrl,
          enabled: isEditing,
          minLines: 3,
          maxLines: 5,
          decoration: const InputDecoration(
            labelText: 'Care notes / allergies / history',
            alignLabelWithHint: true,
            prefixIcon: Icon(Icons.notes_outlined),
          ),
        ),
      ],
    );
  }
}
