import 'package:flutter/material.dart';

class HeartRateCard extends StatelessWidget {
  final int? bpm;
  final bool isNormal;
  final String? subtitle;
  final String? errorMessage;

  const HeartRateCard({
    super.key,
    required this.bpm,
    this.isNormal = true,
    this.subtitle,
    this.errorMessage,
  });

  const HeartRateCard.loading({super.key})
      : bpm = null,
        isNormal = true,
        subtitle = 'Loading...',
        errorMessage = null;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Determine card color based on state
    Color cardColor;
    Color textColor;
    IconData icon;

    if (errorMessage != null) {
      cardColor = colorScheme.errorContainer;
      textColor = colorScheme.onErrorContainer;
      icon = Icons.error_outline;
    } else if (bpm == null) {
      cardColor = colorScheme.surfaceContainerHighest;
      textColor = colorScheme.onSurface;
      icon = Icons.favorite_border;
    } else if (!isNormal) {
      cardColor = colorScheme.errorContainer;
      textColor = colorScheme.onErrorContainer;
      icon = Icons.warning_amber_rounded;
    } else {
      cardColor = colorScheme.primaryContainer;
      textColor = colorScheme.onPrimaryContainer;
      icon = Icons.favorite;
    }

    return Card(
      elevation: 2,
      color: cardColor,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  color: textColor,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Text(
                  'Heart Rate',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: textColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                if (bpm == null && errorMessage == null)
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation(textColor),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            if (bpm != null)
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '$bpm',
                    style: theme.textTheme.displayLarge?.copyWith(
                      color: textColor,
                      fontWeight: FontWeight.bold,
                      height: 1,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Text(
                      'BPM',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: textColor.withOpacity(0.8),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            if (subtitle != null || errorMessage != null) ...[
              const SizedBox(height: 8),
              Text(
                errorMessage ?? subtitle!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: textColor.withOpacity(0.9),
                ),
              ),
            ],
            if (bpm != null && !isNormal) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: colorScheme.error.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: colorScheme.error.withOpacity(0.5),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 14,
                      color: colorScheme.error,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _getHeartRateStatus(bpm),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.error,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _getHeartRateStatus(int? bpm) {
    if (bpm == null) return 'No data';
    if (bpm < 60) return 'Below normal (Bradycardia)';
    if (bpm > 100) return 'Above normal (Tachycardia)';
    return 'Normal';
  }
}