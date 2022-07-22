import 'dart:convert';
import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:go_together/helper/parse_helper.dart';
import 'package:go_together/models/tournament.dart';
import 'package:go_together/helper/api.dart';

class TournamentServiceApi {
  final api = Api();

  Future<List<Tournament>> getAll({Map<String, dynamic> map = const {}}) async {
    log("tournament service api : " + api.handleUrlParams(true, map));
    final response = await api.httpGet(api.host + 'get/activities' + api.handleUrlParams(true, map));
    if (response.statusCode == 200) {
      return compute(parseTournament, response.body);
    } else {
      throw ApiErr(codeStatus: response.statusCode, message: "failed to load activities");
    }
  }

  Future<Tournament> getById(int id) async {
    final response = await api.httpGet(api.host + 'get/tournament/$id');
    if (response.statusCode == 200) {
      return Tournament.fromJson(jsonDecode(response.body)["success"]);
    } else {
      throw ApiErr(codeStatus: response.statusCode, message: "failed to load tournament");
    }
  }

  Future<Tournament> add(Tournament tournament) async {
    final response = await api.httpPost(api.host + 'add/tournament', tournament.toJson());
    if (response.statusCode == 201) {
      return Tournament.fromJson(jsonDecode(response.body)["success"]);
    } else {
      throw ApiErr(codeStatus: response.statusCode, message: "failed to create tournament");
    }
  }

  Future<Tournament> updatePost(Tournament tournament) async {
    final response = await api.httpPost(api.host + '/update/tournament/${tournament.id}', tournament.toJson());
    print(jsonDecode(response.body));
    if (jsonDecode(response.body)['success'] != null) {
      return Tournament.fromJson(jsonDecode(response.body)['success']);
    } else {
      throw ApiErr(codeStatus: response.statusCode, message: "failed to update tournament");
    }
  }

  Future<Tournament> updatePatch(Map<String, dynamic> map) async {
    if(map.containsKey("id")){
      throw Exception('need an id to update an tournament.');
    }
    else {
      final response = await api.httpPatch(api.host + 'tournament/${map["id"]}', jsonEncode(map));
      print(jsonDecode(response.body));
      if (jsonDecode(response.body)['success'] != null) {
        return Tournament.fromJson(jsonDecode(response.body));
      } else {
        throw ApiErr(codeStatus: response.statusCode, message: "failed to update tournament");
      }
    }
  }

  Future<Tournament> delete(String id) async {
    final response = await api.httpDelete(api.host + 'delete/tournament/$id');
    if (response.statusCode == 204) {
      return Tournament.fromJson(jsonDecode(response.body));
    } else {
      throw ApiErr(codeStatus: response.statusCode, message: "failed to delete tournament");
    }
  }

  Future<Tournament> joinActivityUser(Tournament tournament, int userId, bool hasJoin) async {
    final response = await api.httpPost(api.host + 'joining/tournament', jsonEncode(<String, int>{
      "idUser": userId,
      "idTournament": tournament.id!,
      "isJoining": hasJoin ? 0 : 1
    }));
    if (response.statusCode == 200) {
      return Tournament.fromJson(jsonDecode(response.body)["success"]["last_insert"]);
    } else {
      throw ApiErr(codeStatus: response.statusCode, message: "failed to join an tournament");
    }
  }
}