import 'package:flutter/material.dart';

import '../../../model/patient.dart';

class HeaderOverview extends StatelessWidget {
  final Patient patient;
  const HeaderOverview({super.key, required this.patient});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.35),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 26,
              backgroundImage:
              patient.photoUrl != null ? NetworkImage(patient.photoUrl!) : null,
              child: patient.photoUrl == null
                  ? Text(
                patient.name.isNotEmpty ? patient.name[0].toUpperCase() : '?',
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 20),
              )
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 6),
                  Text(
                    '${patient.name}  •  ${patient.gender}, ${patient.age}',
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 8),

                  // FIX: Use Row + Flexible so a long chip (e.g., phone) can shrink with ellipsis.
                  Row(
                    children: [
                      _Chip(
                        text:
                        'ID: ${patient.externalId ?? (patient.id?.toString() ?? '--')}',
                      ),
                      const SizedBox(width: 6),
                      if (patient.contact.phone != null)
                        Flexible(
                          child: _Chip(
                            text: patient.contact.phone!,
                            ellipsize: true,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String text;
  final bool ellipsize;
  const _Chip({required this.text, this.ellipsize = false});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.secondaryContainer.withOpacity(.6),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: theme.textTheme.labelMedium,
        maxLines: ellipsize ? 1 : null,
        softWrap: !ellipsize,
        overflow: ellipsize ? TextOverflow.ellipsis : TextOverflow.visible,
      ),
    );
  }
}
