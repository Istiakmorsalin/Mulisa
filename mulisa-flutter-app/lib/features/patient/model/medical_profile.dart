import 'package:equatable/equatable.dart';

class MedicalProfile extends Equatable {
  final String? bloodGroup;          // A+, O-, …
  final String? allergies;
  final String? medicalHistory;
  final String? currentMedications;

  const MedicalProfile({
    this.bloodGroup,
    this.allergies,
    this.medicalHistory,
    this.currentMedications,
  });

  MedicalProfile copyWith({
    String? bloodGroup,
    String? allergies,
    String? medicalHistory,
    String? currentMedications,
  }) =>
      MedicalProfile(
        bloodGroup: bloodGroup ?? this.bloodGroup,
        allergies: allergies ?? this.allergies,
        medicalHistory: medicalHistory ?? this.medicalHistory,
        currentMedications: currentMedications ?? this.currentMedications,
      );

  Map<String, Object?> toMap({String prefix = 'med_'}) => {
    '${prefix}bloodGroup': bloodGroup,
    '${prefix}allergies': allergies,
    '${prefix}history': medicalHistory,
    '${prefix}currentMeds': currentMedications,
  };

  factory MedicalProfile.fromMap(Map<String, Object?> map, {String prefix = 'med_'}) =>
      MedicalProfile(
        bloodGroup: map['${prefix}bloodGroup'] as String?,
        allergies: map['${prefix}allergies'] as String?,
        medicalHistory: map['${prefix}history'] as String?,
        currentMedications: map['${prefix}currentMeds'] as String?,
      );

  @override
  List<Object?> get props => [bloodGroup, allergies, medicalHistory, currentMedications];
}
