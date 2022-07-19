import 'dart:convert';
import 'package:go_together/helper/extensions/date_extension.dart';

class Conversation {
  final int? id;
  final String name;
  final int userId;
  final String pubKey;
  final String? lastMessage;
  final DateTime? lastMessageDate;
  final DateTime? createdAt;

  Conversation({
    this.id,
    required this.name,
    required this.userId,
    required this.pubKey,
    this.createdAt,
    this.lastMessage,
    this.lastMessageDate,
  });

  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      id: json['idConversation'] == null ? null : json['idConversation'] as int,
      name: json['conversation'] as String,
      userId: json['idUser'] as int,
      pubKey: json['pubKey'] == null ? "" : json['pubKey'] as String,
      createdAt: json['createdAt'] == null ? null : parseStringToDateTime(json['createdAt']! as String),
      lastMessage: json['lastMessage'] == null ? null : json['lastMessage']! as String,
      lastMessageDate: json['lastMessageDate'] == null ? null : parseStringToDateTime(json['lastMessageDate']! as String),
    );
  }

  ///convert this class into a map that can be use for DB purpose.
  ///all keys are the same used in our API
  Map<String, Object?> toMap() {
    Map<String, Object?> map = {
      "idConversation": id,
      "conversation": name,
      "idUser": userId,
      "pubKey": pubKey,
      "createdAt" : createdAt == null ? null : createdAt!.getDbDateTime(),
      "lastMessage" : lastMessage == null ? null : lastMessage!,
      "lastMessageDate" : lastMessageDate == null ? null : lastMessageDate!.getDbDateTime(),
    };
    return map;
  }

  toJson() {
    return jsonEncode(toMap());
  }
}