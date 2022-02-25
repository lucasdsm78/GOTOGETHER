import 'dart:convert';
import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:go_together/models/sports.dart';
import 'package:go_together/helper/api.dart';

class SportServiceApi {
  final api = Api();

  Future<List<Sport>> getAll({Map<String, dynamic> map = const {}}) async {
    final response = await api.client
        .get(Uri.parse(api.host + 'get/sports'));
    if (response.statusCode == 200) {
      return compute(api.parseSports, response.body);
    } else {
      throw ApiErr(codeStatus: response.statusCode, message: "failed to load sports");
    }
  }

  Future<Sport> getById(int id) async {
    final response = await api.client
        .get(Uri.parse(api.host + 'get/sport/$id'));
    if (response.statusCode == 200) {
      return Sport.fromJson(jsonDecode(response.body)["success"]);
    } else {
      throw ApiErr(codeStatus: response.statusCode, message: "failed to load sport");
    }
  }
}