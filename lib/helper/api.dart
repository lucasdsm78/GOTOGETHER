import 'dart:convert';

import 'package:go_together/models/activity.dart';
import 'package:go_together/models/sports.dart';
import 'package:go_together/models/user.dart';

String handleUrlParams(bool isFirstParam, Map<String, dynamic> map, List<String> ignored){
  String params = "";
  int count = 0;
  map.forEach((key, value){
    if(!ignored.contains(key) && value != null && !(value?.isEmpty ?? true) ){
      params += (isFirstParam && count ==0 ? "?" : "&") + key + "=" + value.toString();
      count ++;
    }
  });
  return params;
}

List<Activity> parseActivities(String responseBody) {
  final parsed = jsonDecode(responseBody)["success"].cast<Map<String, dynamic>>();
  return parsed.map<Activity>((json) => Activity.fromJson(json)).toList();
}

List<Sport> parseSports(String responseBody) {
  final parsed = jsonDecode(responseBody)["success"].cast<Map<String, dynamic>>();
  return parsed.map<Activity>((json) => Sport.fromJson(json)).toList();
}

List<User> parseUsers(String responseBody) {
  final parsed = jsonDecode(responseBody)["success"].cast<Map<String, dynamic>>();

  return parsed.map<User>((json) => User.fromJson(json)).toList();
}