import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:go_together/models/user.dart';
import 'package:go_together/helper/api.dart';

class UserServiceApi {
  final api = Api();

  Future<List<User>> getAll({Map<String, dynamic> map = const {}}) async {
    final response = await api.client
        .get(Uri.parse(api.host + 'get/users'));
    if (response.statusCode == 200) {
      return compute(api.parseUsers, response.body);
    } else {
      throw Exception('Failed to load users');
    }
  }

  Future<User> getById(int id) async {
    final response = await api.client
        .get(Uri.parse(api.host + 'get/user/$id'));
    if (response.statusCode == 200) {
      return User.fromJson(jsonDecode(response.body)["success"]);
    } else {
      throw Exception('Failed to load user');
    }
  }

  Future<String> getJWTTokenByGoogleToken(String tokenGoogle) async {
    final response = await api.client
        .get(Uri.parse(api.host + 'authentication/google/$tokenGoogle'),
      headers: api.mainHeader
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body)["success"]["token"];
    } else {
      throw Exception('Failed to load token');
    }
  }

  Future<String> getJWTTokenByLogin(Map<String, String> login) async {
    final response = await api.client
        .post(Uri.parse(api.host + 'authentication'),
        headers: api.mainHeader,
        body: jsonEncode(login),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body)["success"]["token"];
    } else {
      throw Exception('Failed to load token');
    }
  }

  Future<User> add(User user) async {
    //ex : createUser(User(username: "flutterUser2", mail: "flutterUser2@gmail.com", password: "flutterPass"));
    final response = await api.client
        .post(Uri.parse(api.host + 'add/user'),
      headers: api.mainHeader,
      body: user.toJson(),
    );
    if (response.statusCode == 201) {
      return User.fromJson(jsonDecode(response.body)["success"]["last_insert"]);
    } else {
      throw Exception('Failed to create user.');
    }
  }

  Future<User> updatePost(User user) async {
    final response = await api.client
        .post(Uri.parse(api.host + 'user/${user.id}'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: user.toJson(),
    );
    print(jsonDecode(response.body));
    if (jsonDecode(response.body)['success'] != null) {
      return User.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to update user.');
    }
  }

  Future<User> updatePatch(Map<String, dynamic> map) async {
    if(map.containsKey("id")){
      throw Exception('need an id to update an user.');
    }
    else {
      final response = await api.client
          .patch(Uri.parse(api.host + 'user/${map["id"]}'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(map),
      );
      print(jsonDecode(response.body));
      if (jsonDecode(response.body)['success'] != null) {
        return User.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to update user.');
      }
    }
  }

  Future<User> delete(String id) async {
    final response = await api.client
        .delete(Uri.parse(api.host + 'user/$id'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    if (response.statusCode == 200) {
      return User.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to delete user.');
    }
  }
}