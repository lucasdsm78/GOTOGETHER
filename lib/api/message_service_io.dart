import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:go_together/models/messages.dart';
import 'package:go_together/helper/api.dart';

class MessageServiceApi {
  final api = Api();

  Future<List<Message>> getAll({Map<String, dynamic> map = const {}}) async {
    final response = await api.client
        .get(Uri.parse(api.host + 'messages'));
    if (response.statusCode == 200) {
      return compute(api.parseMessages, response.body);
    } else {
      throw Exception('Failed to load messages');
    }
  }

  Future<List<Message>> getById(int id) async {
    final response = await api.client
        .get(Uri.parse(api.host + 'messages/$id'));
    if (response.statusCode == 200) {
      return compute(api.parseMessages, response.body);
    } else {
      throw Exception('Failed to load message');
    }
  }
}