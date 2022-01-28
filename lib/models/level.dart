import 'dart:convert';
import 'package:go_together/helper/map_extension.dart';

class Level {
  final int id;
  final String name;

  Level({
    required this.id,
    required this.name,
  });

  factory Level.fromJson(Map<String, dynamic> json) {
    return Level(
      id: json.getFromMapFirstNotNull( ['levelId', 'id']) as int,
      name: json.getFromMapFirstNotNull( ['level', 'name']) as String,
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