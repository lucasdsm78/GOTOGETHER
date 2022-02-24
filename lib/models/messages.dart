import 'dart:convert';

import '../helper/date_extension.dart';

class Message {
  final int id;
  final String bodyMessage;
  final int idReceiver;
  final int idSender;
  final DateTime? createdAt;

  Message({
    required this.id,
    required this.bodyMessage,
    required this.idReceiver,
    required this.idSender,
    required this.createdAt,

  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['idMessage'] as int,
      bodyMessage: json['message'] as String,
      idReceiver: json['idReceiver'] as int,
      idSender: json['idSender'] as int,
      createdAt: json['createdAt'] == null ? null : parseStringToDateTime(json['createdAt']! as String), // DateTime.parse(json['createdAt']! as String),
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'message': bodyMessage,
    };
  }

  toJson() {
    return jsonEncode(toMap());
  }
}