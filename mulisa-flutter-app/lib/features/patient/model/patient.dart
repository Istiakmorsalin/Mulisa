import 'package:equatable/equatable.dart';
import 'contact_info.dart';
import 'medical_profile.dart';
import 'emergency_contact.dart';
import 'vitals.dart';

class Patient extends Equatable {
  final int? id; // Local or API id
  final String? externalId;
  final String name;
  final int age;
  final String gender;
  final String? photoUrl;

  final ContactInfo contact;
  final MedicalProfile medical;
  final EmergencyContact? emergency;
  final Vitals vitals;
  final String? notes;

  const Patient({
    this.id,
    this.externalId,
    required this.name,
    required this.age,
    required this.gender,
    this.photoUrl,
    this.contact = const ContactInfo(),
    this.medical = const MedicalProfile(),
    this.emergency,
    this.vitals = const Vitals(),
    this.notes,
  });

  Patient copyWith({
    int? id,
    String? externalId,
    String? name,
    int? age,
    String? gender,
    String? photoUrl,
    ContactInfo? contact,
    MedicalProfile? medical,
    EmergencyContact? emergency,
    Vitals? vitals,
    String? notes,
  }) =>
      Patient(
        id: id ?? this.id,
        externalId: externalId ?? this.externalId,
        name: name ?? this.name,
        age: age ?? this.age,
        gender: gender ?? this.gender,
        photoUrl: photoUrl ?? this.photoUrl,
        contact: contact ?? this.contact,
        medical: medical ?? this.medical,
        emergency: emergency ?? this.emergency,
        vitals: vitals ?? this.vitals,
        notes: notes ?? this.notes,
      );

  @override
  List<Object?> get props => [
    id,
    externalId,
    name,
    age,
    gender,
    photoUrl,
    contact,
    medical,
    emergency,
    vitals,
    notes,
  ];

  // ========================================================
  // 🧩 Local Database Mapping (already used in AppDatabase)
  // ========================================================
  Map<String, Object?> toDbMap() => {
    'id': id,
    'externalId': externalId,
    'name': name,
    'age': age,
    'gender': gender,
    'photoUrl': photoUrl,
    ...contact.toMap(prefix: 'contact_'),
    ...medical.toMap(prefix: 'med_'),
    ...vitals.toMap(prefix: 'vital_'),
    ..._emergencyToMap(),
    'notes': notes,
  };

  Map<String, Object?> _emergencyToMap() {
    final e = emergency ?? const EmergencyContact();
    return e.toMap(prefix: 'emc_');
  }

  factory Patient.fromDbMap(Map<String, Object?> map) => Patient(
    id: map['id'] as int?,
    externalId: map['externalId'] as String?,
    name: map['name'] as String,
    age: (map['age'] as num).toInt(),
    gender: map['gender'] as String,
    photoUrl: map['photoUrl'] as String?,
    contact: ContactInfo.fromMap(map, prefix: 'contact_'),
    medical: MedicalProfile.fromMap(map, prefix: 'med_'),
    emergency: EmergencyContact.fromMap(map, prefix: 'emc_'),
    vitals: Vitals.fromMap(map, prefix: 'vital_'),
    notes: map['notes'] as String?,
  );

  // ========================================================
  // 🌐 API Serialization (for Django REST API integration)
  // ========================================================
  factory Patient.fromJson(Map<String, dynamic> j) {
    String? _s(List<String> keys) {
      for (final k in keys) {
        final v = j[k];
        if (v is String && v.isNotEmpty) return v;
      }
      return null;
    }

    int _i(List<String> keys, [int def = 0]) {
      for (final k in keys) {
        final v = j[k];
        if (v is int) return v;
        if (v is num) return v.toInt();
        if (v is String) {
          final p = int.tryParse(v);
          if (p != null) return p;
        }
      }
      return def;
    }

    // ✅ Parse nested contact object
    ContactInfo _parseContact() {
      final contactData = j['contact'];
      if (contactData is Map<String, dynamic>) {
        return ContactInfo(
          phone: contactData['phone'] as String?,
          email: contactData['email'] as String?,
          address: contactData['address'] as String?,
        );
      }
      return const ContactInfo();
    }

    // ✅ Parse nested medical object
    MedicalProfile _parseMedical() {
      final medicalData = j['medical'];
      if (medicalData is Map<String, dynamic>) {
        return MedicalProfile(
          bloodGroup: medicalData['bloodGroup'] as String?,
          allergies: medicalData['allergies'] as String?,
          medicalHistory: medicalData['medicalHistory'] as String?,
          currentMedications: medicalData['currentMedications'] as String?,
        );
      }
      return const MedicalProfile();
    }

    // ✅ Parse nested emergency object
    EmergencyContact? _parseEmergency() {
      final emergencyData = j['emergency'];
      if (emergencyData is Map<String, dynamic>) {
        return EmergencyContact(
          name: emergencyData['name'] as String?,
          phone: emergencyData['phone'] as String?,
          relationship: emergencyData['relationship'] as String?,
        );
      }
      return null;
    }

    return Patient(
      id: j['id'] is int ? j['id'] as int : int.tryParse('${j['id']}'),
      externalId: _s(['externalId', 'external_id']),
      name: _s(['name', 'full_name', 'patient_name']) ?? 'Unknown',
      age: _i(['age']),
      gender: _s(['gender', 'sex']) ?? 'Unknown',
      photoUrl: _s(['photoUrl', 'photo_url', 'avatar', 'image']),
      notes: _s(['notes', 'note']),
      contact: _parseContact(),      // ✅ Use parsed contact
      medical: _parseMedical(),      // ✅ Use parsed medical
      emergency: _parseEmergency(),
      vitals: const Vitals(),
    );
  }

  Map<String, dynamic> toJson() {

    // Helper to check if it's a valid URL
    bool isValidUrl(String? url) {
      if (url == null || url.isEmpty) return false;
      return url.startsWith('http://') || url.startsWith('https://');
    }

    return {
      if (id != null) 'id': id,
      'externalId': externalId,
      'name': name,
      'age': age,
      'gender': gender,
      // ✅ Only send photoUrl if it's a valid URL, otherwise send null
      'photoUrl': isValidUrl(photoUrl) ? photoUrl : null,
      'notes': notes,

      'contact': {
        'phone': contact.phone,
        'email': contact.email,
        'address': contact.address,
      },

      // If you want to send other nested data:
      'medical': {
        'bloodGroup': medical.bloodGroup,
        'allergies': medical.allergies,
        'medicalHistory': medical.medicalHistory,
        'currentMedications': medical.currentMedications,
      },

      'emergency': emergency != null ? {
        'name': emergency!.name,
        'phone': emergency!.phone,
        'relationship': emergency!.relationship,
      } : {},

      // Don't send vitals on patient update - handle via separate endpoint
    };
  }
}
