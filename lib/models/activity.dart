import 'dart:io';
import 'dart:convert';
import 'package:go_together/helper/date_extension.dart';
import 'package:go_together/helper/enum/gender.dart';
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
  final List<String>? currentParticipants;
  final int? nbCurrentParticipants;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  final bool public;
  final Gender criterionGender;
  final bool limitByLevel;

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
    this.currentParticipants,
    this.nbCurrentParticipants,
    this.createdAt,
    this.updatedAt,

    required this.public,
    required this.criterionGender,
    required this.limitByLevel,
  });

  factory Activity.fromJson(Map<String, dynamic> json) {
    return Activity(
      id: json['activityId'],
      /*location: Location(id: json["locationId"], address: json['address'],
        city: json['city'], country:json['country'],lat: double.parse(json['lat']),
        lon: double.parse(json['lon'])),*/
      location: Location.fromJson(json),

      host: User(id:json['hostId'], username: json['hostName'], mail: json['hostMail'], role: json['hostRole']),
      sport: Sport.fromJson(json),

      dateEnd: HttpDate.parse(json['dateEnd']),
      dateStart: HttpDate.parse(json['dateStart']),
      description: json['description'],
      isCanceled: json['isCanceled'],
      level: Level.fromJson(json),
      attendeesNumber: json['attendeesNumber'],

      currentParticipants: json['participantsIdConcat']?.isEmpty ?? true ? <String>[] : json['participantsIdConcat'].split(','),
      nbCurrentParticipants: json['nbCurrentParticipants'] == null ? 0 : json['nbCurrentParticipants'] as int,
      createdAt: HttpDate.parse(json['createdAt']),
      updatedAt: HttpDate.parse(json['updatedAt']),

      public: json["public"] == null ? true : json["public"]!=0,
      criterionGender: json["criterionGender"] == null ? Gender.male : getGenderByString(json["criterionGender"]),
      limitByLevel: json["limitByLevel"] == null ? true : json["limitByLevel"]!=0,
    );
  }

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

      "currentParticipants": currentParticipants == null ? null : currentParticipants,
      "nbCurrentParticipants": nbCurrentParticipants == null ? null : nbCurrentParticipants,
      "createdAt": createdAt == null ? null : createdAt!.getDbDateTime(),
      "updatedAt": updatedAt == null ? null : updatedAt!.getDbDateTime(),

      "public": public,
      "criterionGender": criterionGender.toShortString(),
      "limitByLevel": limitByLevel,
    };
    return map;
  }

  toJson() {
    return jsonEncode(toMap());
  }
}
