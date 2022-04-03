
import 'dart:convert';

class Signal {
  final int? id;
  final int? idReported;
  final int? idReporter;
  final String? mailReported;
  final String? mailReporter;
  final String? reason;
  final String? reportingDate;
  final String? usernameReported;
  final String? usernameReporter;

  Signal({
    this.id,
    this.idReported,
    this.idReporter,
    this.mailReported,
    this.mailReporter,
    this.reason,
    this.reportingDate,
    this.usernameReported,
    this.usernameReporter
  });

  factory Signal.fromJson(Map<String, dynamic> json) {
    return Signal(
      id: json['id'],
      idReported: json['idReported'],
      idReporter: json['idReporter'],
      mailReported: json['mailReported'],
      mailReporter: json['mailReporter'],
      reason: json['reason'],
      reportingDate: json['reportingDate'],
      usernameReported: json['usernameReported'],
      usernameReporter: json['usernameReporter'],
    );
  }
  Map<String, Object?> toMap() {
    return {
      'userIdReporter': idReporter,
      'userIdReported' : idReported,
      'reason': reason
    };
  }

  toJson() {
    return jsonEncode(toMap());
  }
}
