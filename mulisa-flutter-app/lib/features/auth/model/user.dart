import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id;
  final String name;
  final String token;

  const User({required this.id, required this.name, required this.token});
  @override
  List<Object?> get props => [id, name, token];

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json['id'].toString(),
    name: json['name'] ?? 'User',
    token: json['token'] ?? json['access_token'] ?? '',
  );
}
