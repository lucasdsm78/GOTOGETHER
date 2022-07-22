import 'dart:io';
import 'dart:convert';
import 'package:go_together/helper/enum/run_types.dart';
import 'package:go_together/helper/extensions/date_extension.dart';
import 'package:go_together/helper/enum/gender.dart';
import 'package:go_together/helper/parse_helper.dart';
import 'package:go_together/models/location.dart';
import 'package:go_together/models/sports.dart';
import 'package:go_together/models/user.dart';

import 'level.dart';

class Activity {
  final int? id;
  final Location location;

  final User host;
  final Sport sport;

  final DateTime dateEnd;
  final DateTime dateStart;
  final String description;
  final int isCanceled;
  final Level level;
  final int attendeesNumber;
  final List<String>? currentAttendees;
  final int? nbCurrentParticipants;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  final bool? public;
  final Gender? criterionGender;
  final bool? limitByLevel;

  Activity({
    this.id,
    required this.location,

    required this.host,
    required this.sport,

    required this.dateEnd,
    required this.dateStart,
    required this.description,
    required this.isCanceled,
    required this.level,
    required this.attendeesNumber,
    this.currentAttendees,
    this.nbCurrentParticipants,
    this.createdAt,
    this.updatedAt,

    this.public,
    this.criterionGender,
    this.limitByLevel,
  });

  factory Activity.fromJson(Map<String, dynamic> json) {
    return Activity(
      id: json['activityId'],
      location: Location.fromJson(json),

      host: User(id:json['hostId'], username: json['hostName'], mail: json['hostMail'], role: json['hostRole'], friendsList: jsonParseToList(json["hostFriends"], RunTypes.int)),
      sport: Sport.fromJson(json),

      dateEnd: parseStringToDateTime(json['dateEnd']! as String),
      dateStart: parseStringToDateTime(json['dateStart']! as String),
      description: json['description'],
      isCanceled: json['isCanceled'],
      level: Level.fromJson(json),
      attendeesNumber: json['attendeesNumber'],

      currentAttendees: json['participantsIdConcat']?.isEmpty ?? true ? <String>[] : json['participantsIdConcat'].split(','),
      nbCurrentParticipants: json['nbCurrentParticipants'] == null ? 0 : json['nbCurrentParticipants'] as int,
      createdAt: parseStringToDateTime(json['createdAt']! as String),
      updatedAt: parseStringToDateTime(json['updatedAt']! as String),

      public: json["public"] == null ? true : json["public"]!=0,
      criterionGender: json["criterionGender"] == null ? null : getGenderByString(json["criterionGender"]),
      limitByLevel: json["limitByLevel"] == null ? true : json["limitByLevel"]!=0,
    );
  }

  ///convert this class into a map that can be use for DB purpose.
  ///all keys are the same used in our API
  Map<String, Object?> toMap() {
    Map<String, Object?> map = {
      "id": id,
      "location": location.toMap(),

      "host": host.toMap(),
      "sport": sport.toMap(),

      "dateEnd": dateEnd.getDbDateTime(),
      "dateStart": dateStart.getDbDateTime(),
      "description": description,
      "isCanceled": isCanceled,
      "level": level.toMap(),
      "attendeesNumber": attendeesNumber,

      "currentParticipants": currentAttendees == null ? null : currentAttendees,
      "nbCurrentParticipants": nbCurrentParticipants == null ? null : nbCurrentParticipants,
      "createdAt": createdAt == null ? null : createdAt!.getDbDateTime(),
      "updatedAt": updatedAt == null ? null : updatedAt!.getDbDateTime(),

      "public": public,
      "criterionGender": criterionGender == null ? null : criterionGender!.toShortString(),
      "limitByLevel": limitByLevel,
    };
    return map;
  }

  String toJson() {
    return jsonEncode(toMap());
  }
}
