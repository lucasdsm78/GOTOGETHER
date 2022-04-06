import 'dart:convert';
import 'dart:developer';
// import 'dart:ffi';
import 'package:flutter/foundation.dart';
import 'package:go_together/models/user.dart';
import 'package:go_together/helper/api.dart';

class FriendsServiceApi {
  final api = Api();

  //probably won't be used (at least for now)
  Future<List<User>> getAll({Map<String, dynamic> map = const {}}) async {
    final response = await api.client
        .get(Uri.parse(api.host + 'friends'));
    if (response.statusCode == 200) {
      return compute(api.parseUsers, response.body);
    } else {
      throw Exception('Failed to load all friends');
    }
  }

  Future<List<User>> getById(int userId) async {
    final response = await api.client
        .get(Uri.parse(api.host + 'friends/$userId'));
    if (response.statusCode == 200) {
      return compute(api.parseUsers, response.body);
    } else {
      throw Exception('Failed to load friends user');
    }
  }

  Future<List<User>> getWaitingById(int userId) async {
    final response = await api.client
        .get(Uri.parse(api.host + 'friends/waiting/$userId'));
    if (response.statusCode == 200) {
      return compute(api.parseUsers, response.body);
    } else {
      throw Exception('Failed to load friends user');
    }
  }

  Future<List<User>> getWaitingAndValidateById(int userId) async {
    final response = await api.client
        .get(Uri.parse(api.host + 'friends/all/$userId'));
    if (response.statusCode == 200) {
      return compute(api.parseUsers, response.body);
    } else {
      throw Exception('Failed to load friends user');
    }
  }

  Future<User> add(Map<String, int> map) async {
    log(map.toString());
    if(!map.containsKey("userIdSender") || !map.containsKey("userIdReceiver")){
      throw Exception('need an userIdSender and userIdReceiver to create a friendship.');
    }
    final response = await api.client
        .post(Uri.parse(api.host + 'friends'),
      headers: api.mainHeader,
      body: jsonEncode(map),
    );
    if (response.statusCode == 201) {
      return User.fromJson(jsonDecode(response.body)["success"]["last_insert"]);
    } else {
      throw Exception('Failed to add new friend.');
    }
  }

  Future<bool> validateFriendship(Map<String, int> map) async {
    if(map.containsKey("userIdSender") && map.containsKey("userIdReceiver")){
      throw Exception('need an userIdSender and userIdReceiver to update a friendship.');
    }
    else {
      final response = await api.client
          .patch(Uri.parse(api.host + 'friends'),
        headers: api.mainHeader,
        body: jsonEncode(map),
      );
      if (jsonDecode(response.body)['success'] != null && response.statusCode ==200) {
        return true;
      } else {
        throw Exception('Failed to validate friendship.');
      }
    }
  }

  Future<bool> delete(Map<String, int> map) async {
    if(map.containsKey("userIdSender") && map.containsKey("userIdReceiver")){
      throw Exception('need an userIdSender and userIdReceiver to update a friendship.');
    }
    final response = await api.client
        .delete(Uri.parse(api.host + 'friends'),
      headers: api.mainHeader,
      body: jsonEncode(map),
    );

    if (response.statusCode == 204) {
      return true;
    } else {
      throw Exception('Failed to delete friendship.');
    }
  }
}