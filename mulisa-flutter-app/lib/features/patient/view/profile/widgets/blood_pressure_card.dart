import 'package:flutter/material.dart';
import 'package:mulisa/features/patient/view/profile/widgets/text_theme_ext.dart';
import '../../../model/patient.dart';

class BloodPressureCard extends StatelessWidget {
  final Patient patient;
  final int? systolic;
  final int? diastolic;
  final DateTime? recordedAt;
  final bool loading;
  final String? errorText;
  final VoidCallback? onTap;

  const BloodPressureCard({
    super.key,
    required this.patient,
    this.systolic,
    this.diastolic,
    this.recordedAt,
    this.loading = false,
    this.errorText,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Use override values if provided, otherwise fall back to patient.vitals
    final v = patient.vitals;
    final effectiveSystolic = systolic ?? v.bpSystolic;
    final effectiveDiastolic = diastolic ?? v.bpDiastolic;

    // Determine BP status
    final bpStatus = _getBPStatus(effectiveSystolic, effectiveDiastolic);

    return InkWell(
      onTap: loading ? null : onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: _getBackgroundColor(theme, bpStatus, loading, errorText),
          borderRadius: BorderRadius.circular(16),
          border: errorText != null
              ? Border.all(
            color: theme.colorScheme.error.withOpacity(0.5),
            width: 1,
          )
              : null,
        ),
        child: Row(
          children: [
            _buildLeadingIcon(theme, bpStatus, loading, errorText),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Blood Pressure', style: theme.textStyleForBPTitle),
                  const SizedBox(height: 4),
                  if (loading)
                    _buildLoadingState(theme)
                  else if (errorText != null)
                    _buildErrorState(theme)
                  else
                    _buildBPValue(theme, effectiveSystolic, effectiveDiastolic, bpStatus),
                  if (recordedAt != null && !loading && errorText == null) ...[
                    const SizedBox(height: 4),
                    _buildTimestamp(theme, recordedAt!),
                  ],
                ],
              ),
            ),
            if (!loading && errorText == null)
              Icon(
                Icons.chevron_right,
                color: theme.colorScheme.onSurface.withOpacity(0.5),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeadingIcon(
      ThemeData theme,
      BPStatus status,
      bool loading,
      String? errorText,
      ) {
    if (loading) {
      return SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation(
            theme.colorScheme.primary,
          ),
        ),
      );
    }

    if (errorText != null) {
      return Icon(
        Icons.error_outline,
        color: theme.colorScheme.error,
      );
    }

    return Icon(
      _getIconForStatus(status),
      color: _getColorForStatus(theme, status),
    );
  }

  Widget _buildLoadingState(ThemeData theme) {
    return Text(
      'Loading...',
      style: theme.textTheme.titleMedium?.copyWith(
        color: theme.colorScheme.onSurface.withOpacity(0.5),
      ),
    );
  }

