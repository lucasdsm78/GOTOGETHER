import 'dart:convert';
import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:go_together/helper/parse_helper.dart';
import 'package:go_together/models/user.dart';
import 'package:go_together/helper/api.dart';

class FriendsServiceApi {
  final api = Api();

  Future<List<User>> getAll({Map<String, dynamic> map = const {}}) async {
    final response = await api.httpGet(api.host + 'friends');
    if (response.statusCode == 200) {
      return compute(parseUsers, response.body);
    } else {
      throw Exception('Failed to load all friends');
    }
  }

  Future<List<User>> getById(int userId) async {
    final response = await api.httpGet(api.host + 'friends/$userId');
    if (response.statusCode == 200) {
      return compute(parseUsers, response.body);
    } else {
      throw Exception('Failed to load friends user');
    }
  }

  Future<List<User>> getWaitingById(int userId) async {
    final response = await api.httpGet(api.host + 'friends/waiting/$userId');
    if (response.statusCode == 200) {
      return compute(parseUsers, response.body);
    } else {
      throw Exception('Failed to load friends user');
    }
  }

  Future<List<User>> getWaitingAndValidateById(int userId) async {
    final response = await api.httpGet(api.host + 'friends/all/$userId');
    if (response.statusCode == 200) {
      return compute(parseUsers, response.body);
    } else {
      throw Exception('Failed to load friends user');
    }
  }

  /// use to add a new friend to user's invited friend list.
  /// [map] should contain 'userIdSender' & 'userIdReceiver' to work.
  /// userIdSender is the current user id, userIdReceiver is the user id to
  /// invite as friend.
  Future<User> add(Map<String, int> map) async {
    log(map.toString());
    if(!map.containsKey("userIdSender") || !map.containsKey("userIdReceiver")){
      throw Exception('need an userIdSender and userIdReceiver to create a friendship.');
    }
    final response = await api.httpPost(api.host + 'friends', jsonEncode(map));
    if (response.statusCode == 201) {
      return User.fromJson(jsonDecode(response.body)["success"]["last_insert"]);
    } else {
      throw Exception('Failed to add new friend.');
    }
  }


  /// use to validate friendship between 2 users.
  /// [map] should contain 'userIdSender' & 'userIdReceiver' to work.
  Future<bool> validateFriendship(Map<String, int> map) async {
    if(!map.containsKey("userIdSender") || !map.containsKey("userIdReceiver")){
      throw Exception('need an userIdSender and userIdReceiver to update a friendship.');
    }
    else {
      final response = await api.httpPatch(api.host + 'friends', jsonEncode(map));
      if (jsonDecode(response.body)['success'] != null && response.statusCode ==200) {
        return true;
      } else {
        throw Exception('Failed to validate friendship.');
      }
    }
  }

  /// use to delete friendship between 2 users.
  /// [map] should contain 'userIdSender' & 'userIdReceiver' to work.
  Future<bool> delete(Map<String, int> map) async {
    if(!map.containsKey("userIdSender") || !map.containsKey("userIdReceiver")){
      throw Exception('need an userIdSender and userIdReceiver to update a friendship.');
    }
    final response = await api.httpDelete(api.host + 'friends', json:jsonEncode(map));
    if (response.statusCode == 204) {
      return true;
    } else {
      throw Exception('Failed to delete friendship.');
    }
  }
}