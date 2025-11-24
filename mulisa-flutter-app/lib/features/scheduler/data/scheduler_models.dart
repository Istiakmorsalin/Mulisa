// lib/features/scheduler/data/scheduler_models.dart


class ProviderSummary {
  final String id;
  final String name;
  final String specialty;
  final String phone;
  final String? email;
  final List<LocationModel> locations;

  ProviderSummary({
    required this.id,
    required this.name,
    required this.specialty,
    required this.phone,
    this.email,
    required this.locations,
  });

  factory ProviderSummary.fromJson(Map<String, dynamic> json) {
    return ProviderSummary(
      id: json['id'].toString(),
      name: json['name'] as String,
      specialty: json['specialty'] as String,
      phone: (json['phone'] as String?) ?? '',
      email: json['email'] as String?,
      locations: (json['locations'] as List<dynamic>?)
          ?.map((e) => LocationModel.fromJson(e as Map<String, dynamic>))
          .toList() ??
          [],
    );
  }
}

class LocationModel {
  final String id;
  final String name;
  final String address;
  final String city;
  final String state;
  final String zipCode;
  final String? phone;

  LocationModel({
    required this.id,
    required this.name,
    required this.address,
    required this.city,
    required this.state,
    required this.zipCode,
    this.phone,
  });

  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      id: json['id'].toString(),
      name: json['name'] as String,
      address: json['address'] as String,
      city: json['city'] as String,
      state: json['state'] as String,
      zipCode: json['zip_code'] as String,
      phone: json['phone'] as String?,
    );
  }
}

class AppointmentTypeModel {
  final String id;
  final String name;
  final int durationMin;
  final bool allowPatientBooking;
  final String? description;

  AppointmentTypeModel({
    required this.id,
    required this.name,
    required this.durationMin,
    required this.allowPatientBooking,
    this.description,
  });

  factory AppointmentTypeModel.fromJson(Map<String, dynamic> json) {
    return AppointmentTypeModel(
      id: json['id'].toString(),
      name: json['name'] as String,
      durationMin: json['duration_minutes'] as int,
      allowPatientBooking: json['allow_patient_booking'] as bool,
      description: json['description'] as String?,
    );
  }
}

class AppointmentBooking {
  final String patientId;
  final String providerId;
  final String appointmentTypeId;
  final String locationId;
  final DateTime appointmentDateTime;
  final String? notes;

  AppointmentBooking({
    required this.patientId,
    required this.providerId,
    required this.appointmentTypeId,
    required this.locationId,
    required this.appointmentDateTime,
    this.notes,
  });

  Map<String, dynamic> toJson() {
    // Format date as YYYY-MM-DD
    final dateStr = '${appointmentDateTime.year.toString().padLeft(4, '0')}-'
        '${appointmentDateTime.month.toString().padLeft(2, '0')}-'
        '${appointmentDateTime.day.toString().padLeft(2, '0')}';

    // Format time as HH:MM:SS
    final timeStr = '${appointmentDateTime.hour.toString().padLeft(2, '0')}:'
        '${appointmentDateTime.minute.toString().padLeft(2, '0')}:00';

    print('DEBUG - Building toJson:');
    print('  patientId: $patientId (${patientId.runtimeType})');
    print('  providerId: $providerId (${providerId.runtimeType})');
    print('  appointmentTypeId: $appointmentTypeId (${appointmentTypeId.runtimeType})');
    print('  locationId: $locationId (${locationId.runtimeType})');
    print('  dateStr: $dateStr');
    print('  timeStr: $timeStr');
    print('  notes: $notes (${notes.runtimeType})');

    final result = {
      'patient': patientId,
      'provider': providerId,
      'appointment_type': appointmentTypeId,
      'location': locationId,
      'appointment_date': dateStr,
      'appointment_time': timeStr,
      'notes': notes ?? '',
    };

    print('DEBUG - Final JSON: $result');
    return result;
  }
}

class AppointmentModel {
  final String id;
  final String patient;
  final String provider;
  final String appointmentType;
  final String location;
  final DateTime appointmentDate;
  final String appointmentTime;
  final String status;
  final String? notes;
  final String providerName;
  final String providerSpecialty;
  final String typeName;
  final String locationName;
  final String locationAddress;
  final String patientName;
  final DateTime createdAt;
  final DateTime updatedAt;

  AppointmentModel({
    required this.id,
    required this.patient,
    required this.provider,
    required this.appointmentType,
    required this.location,
    required this.appointmentDate,
    required this.appointmentTime,
    required this.status,
    this.notes,
    required this.providerName,
    required this.providerSpecialty,
    required this.typeName,
    required this.locationName,
    required this.locationAddress,
    required this.patientName,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AppointmentModel.fromJson(Map<String, dynamic> json) {
    return AppointmentModel(
      id: json['id'].toString(),
      patient: json['patient'].toString(),
      provider: json['provider'].toString(),
      appointmentType: json['appointment_type'].toString(),
      location: json['location'].toString(),
      appointmentDate: DateTime.parse(json['appointment_date']),
      appointmentTime: json['appointment_time'] as String,
      status: json['status'] as String,
      notes: json['notes'] as String?,
      providerName: json['provider_name'] as String,
      providerSpecialty: json['provider_specialty'] as String,
      typeName: json['type_name'] as String,
      locationName: json['location_name'] as String,
      locationAddress: json['location_address'] as String,
      patientName: json['patient_name'] as String,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  // Helper to get full DateTime
  DateTime get fullDateTime {
    final timeParts = appointmentTime.split(':');
    return DateTime(
      appointmentDate.year,
      appointmentDate.month,
      appointmentDate.day,
      int.parse(timeParts[0]),
      int.parse(timeParts[1]),
    );
  }

  // Helper to get time components (hour, minute) - No TimeOfDay dependency
  (int hour, int minute) get timeComponents {
    final timeParts = appointmentTime.split(':');
    return (int.parse(timeParts[0]), int.parse(timeParts[1]));
  }
}