import 'dart:developer';
import 'package:go_together/api/objects/activity.dart';
import 'package:http/http.dart' as http;
import 'package:go_together/api/objects/user.dart';
import 'dart:async';
import 'dart:convert';

const apiUrl = "http://51.255.51.106:5000/";

Future<http.Response> fetchUsers() {
  //@todo : savoir générer un tableau et le remplir, ceci a partir du tableau d'user
  return http.get(Uri.parse(apiUrl + 'get/users'));
}

Future<User> fetchUserById(id) async {
  final response = await http
      .get(Uri.parse(apiUrl + 'get/user/$id'));
  if (response.statusCode == 200) {
    return User.fromJson(jsonDecode(response.body)["success"]);
  } else {
    throw Exception('Failed to load user');
  }
}


Future<Activity> fetchActivityById(id) async {
  final response = await http
      .get(Uri.parse(apiUrl + 'get/activity/$id'));
  if (response.statusCode == 200) {
    return Activity.fromJson(jsonDecode(response.body)["success"]);
  } else {
    throw Exception('Failed to load activity');
  }
}