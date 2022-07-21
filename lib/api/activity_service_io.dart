import 'dart:convert';
import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:go_together/helper/parse_helper.dart';
import 'package:go_together/models/activity.dart';
import 'package:go_together/models/user.dart';
import 'package:go_together/helper/api.dart';

/// This class is used to call our API for all that concern activities
class ActivityServiceApi {
  final api = Api();

  /// get all activities corresponding to filter given by [map].
  /// the [map] keys are the params used in api to filter the activities
  Future<List<Activity>> getAll({Map<String, dynamic> map = const {}}) async {
    log("activity service api : " + api.handleUrlParams(true, map));
    final response = await api.httpGet(api.host + 'get/activities' + api.handleUrlParams(true, map));
    if (response.statusCode == 200) {
      return compute(parseActivities, response.body);
    } else {
      throw ApiErr(codeStatus: response.statusCode, message: "failed to load activities");
    }
  }

  Future<List<Activity>> getAllProposition(int idUser) async {
    final response = await api.httpGet(api.host + 'activities/proposition/' + idUser.toString());
    if (response.statusCode == 200) {
      return compute(parseActivities, response.body);
    } else {
      throw ApiErr(codeStatus: response.statusCode, message: "failed to load activities");
    }
  }

  Future<Activity> getById(int id) async {
    final response = await api.httpGet(api.host + 'get/activity/$id');

    if (response.statusCode == 200) {
      return Activity.fromJson(jsonDecode(response.body)["success"]);
    } else {
      throw ApiErr(codeStatus: response.statusCode, message: "failed to load activity");
    }
  }

  Future<List<Activity>> getByUserId(int id) async {
    final response = await api.httpGet(api.host + 'activities/user/$id');
    if (response.statusCode == 200) {
      return compute(parseActivities, response.body);
    } else {
      throw ApiErr(codeStatus: response.statusCode, message: "failed to load activities");
    }
  }

  Future<Activity> add(Activity activity) async {
    final response = await api.httpPost(api.host + 'add/activity', activity.toJson());
    if (response.statusCode == 201) {
      return Activity.fromJson(jsonDecode(response.body)["success"]);
    } else {
      throw ApiErr(codeStatus: response.statusCode, message: "failed to create activity");
    }
  }

  Future<Activity> updatePost(Activity activity) async {
    final response = await api.httpPut(api.host + 'update/activity/${activity.id}', activity.toJson());
    print(jsonDecode(response.body));
    if (jsonDecode(response.body)['success'] != null) {
      return Activity.fromJson(jsonDecode(response.body)['success']);
    } else {
      throw ApiErr(codeStatus: response.statusCode, message: "failed to update activity");
    }
  }

  /// update partially an activity.
  /// the [id] field in [map] should exist and is the activity id.
  Future<Activity> updatePatch(Map<String, dynamic> map) async {
    if(!map.containsKey("id")){
      throw Exception('need an id to update an activity.');
    }
    else {
      final response = await api.httpPatch(api.host + 'activity/${map["id"]}', jsonEncode(map));
      print(jsonDecode(response.body));
      if (jsonDecode(response.body)['success'] != null) {
        return Activity.fromJson(jsonDecode(response.body));
      } else {
        throw ApiErr(codeStatus: response.statusCode, message: "failed to update activity");
      }
    }
  }

  Future<Activity> delete(String id) async {
    final response = await api.httpDelete(api.host + 'delete/activity/$id');
    if (response.statusCode == 204) {
      return Activity.fromJson(jsonDecode(response.body));
    } else {
      throw ApiErr(codeStatus: response.statusCode, message: "failed to delete activity");
    }
  }

  Future<Activity> joinActivityUser(Activity activity, int userId, bool hasJoin) async {
    final response = await api.httpPost(api.host + 'joining/activity', jsonEncode(<String, int>{
      "idUser": userId,
      "idActivity": activity.id!,
      "isJoining": hasJoin ? 0 : 1
    }));
    if (response.statusCode == 200) {
      return Activity.fromJson(jsonDecode(response.body)["success"]["last_insert"]);
    } else {
      throw ApiErr(codeStatus: response.statusCode, message: "failed to join an activity");
    }
  }

  Future<List<User>> getAllAttendeesByIdActivity(int id) async {
    final response = await api.httpGet(api.host + 'participants/' + id.toString());
    if (response.statusCode == 200) {
      return compute(parseUsers, response.body);
    } else {
      throw ApiErr(codeStatus: response.statusCode, message: "failed to load participants of this activity");
    }
  }

  /// use to change the activity host.
  /// the user won't be able to update after this.
  /// it's used to avoid a cancellation that may be annoying for attendees.
  Future<bool> changeHost(Map<String, dynamic> map) async {
    //{"hostId":And(int), "activityId":And(int)}
    log(map.toString());
    if(!map.containsKey("activityId")){
      throw Exception('need an id to update an activity.');
    }
    else {
      final response = await api.httpPatch(api.host + 'activities/change_host', jsonEncode(map));
      if (jsonDecode(response.body)['success'] != null) {
        log("change ");
        return true;
      } else {
        log("on error occured");
        throw ApiErr(codeStatus: response.statusCode, message: "failed to update activity");
      }
    }
  }
}