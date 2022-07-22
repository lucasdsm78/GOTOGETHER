import 'dart:convert';
import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:go_together/helper/parse_helper.dart';
import 'package:go_together/models/sports.dart';
import 'package:go_together/helper/api.dart';

class SportServiceApi {
  final api = Api();

  Future<List<Sport>> getAll({Map<String, dynamic> map = const {}}) async {
    final response = await api.httpGet(api.host + 'sports');
    if (response.statusCode == 200) {
      return compute(parseSports, response.body);
    } else {
      throw ApiErr(codeStatus: response.statusCode, message: "failed to load sports");
    }
  }

  Future<Sport> getById(int id) async {
    final response = await api.httpGet(api.host + 'sports/$id');
    if (response.statusCode == 200) {
      return Sport.fromJson(jsonDecode(response.body)["success"]);
    } else {
      throw ApiErr(codeStatus: response.statusCode, message: "failed to load sport");
    }
  }
}