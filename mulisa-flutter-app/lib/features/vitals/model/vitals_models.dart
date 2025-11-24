
import 'package:mulisa/features/patient/model/patient.dart';

class VitalInput {
  final int heartRate;
  final int bpSys;
  final int bpDia;
  final int heightCm;
  final int weightKg;
  final double temperatureC;
  final int spo2;
  final int respiratoryRate;

  VitalInput({
    required this.heartRate,
    required this.bpSys,
    required this.bpDia,
    required this.heightCm,
    required this.weightKg,
    required this.temperatureC,
    required this.spo2,
    required this.respiratoryRate,
  });

  Map<String, dynamic> toJson() => {
    "heart_rate": heartRate,
    "bp_sys": bpSys,
    "bp_dia": bpDia,
    "height_cm": heightCm,
    "weight_kg": weightKg,
    "temperature_c": temperatureC,
    "spo2": spo2,
    "respiratory_rate": respiratoryRate,
  };
}

/// If you want to render a table/list after save or from GET:
class VitalItem {
  final int id;
  final int heartRate;
  final int bpSys;
  final int bpDia;
  final int heightCm;
  final int weightKg;
  final double temperatureC;
  final int spo2;
  final int respiratoryRate;
  final DateTime? recordedAt; // if backend includes it
  final DateTime? createdAt;  // if backend includes it

  VitalItem({
    required this.id,
    required this.heartRate,
    required this.bpSys,
    required this.bpDia,
    required this.heightCm,
    required this.weightKg,
    required this.temperatureC,
    required this.spo2,
    required this.respiratoryRate,
    this.recordedAt,
    this.createdAt,
  });

  factory VitalItem.fromJson(Map<String, dynamic> j) => VitalItem(
    id: j["id"] as int,
    heartRate: j["heart_rate"] ?? 0,
    bpSys: j["bp_sys"] ?? 0,
    bpDia: j["bp_dia"] ?? 0,
    heightCm: j["height_cm"] ?? 0,
    weightKg: j["weight_kg"] ?? 0,
    temperatureC: (j["temperature_c"] is int)
        ? (j["temperature_c"] as int).toDouble()
        : (j["temperature_c"] ?? 0.0) as double,
    spo2: j["spo2"] ?? 0,
    respiratoryRate: j["respiratory_rate"] ?? 0,
    recordedAt:
    j["recorded_at"] != null ? DateTime.tryParse(j["recorded_at"]) : null,
    createdAt:
    j["created_at"] != null ? DateTime.tryParse(j["created_at"]) : null,
  );
}
