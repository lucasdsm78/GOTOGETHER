import 'dart:developer';

import 'package:http/http.dart' as http;
import 'package:go_together/api/objects/user.dart';
import 'dart:async';
import 'dart:convert';

Future<http.Response> fetchUsers() {
  return http.get(Uri.parse('http://51.255.51.106:5000/get/users'));
}

Future<User> fetchUserById(id) async {
  final response = await http
      .get(Uri.parse('http://51.255.51.106:5000/get/user/$id'));
  if (response.statusCode == 200) {
    return User.fromJson(jsonDecode(response.body)["success"]);
  } else {
    throw Exception('Failed to load album');
  }
}