  Widget _buildErrorState(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Failed to load',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
            color: theme.colorScheme.error,
          ),
        ),
        if (errorText!.isNotEmpty) ...[
          const SizedBox(height: 2),
          Text(
            errorText!,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.error.withOpacity(0.8),
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ],
    );
  }

  Widget _buildBPValue(
      ThemeData theme,
      int? systolic,
      int? diastolic,
      BPStatus status,
      ) {
    final bpText = (systolic == null || diastolic == null)
        ? 'No data'
        : '$systolic/$diastolic mmHg';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          bpText,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
            color: _getColorForStatus(theme, status),
          ),
        ),
        if (systolic != null && diastolic != null && status != BPStatus.normal) ...[
          const SizedBox(height: 2),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: _getColorForStatus(theme, status).withOpacity(0.15),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              _getStatusText(status),
              style: theme.textTheme.bodySmall?.copyWith(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: _getColorForStatus(theme, status),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildTimestamp(ThemeData theme, DateTime recordedAt) {
    final now = DateTime.now();
    final difference = now.difference(recordedAt);

    String timeText;
    if (difference.inMinutes < 1) {
      timeText = 'Just now';
    } else if (difference.inMinutes < 60) {
      timeText = '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      timeText = '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      timeText = '${difference.inDays}d ago';
    } else {
      timeText = '${recordedAt.month}/${recordedAt.day}/${recordedAt.year}';
    }

    return Text(
      'Recorded $timeText',
      style: theme.textTheme.bodySmall?.copyWith(
        color: theme.colorScheme.onSurface.withOpacity(0.6),
        fontSize: 11,
      ),
    );
  }

  Color _getBackgroundColor(
      ThemeData theme,
      BPStatus status,
      bool loading,
      String? errorText,
      ) {
    if (errorText != null) {
      return theme.colorScheme.errorContainer.withOpacity(0.3);
    }

    if (loading) {
      return theme.colorScheme.surfaceContainerHighest.withOpacity(0.5);
    }

    switch (status) {
      case BPStatus.low:
      case BPStatus.high:
      case BPStatus.hypertensionStage1:
      case BPStatus.hypertensionStage2:
      case BPStatus.hypertensiveCrisis:
        return theme.colorScheme.errorContainer.withOpacity(0.2);
      case BPStatus.elevated:
        return theme.colorScheme.tertiaryContainer.withOpacity(0.3);
      case BPStatus.normal:
      case BPStatus.noData:
        return theme.colorScheme.surfaceContainerHighest.withOpacity(0.5);
    }
  }

  BPStatus _getBPStatus(int? systolic, int? diastolic) {
    if (systolic == null || diastolic == null) {
      return BPStatus.noData;
    }

    // Hypotension (Low BP)
    if (systolic < 90 || diastolic < 60) {
      return BPStatus.low;
    }

    // Normal BP
    if (systolic < 120 && diastolic < 80) {
      return BPStatus.normal;
    }

    // Elevated BP
    if (systolic >= 120 && systolic < 130 && diastolic < 80) {
      return BPStatus.elevated;
    }

    // Hypertension Stage 1
    if ((systolic >= 130 && systolic < 140) || (diastolic >= 80 && diastolic < 90)) {
      return BPStatus.hypertensionStage1;
    }

    // Hypertension Stage 2
    if ((systolic >= 140 && systolic < 180) || (diastolic >= 90 && diastolic < 120)) {
      return BPStatus.hypertensionStage2;
    }

    // Hypertensive Crisis
    if (systolic >= 180 || diastolic >= 120) {
      return BPStatus.hypertensiveCrisis;
    }

    return BPStatus.normal;
  }

  Color _getColorForStatus(ThemeData theme, BPStatus status) {
    switch (status) {
      case BPStatus.low:
      case BPStatus.hypertensionStage1:
      case BPStatus.hypertensionStage2:
      case BPStatus.hypertensiveCrisis:
        return theme.colorScheme.error;
      case BPStatus.elevated:
      case BPStatus.high:
        return theme.colorScheme.tertiary;
      case BPStatus.normal:
        return theme.colorScheme.primary;
      case BPStatus.noData:
        return theme.colorScheme.onSurface.withOpacity(0.5);
    }
  }

  IconData _getIconForStatus(BPStatus status) {
    switch (status) {
      case BPStatus.low:
        return Icons.arrow_downward;
      case BPStatus.normal:
        return Icons.favorite;
      case BPStatus.elevated:
      case BPStatus.high:
        return Icons.trending_up;
      case BPStatus.hypertensionStage1:
      case BPStatus.hypertensionStage2:
        return Icons.warning_amber_rounded;
      case BPStatus.hypertensiveCrisis:
        return Icons.emergency;
      case BPStatus.noData:
        return Icons.local_fire_department_rounded;
    }
  }

  String _getStatusText(BPStatus status) {
    switch (status) {
      case BPStatus.low:
        return 'LOW';
      case BPStatus.normal:
        return 'NORMAL';
      case BPStatus.elevated:
        return 'ELEVATED';
      case BPStatus.high:
        return 'HIGH';
      case BPStatus.hypertensionStage1:
        return 'STAGE 1 HYPERTENSION';
      case BPStatus.hypertensionStage2:
        return 'STAGE 2 HYPERTENSION';
      case BPStatus.hypertensiveCrisis:
        return 'CRISIS - SEEK CARE';
      case BPStatus.noData:
        return 'NO DATA';
    }
  }
}

enum BPStatus {
  noData,
  low,           // < 90/60
  normal,        // < 120/80
  elevated,      // 120-129/<80
  high,          // Used for general high BP
  hypertensionStage1,  // 130-139 or 80-89
  hypertensionStage2,  // 140-179 or 90-119
  hypertensiveCrisis,  // ≥180 or ≥120
}