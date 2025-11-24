import 'package:equatable/equatable.dart';
import 'dart:math' as math;

class Vitals extends Equatable {
  final int? heartRate;            // bpm
  final int? bpSystolic;           // mmHg
  final int? bpDiastolic;          // mmHg
  final double? heightCm;          // cm
  final double? weightKg;          // kg

  const Vitals({
    this.heartRate,
    this.bpSystolic,
    this.bpDiastolic,
    this.heightCm,
    this.weightKg,
  });

  Vitals copyWith({
    int? heartRate,
    int? bpSystolic,
    int? bpDiastolic,
    double? heightCm,
    double? weightKg,
  }) =>
      Vitals(
        heartRate: heartRate ?? this.heartRate,
        bpSystolic: bpSystolic ?? this.bpSystolic,
        bpDiastolic: bpDiastolic ?? this.bpDiastolic,
        heightCm: heightCm ?? this.heightCm,
        weightKg: weightKg ?? this.weightKg,
      );

  // ---- convenience ----
  double? get bmi {
    if (heightCm == null || weightKg == null || heightCm == 0) return null;
    final hM = heightCm! / 100.0;
    return weightKg! / (hM * hM);
  }

  String get bmiString => bmi == null ? '--' : bmi!.toStringAsFixed(1);
  String get heightString => heightCm == null ? '--' : '${heightCm!.round()} cm';
  String get weightStringKg => weightKg == null ? '--' : '${weightKg!.round()} kg';
  String get weightStringLbs =>
      weightKg == null ? '--' : '${(weightKg! * 2.20462).round()} lbs';

  String get bpString {
    if (bpSystolic == null || bpDiastolic == null) return '--';
    return '${bpSystolic}/${bpDiastolic} mmHg';
  }

  Map<String, Object?> toMap({String prefix = 'vital_'}) => {
    '${prefix}hr': heartRate,
    '${prefix}bpSys': bpSystolic,
    '${prefix}bpDia': bpDiastolic,
    '${prefix}heightCm': heightCm,
    '${prefix}weightKg': weightKg,
  };

  factory Vitals.fromMap(Map<String, Object?> map, {String prefix = 'vital_'}) =>
      Vitals(
        heartRate: map['${prefix}hr'] as int?,
        bpSystolic: map['${prefix}bpSys'] as int?,
        bpDiastolic: map['${prefix}bpDia'] as int?,
        heightCm: (map['${prefix}heightCm'] as num?)?.toDouble(),
        weightKg: (map['${prefix}weightKg'] as num?)?.toDouble(),
      );

  @override
  List<Object?> get props => [heartRate, bpSystolic, bpDiastolic, heightCm, weightKg];
}
