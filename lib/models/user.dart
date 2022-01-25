import 'dart:convert';

class User {
  final int? id;
  final String username;
  final String mail;
  final String role;

  User({
    this.id,
    required this.username,
    required this.mail,
    required this.role,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int,
      username: json['username'] as String,
      mail: json['mail'] as String,
      role: json['role'] as String,
    );
  }

  toJson() {
    return jsonEncode({
      "id": id,
      "username": username,
      "mail": mail,
      "role": role,
    });
  }
}