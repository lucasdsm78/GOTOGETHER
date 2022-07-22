import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:go_together/helper/parse_helper.dart';
import 'package:go_together/models/conversation.dart';
import 'package:go_together/models/messages.dart';
import 'package:go_together/helper/api.dart';

class MessageServiceApi {
  final api = Api();

  Future<List<Message>> getAll({Map<String, dynamic> map = const {}}) async {
    final response = await api.httpGet(api.host + 'messages');
    if (response.statusCode == 200) {
      return compute(parseMessages, response.body);
    } else {
      throw ApiErr(codeStatus: response.statusCode, message: "failed to load messages");
    }
  }

  Future<List<Message>> getById(int id) async {
    final response = await api.httpGet(api.host + 'messages/$id');
    if (response.statusCode == 200) {
      return compute(parseMessages, response.body);
    } else {
      throw ApiErr(codeStatus: response.statusCode, message: "can't load message");
    }
  }

  Future<List<Conversation>> getConversationById(int id) async {
    final response = await api.httpGet(api.host + 'conversations/$id');
    if (response.statusCode == 200) {
      return compute(parseConversation, response.body);
    } else {
      throw ApiErr(codeStatus: response.statusCode, message: "failed to load conversations data");
    }
  }

  Future<List<Conversation>> getAllConversationCurrentUser() async {
    final response = await api.httpGet(api.host + 'conversations');
    if (response.statusCode == 200) {
      return compute(parseConversation, response.body);
    } else {
      throw ApiErr(codeStatus: response.statusCode, message: "failed to load conversations data");
    }
  }

  /// we add a copy of one encrypted message for each user in conversation
  Future<Message> add(int id, List<Message> message) async {
    List<Map<String, dynamic>> messageListAsDict = [];
    message.forEach((element) {
      messageListAsDict.add(element.toMap());
    });
    String body = jsonEncode(messageListAsDict);
    final response = await api.httpPost(api.host + 'messages/$id', body);
    if (response.statusCode == 201) {
      return Message.fromJson(jsonDecode(response.body)["success"]["last_insert"]);
    } else {
      throw ApiErr(codeStatus: response.statusCode, message: "can't add message in this conversation");
    }
  }

  Future<bool> quit(int id) async {
    final response = await api.httpDelete(api.host + 'conversations/quit/$id');
    if (response.statusCode == 200) {
      return true;
    } else {
      throw ApiErr(codeStatus: response.statusCode, message: "can't add message in this conversation");
    }
  }
}