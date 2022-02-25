import 'dart:convert';
import 'package:go_together/helper/date_extension.dart';

class Conversation {
  final int? id;
  final String name;
  final int userId;
  final String pubKey;
  final DateTime? createdAt;

  Conversation({
    this.id,
    required this.name,
    required this.userId,
    required this.pubKey,
    this.createdAt,
  });

  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      id: json['idConversation'] == null ? null : json['idConversation'] as int,
      name: json['conversation'] as String,
      userId: json['idUser'] as int,
      pubKey: json['pubKey'] == null ? "" : json['pubKey'] as String,
      createdAt: json['createdAt'] == null ? null : parseStringToDateTime(json['createdAt']! as String),
    );
  }

  Map<String, Object?> toMap() {
    Map<String, Object?> map = {
      "idConversation": id,
      "conversation": name,
      "idUser": userId,
      "pubKey": pubKey,
      "createdAt" : createdAt == null ? null : createdAt!.getDbDateTime(),
    };
    return map;
  }

  toJson() {
    return jsonEncode(toMap());
  }
}