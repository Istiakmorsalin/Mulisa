import 'package:flutter/material.dart';
import 'package:mulisa/features/patient/model/patient.dart';

/// Beautiful patient information display card
class PatientInfoCard extends StatelessWidget {
  final Patient patient;

  const PatientInfoCard({super.key, required this.patient});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section Title
            Text(
              'Patient Information',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 20),

            // Demographics
            _SectionHeader(
              icon: Icons.person_outline,
              title: 'Demographics',
            ),
            const SizedBox(height: 12),
            _InfoRow(
              icon: Icons.badge_outlined,
              label: 'Full Name',
              value: patient.name,
            ),
            _InfoRow(
              icon: Icons.cake_outlined,
              label: 'Age',
              value: '${patient.age} years',
            ),
            _InfoRow(
              icon: Icons.wc_outlined,
              label: 'Gender',
              value: _formatGender(patient.gender),
            ),

            const Divider(height: 32),

            // Contact Information
            _SectionHeader(
              icon: Icons.contact_phone_outlined,
              title: 'Contact Information',
            ),
            const SizedBox(height: 12),
            _InfoRow(
              icon: Icons.phone_outlined,
              label: 'Phone',
              value: patient.contact.phone ?? 'Not provided',
              isEmpty: patient.contact.phone == null,
            ),
            if (patient.contact.email != null)
              _InfoRow(
                icon: Icons.email_outlined,
                label: 'Email',
                value: patient.contact.email!,
              ),
            if (patient.contact.address != null)
              _InfoRow(
                icon: Icons.location_on_outlined,
                label: 'Address',
                value: patient.contact.address!,
              ),

            // Notes section if available
            if (patient.notes != null && patient.notes!.isNotEmpty) ...[
              const Divider(height: 32),
              _SectionHeader(
                icon: Icons.notes_outlined,
                title: 'Notes',
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: colorScheme.outline.withOpacity(0.2),
                  ),
                ),
                child: Text(
                  patient.notes!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatGender(String gender) {
    return gender[0].toUpperCase() + gender.substring(1).toLowerCase();
  }
}

/// Section header with icon
class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;

  const _SectionHeader({
    required this.icon,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: theme.colorScheme.primary,
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.primary,
          ),
        ),
      ],
    );
  }
}

/// Information row with icon, label, and value
class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isEmpty;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.isEmpty = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isEmpty
                  ? colorScheme.surfaceContainerHighest.withOpacity(0.5)
                  : colorScheme.primaryContainer.withOpacity(0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 18,
              color: isEmpty
                  ? colorScheme.onSurface.withOpacity(0.4)
                  : colorScheme.primary,
            ),
          ),
          const SizedBox(width: 12),

          // Label and Value
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface.withOpacity(0.6),
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: isEmpty ? FontWeight.normal : FontWeight.w600,
                    color: isEmpty
                        ? colorScheme.onSurface.withOpacity(0.4)
                        : colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}