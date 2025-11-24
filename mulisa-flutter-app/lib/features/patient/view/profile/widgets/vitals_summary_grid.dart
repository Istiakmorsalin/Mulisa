import 'package:flutter/material.dart';
import 'package:mulisa/features/patient/model/patient.dart';
import 'package:mulisa/features/vitals/vitals_extensions.dart';

class VitalsSummaryGrid extends StatelessWidget {
  final Patient patient;
  final Map<String, dynamic>? vital;
  final bool isLoading;
  final bool hasError;

  const VitalsSummaryGrid({
    super.key,
    required this.patient,
    this.vital,
    this.isLoading = false,
    this.hasError = false,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: [
        _VitalTile(
          title: 'SpO₂',
          value: vital?.spo2?.toString(),
          unit: '%',
          icon: Icons.air,
          isNormal: _isSpO2Normal(vital?.spo2),
          isLoading: isLoading,
          hasError: hasError,
        ),
        _VitalTile(
          title: 'Temperature',
          value: vital?.temperature?.toStringAsFixed(1),
          unit: '°C',
          icon: Icons.thermostat,
          isNormal: _isTempNormal(vital?.temperature),
          isLoading: isLoading,
          hasError: hasError,
        ),
        _VitalTile(
          title: 'Respiratory Rate',
          value: vital?.respiratoryRate?.toString(),
          unit: 'br/min',
          icon: Icons.waves,
          isNormal: _isRespRateNormal(vital?.respiratoryRate),
          isLoading: isLoading,
          hasError: hasError,
        ),
        _VitalTile(
          title: 'BMI',
          value: _calculateBMI(patient),
          unit: '',
          icon: Icons.monitor_weight_outlined,
          isNormal: _isBMINormal(_calculateBMIValue(patient)),
          isLoading: false, // BMI calculated from patient data
          hasError: false,
        ),
      ],
    );
  }

  bool _isSpO2Normal(int? spo2) {
    if (spo2 == null) return true;
    return spo2 >= 95 && spo2 <= 100;
  }

  bool _isTempNormal(double? temp) {
    if (temp == null) return true;
    return temp >= 36.1 && temp <= 37.2;
  }

  bool _isRespRateNormal(int? rate) {
    if (rate == null) return true;
    // Normal adult respiratory rate: 12-20 breaths per minute
    return rate >= 12 && rate <= 20;
  }

  bool _isBMINormal(double? bmi) {
    if (bmi == null) return true;
    return bmi >= 18.5 && bmi < 25.0;
  }

  String? _calculateBMI(Patient patient) {
    final bmi = _calculateBMIValue(patient);
    return bmi?.toStringAsFixed(1);
  }

  double? _calculateBMIValue(Patient patient) {
    // First try to get from vitals (latest data)
    if (vital != null) {
      final h = vital?.heightCm;
      final w = vital?.weightKg;
      if (h != null && w != null && h > 0) {
        final heightM = h / 100.0;
        return w / (heightM * heightM);
      }
    }

    // Fallback to patient data if available
    // Assuming Patient model might have these fields
    // If not, return null and it will show "--"
    return null;
  }
}

class _VitalTile extends StatelessWidget {
  final String title;
  final String? value;
  final String unit;
  final IconData icon;
  final bool isNormal;
  final bool isLoading;
  final bool hasError;

  const _VitalTile({
    required this.title,
    required this.value,
    required this.unit,
    required this.icon,
    this.isNormal = true,
    this.isLoading = false,
    this.hasError = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Determine colors based on state
    Color backgroundColor;
    Color foregroundColor;

    if (hasError) {
      backgroundColor = colorScheme.errorContainer;
      foregroundColor = colorScheme.onErrorContainer;
    } else if (value != null && !isNormal) {
      backgroundColor = colorScheme.errorContainer.withOpacity(0.5);
      foregroundColor = colorScheme.onErrorContainer;
    } else {
      backgroundColor = colorScheme.surfaceContainerHighest;
      foregroundColor = colorScheme.onSurface;
    }

    return Card(
      elevation: 1,
      color: backgroundColor,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  color: foregroundColor.withOpacity(0.7),
                  size: 20,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    title,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: foregroundColor.withOpacity(0.8),
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (!isNormal && value != null)
                  Icon(
                    Icons.warning_amber_rounded,
                    size: 16,
                    color: colorScheme.error,
                  ),
              ],
            ),
            const SizedBox(height: 8),
            if (isLoading)
              Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation(foregroundColor),
                  ),
                ),
              )
            else if (hasError)
              Text(
                'Error',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: foregroundColor,
                ),
              )
            else if (value != null)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      value!,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        color: foregroundColor,
                        fontWeight: FontWeight.bold,
                        height: 1,
                      ),
                    ),
                    if (unit.isNotEmpty) ...[
                      const SizedBox(width: 4),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4.0),
                        child: Text(
                          unit,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: foregroundColor.withOpacity(0.7),
                          ),
                        ),
                      ),
                    ],
                  ],
                )
              else
                Text(
                  '--',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: foregroundColor.withOpacity(0.5),
                    fontWeight: FontWeight.bold,
                  ),
                ),
          ],
        ),
      ),
    );
  }
}