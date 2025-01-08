import 'package:uuid/uuid.dart';

class User {
  final String id;
  final String email;
  final String hashPassword;
  final String fullName;
  final String username;

  User({
    String? id,
    required this.email,
    required this.hashPassword,
    required this.fullName,
    required this.username,
  }) : this.id = id ?? const Uuid().v4();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'hashPassword': hashPassword,
      'fullName': fullName,
      'username': username,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      email: map['email'],
      hashPassword: map['hashPassword'],
      fullName: map['fullName'],
      username: map['username'],
    );
  }
}
