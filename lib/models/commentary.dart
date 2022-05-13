import 'dart:convert';

import '../helper/extensions/date_extension.dart';

/// Commentary correspond to commentary made on user
class Commentary {
  final int? id;
  final int userIdReceiver;
  final int userIdSender;
  int? mark;
  String? commentary;
  final DateTime? createdAt;

  Commentary({
    this.id,
    required this.userIdReceiver,
    required this.userIdSender,
    this.mark,
    this.commentary,
    this.createdAt,
  });

  factory Commentary.fromJson(Map<String, dynamic> json) {
    return Commentary(
      id: json['idMessage'] as int,
      userIdReceiver: json['userIdReceiver'] as int,
      userIdSender: json['userIdSender'] as int,
      mark: json['mark'] as int,
      commentary: json['commentary'] as String,
      createdAt: json['createdAt'] == null ? null : parseStringToDateTime(json['createdAt']! as String), // DateTime.parse(json['createdAt']! as String),
    );
  }

  ///convert this class into a map that can be use for DB purpose.
  ///all keys are the same used in our API
  Map<String, Object?> toMap() {
    return {
      'userIdReceiver': userIdReceiver,
      'userIdSender': userIdSender,
      'mark': mark,
      'commentary' : commentary
    };
  }

  toJson() {
    return jsonEncode(toMap());
  }
}