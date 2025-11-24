import 'package:equatable/equatable.dart';

class ContactInfo extends Equatable {
  final String? phone;
  final String? email;
  final String? address;

  const ContactInfo({this.phone, this.email, this.address});

  ContactInfo copyWith({String? phone, String? email, String? address}) =>
      ContactInfo(
        phone: phone ?? this.phone,
        email: email ?? this.email,
        address: address ?? this.address,
      );

  Map<String, Object?> toMap({String prefix = 'contact_'}) => {
    '${prefix}phone': phone,
    '${prefix}email': email,
    '${prefix}address': address,
  };

  factory ContactInfo.fromMap(Map<String, Object?> map, {String prefix = 'contact_'}) =>
      ContactInfo(
        phone: map['${prefix}phone'] as String?,
        email: map['${prefix}email'] as String?,
        address: map['${prefix}address'] as String?,
      );

  @override
  List<Object?> get props => [phone, email, address];
}
