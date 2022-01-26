import 'dart:convert';

class Sport {
  final int id;
  final String name;

  Sport({
    required this.id,
    required this.name,
  });

  factory Sport.fromJson(Map<String, dynamic> json) {
    return Sport(
      id: json['id'] as int,
      name: json['name'] as String,
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'name': name,
    };
  }

  toJson() {
    return jsonEncode(toMap());
  }
}