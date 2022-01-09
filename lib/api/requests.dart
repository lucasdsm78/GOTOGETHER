import 'dart:developer';
import 'package:go_together/api/objects/activity.dart';
import 'package:http/http.dart' as http;
import 'package:go_together/api/objects/user.dart';
import 'dart:async';
import 'dart:convert';

const apiUrl = "http://51.255.51.106:5000/";

Future<List<User>> fetchUsers() async {
  //@todo : savoir générer un tableau et le remplir, ceci a partir du tableau d'user
  final response = await http.get(Uri.parse(apiUrl + 'get/users'));

  if (response.statusCode == 200) {
    List jsonResponse = jsonDecode(response.body)["success"];
    return jsonResponse.map((user) => User.fromJson(user)).toList();
  } else {
    throw Exception('Failed to load user');
  }
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