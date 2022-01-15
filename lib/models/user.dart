import 'dart:convert';

class User {
  final int id;
  final String username;
  final String mail;
  final String role;

  User({
    required this.id,
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
}

class UserCreate {
  final String username;
  final String mail;
  final String password;

  UserCreate({
    required this.username,
    required this.mail,
    required this.password,
  });

  factory UserCreate.fromJson(Map<String, dynamic> json) {
    return UserCreate(
      username: json['username'] as String,
      mail: json['mail'] as String,
      password: json['password'] as String,
    );
  }
  factory UserCreate.fromString(String username, String mail, String password) {
    return UserCreate(
      username: username,
      mail: mail,
      password: password,
    );
  }

  asJson(){
    return jsonEncode(<String, String>{
      'username': username,
      'mail' : mail,
      'password' : password
    });
  }
}