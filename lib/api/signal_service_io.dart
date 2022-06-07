import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:go_together/helper/parse_helper.dart';
import 'package:go_together/models/signal.dart';
import 'package:go_together/helper/api.dart';

class SignalServiceApi {
  final api = Api();

  Future<List<Signal>> getAll({Map<String, dynamic> map = const {}, required int? id}) async {
    final response = await api.client
        .get(Uri.parse(api.host + 'reporting/reporter/$id'));
    if (response.statusCode == 200) {
      return compute(parseSignal, response.body);
    } else {
      throw Exception('Failed to load signals');
    }
  }

  Future<Signal> add(Signal signal) async {
    final response = await api.client
        .post(Uri.parse(api.host + 'reporting'),
      headers: api.mainHeader,
      body: signal.toJson(),
    );
    if (response.statusCode == 201) {
      return Signal.fromJson(jsonDecode(response.body)["success"]["last_insert"]);
    } else {
      throw Exception('Failed to create user.');
    }
  }

}