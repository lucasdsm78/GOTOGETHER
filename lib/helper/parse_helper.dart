import 'dart:convert';
import 'package:go_together/models/sports.dart';
import 'package:go_together/models/user.dart';

List<Sport> parseSports(String json) {
  final parsed = jsonDecode(json).cast<Map<String, dynamic>>();
  return parsed.map<Sport>((el) => Sport.fromJson(el)).toList();
}
String listSportToJson(List<Sport> res){
  return  res.map((e) => e.toJson()).toList().toString();
}


List<User> parseUsers(String responseBody) {
  final parsed = jsonDecode(responseBody)["success"].cast<Map<String, dynamic>>();
  return parsed.map<User>((json) => User.fromJson(json)).toList();
}