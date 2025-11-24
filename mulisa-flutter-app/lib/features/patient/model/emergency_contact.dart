import 'package:equatable/equatable.dart';

class EmergencyContact extends Equatable {
  final String? name;
  final String? phone;
  final String? relationship;

  const EmergencyContact({this.name, this.phone, this.relationship});

  bool get isEmpty => name == null && phone == null && relationship == null;

  EmergencyContact copyWith({String? name, String? phone, String? relationship}) =>
      EmergencyContact(
        name: name ?? this.name,
        phone: phone ?? this.phone,
        relationship: relationship ?? this.relationship,
      );

  Map<String, Object?> toMap({String prefix = 'emc_'}) => {
    '${prefix}name': name,
    '${prefix}phone': phone,
    '${prefix}relationship': relationship,
  };

  factory EmergencyContact.fromMap(Map<String, Object?> map, {String prefix = 'emc_'}) =>
      EmergencyContact(
        name: map['${prefix}name'] as String?,
        phone: map['${prefix}phone'] as String?,
        relationship: map['${prefix}relationship'] as String?,
      );

  @override
  List<Object?> get props => [name, phone, relationship];
}
