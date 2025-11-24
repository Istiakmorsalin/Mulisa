// lib/features/vitals/extensions/vitals_extensions.dart
// Helper extensions to safely extract vital values from Map<String, dynamic>

extension VitalsExtension on Map<String, dynamic>? {
  // Handle both int and double from API
  int? get heartRate {
    final val = this?['heart_rate'];
    if (val == null) return null;
    if (val is int) return val;
    if (val is double) return val.toInt();
    return int.tryParse(val.toString());
  }

  int? get systolic {
    final val = this?['bp_sys'];
    if (val == null) return null;
    if (val is int) return val;
    if (val is double) return val.toInt();
    return int.tryParse(val.toString());
  }

  int? get diastolic {
    final val = this?['bp_dia'];
    if (val == null) return null;
    if (val is int) return val;
    if (val is double) return val.toInt();
    return int.tryParse(val.toString());
  }

  int? get spo2 {
    final val = this?['spo2'];
    if (val == null) return null;
    if (val is int) return val;
    if (val is double) return val.toInt();
    return int.tryParse(val.toString());
  }

  double? get temperature {
    final val = this?['temperature_c'];
    if (val == null) return null;
    if (val is double) return val;
    if (val is int) return val.toDouble();
    return double.tryParse(val.toString());
  }

  int? get respiratoryRate {
    final val = this?['respiratory_rate'];
    if (val == null) return null;
    if (val is int) return val;
    if (val is double) return val.toInt();
    return int.tryParse(val.toString());
  }

  int? get heightCm {
    final val = this?['height_cm'];
    if (val == null) return null;
    if (val is int) return val;
    if (val is double) return val.toInt();
    return int.tryParse(val.toString());
  }

  int? get weightKg {
    final val = this?['weight_kg'];
    if (val == null) return null;
    if (val is int) return val;
    if (val is double) return val.toInt();
    return int.tryParse(val.toString());
  }

  DateTime? get recordedAt {
    final val = this?['recorded_at'];
    return val != null ? DateTime.tryParse(val.toString()) : null;
  }

  DateTime? get createdAt {
    final val = this?['created_at'];
    return val != null ? DateTime.tryParse(val.toString()) : null;
  }

  // Calculate BMI if height and weight are available
  double? get bmi {
    final h = this?.heightCm;
    final w = this?.weightKg;
    if (h == null || w == null || h == 0) return null;
    final heightM = h / 100.0;
    return w / (heightM * heightM);
  }
}