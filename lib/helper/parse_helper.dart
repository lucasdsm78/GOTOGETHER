import 'dart:convert';
import 'package:go_together/models/sports.dart';

List<Sport> parseSports(String json) {
  final parsed = jsonDecode(json).cast<Map<String, dynamic>>();
  return parsed.map<Sport>((el) => Sport.fromJson(el)).toList();
}