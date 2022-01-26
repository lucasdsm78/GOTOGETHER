import 'dart:convert';
import 'package:go_together/helper/map_extension.dart';

class Sport {
  final int id;
  final String name;

  Sport({
    required this.id,
    required this.name,
  });

  factory Sport.fromJson(Map<String, dynamic> json) {
    return Sport(
      id: json.getFromMapFirstNotNull( ['sportId', 'id']) as int,
      name: json.getFromMapFirstNotNull( ['sport', 'name']) as String,
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