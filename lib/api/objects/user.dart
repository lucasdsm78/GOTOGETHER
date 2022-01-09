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