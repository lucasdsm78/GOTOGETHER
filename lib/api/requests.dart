import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:go_together/helper/api.dart';
import 'package:go_together/models/activity.dart';
import 'package:go_together/models/sports.dart';
import 'package:http/http.dart' as http;
import 'package:go_together/models/user.dart';
import 'dart:async';
import 'dart:convert';

const apiUrl = "http://51.255.51.106:5000/";
const mainHeader = {
  'Content-Type': 'application/json; charset=UTF-8',
  //      HttpHeaders.authorizationHeader: 'Basic your_api_token_here',
};

//region Users
Future<List<User>> fetchUsers(http.Client client) async {
  final response = await client
      .get(Uri.parse(apiUrl + 'get/users'));

  if (response.statusCode == 200) {
    return compute(parseUsers, response.body);
  } else {
    throw Exception('Failed to load activities');
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

Future<User> createUser(UserCreate user) async {
  //ex : createUser(UserCreate(username: "flutterUser2", mail: "flutterUser2@gmail.com", password: "flutterPass"));

  final response = await http.post(
    Uri.parse(apiUrl + 'add/user'),
    headers: mainHeader,
    body: user.asJson(),
  );

  if (response.statusCode == 201) {
    return User.fromJson(jsonDecode(response.body)["success"]["last_insert"]);
  } else {
    throw Exception('Failed to create album.');
  }
}
//endregion

//region Activity
Future<List<Activity>> fetchActivities(http.Client client, Map<String, dynamic> map) async {
  final response = await client
      .get(Uri.parse(apiUrl + 'get/activities' + handleUrlParams(true, map, [])));
  if (response.statusCode == 200) {
    return compute(parseActivities, response.body);
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

Future<Activity> createActivity(ActivityCreate activity) async {
  //ex : createActivity(ActivityCreate(hostId:1, sportId:3, ...));
  final response = await http.post(
    Uri.parse(apiUrl + 'add/activity'),
    headers:mainHeader,
    body: activity.asJson(),
  );

  if (response.statusCode == 201) {
    return Activity.fromJson(jsonDecode(response.body)["success"]["last_insert"]);
  } else {
    throw Exception('Failed to create album.');
  }
}

Future<Activity> joinActivity(Activity activity, int userId, bool hasJoin) async {
  final response = await http.post(
    Uri.parse(apiUrl + 'joining/activity'),
    headers:mainHeader,
    body:  jsonEncode(<String, int>{
      "idUser": userId,
      "idActivity": activity.id,
      "isJoining": hasJoin ? 0 : 1
    }),
  );

  if (response.statusCode == 200) {
    return Activity.fromJson(jsonDecode(response.body)["success"]["last_insert"]);
  } else {
    throw Exception('Failed to create album.');
  }
}
//endregion

//region others (like sports)
Future<List<Sport>> fetchSports(http.Client client) async {
  final response = await client.get(Uri.parse(apiUrl + 'get/sports'));
  if (response.statusCode == 200) {
    return compute(parseSports, response.body);
  } else {
    throw Exception('Failed to load sports');
  }
}
//endregion

