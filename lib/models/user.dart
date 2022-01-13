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
      id: json['id'],
      username: json['username'],
      mail: json['mail'],
      role: json['role'],
    );
  }
}

class UserRequest {
  final String username;
  final String mail;
  final String password;

  UserRequest({
    required this.username,
    required this.mail,
    required this.password,
  });

  factory UserRequest.fromJson(Map<String, dynamic> json) {
    return UserRequest(
      username: json['username'],
      mail: json['mail'],
      password: json['password'],
    );
  }
  factory UserRequest.fromString(String username, String mail, String password) {
    return UserRequest(
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