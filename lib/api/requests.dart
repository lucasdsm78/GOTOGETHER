import 'dart:developer';
import 'package:go_together/models/activity.dart';
import 'package:http/http.dart' as http;
import 'package:go_together/models/user.dart';
import 'dart:async';
import 'dart:convert';

const apiUrl = "http://51.255.51.106:5000/";
//region Users
Future<List<User>> fetchUsers() async {
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

Future<User> createUser(UserRequest user) async {
  //ex : createUser(UserRequest(username: "flutterUser2", mail: "flutterUser2@gmail.com", password: "flutterPass"));

  final response = await http.post(
    Uri.parse(apiUrl + 'add/user'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: user.asJson(),
  );

  if (response.statusCode == 201) {
    return User.fromJson(jsonDecode(response.body)["success"]["last_insert"]);
  } else {
    throw Exception('Failed to create album.');
  }
}
//endregion

Future<List<Activity>> fetchActivities() async {
  final response = await http.get(Uri.parse(apiUrl + 'get/activities'));

  if (response.statusCode == 200) {
    List jsonResponse = jsonDecode(response.body)["success"];
    return jsonResponse.map((activity) => Activity.fromJson(activity)).toList();
  } else {
    throw Exception('Failed to load activities');
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
