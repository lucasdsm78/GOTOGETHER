import 'dart:convert';
import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:go_together/models/activity.dart';
import 'package:go_together/helper/api.dart';

class ActivityServiceApi {
  final api = Api();

  Future<List<Activity>> getAll({Map<String, dynamic> map = const {}}) async {
    log(api.handleUrlParams(true, map, []));
    final response = await api.client
        .get(Uri.parse(api.host + 'get/activities' + api.handleUrlParams(true, map, [])));
    if (response.statusCode == 200) {
      return compute(api.parseActivities, response.body);
    } else {
      throw Exception('Failed to load activities');
    }
  }

  Future<Activity> getById(int id) async {
    final response = await api.client
        .get(Uri.parse(api.host + 'get/activity/$id'));
    if (response.statusCode == 200) {
      return Activity.fromJson(jsonDecode(response.body)["success"]);
    } else {
      throw Exception('Failed to load activity');
    }
  }

  Future<Activity> add(Activity activity) async {
    final response = await api.client
        .post(Uri.parse(api.host + 'add/activity'),
      headers:api.mainHeader,
      body: activity.toJson(),
    );
    if (response.statusCode == 201) {
      return Activity.fromJson(jsonDecode(response.body)["success"]);
    } else {
      throw Exception('Failed to create activity.');
    }
  }

  Future<Activity> updatePost(Activity activity) async {
    final response = await api.client
        .post(Uri.parse(api.host + 'activity/${activity.id}'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: activity.toJson(),
    );
    print(jsonDecode(response.body));
    if (jsonDecode(response.body)['success'] != null) {
      return Activity.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to update activity.');
    }
  }

  Future<Activity> updatePatch(Map<String, dynamic> map) async {
    if(map.containsKey("id")){
      throw Exception('need an id to update an activity.');
    }
    else {
      final response = await api.client
          .patch(Uri.parse(api.host + 'activity/${map["id"]}'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(map),
      );
      print(jsonDecode(response.body));
      if (jsonDecode(response.body)['success'] != null) {
        return Activity.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to update activity.');
      }
    }
  }

  Future<Activity> delete(String id) async {
    final response = await api.client
        .delete(Uri.parse(api.host + 'delete/activity/$id'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    if (response.statusCode == 200) {
      return Activity.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to delete activity.');
    }
  }

  Future<Activity> joinActivityUser(Activity activity, int userId, bool hasJoin) async {
    final response = await api.client
        .post(Uri.parse(api.host+ 'joining/activity'),
      headers:api.mainHeader,
      body:  jsonEncode(<String, int>{
        "idUser": userId,
        "idActivity": activity.id!,
        "isJoining": hasJoin ? 0 : 1
      }),
    );

    if (response.statusCode == 200) {
      return Activity.fromJson(jsonDecode(response.body)["success"]["last_insert"]);
    } else {
      throw Exception('Failed to join an activity.');
    }
  }
}