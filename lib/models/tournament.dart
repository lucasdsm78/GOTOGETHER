import 'dart:io';
import 'package:go_together/models/activity.dart';
import 'dart:convert';
import 'package:go_together/helper/enum/run_types.dart';
import 'package:go_together/helper/extensions/date_extension.dart';
import 'package:go_together/helper/enum/gender.dart';
import 'package:go_together/helper/parse_helper.dart';
import 'package:go_together/models/location.dart';
import 'package:go_together/models/sports.dart';
import 'package:go_together/models/user.dart';

import 'level.dart';

class Tournament extends Activity {
  final int nbEquip;
  final int? nbByEquip;

  Tournament(
      {id,
      required location,
      required host,
      required sport,
      required dateEnd,
      required dateStart,
      required description,
      required isCanceled,
      required level,
      required attendeesNumber,
      currentParticipants,
      nbCurrentParticipants,
      createdAt,
      updatedAt,
      public,
      criterionGender,
      limitByLevel,
      required this.nbEquip,
      this.nbByEquip})
      : super(
          id: id,
          location: location,
          host: host,
          sport: sport,
          dateEnd: dateEnd,
          dateStart: dateStart,
          description: description,
          isCanceled: isCanceled,
          level: level,
          attendeesNumber: attendeesNumber,
          currentAttendees: currentParticipants,
          nbCurrentParticipants: nbCurrentParticipants,
          createdAt: createdAt,
          updatedAt: updatedAt,
          public: public,
          criterionGender: criterionGender,
          limitByLevel: limitByLevel,
        );

  factory Tournament.fromJson(Map<String, dynamic> json) {
    return Tournament(
      id: json['tournamentId'],
      location: Location.fromJson(json),

      host: User(id:json['hostId'], username: json['hostName'], mail: json['hostMail'], role: json['hostRole'], friendsList: jsonParseToList(json["hostFriends"], RunTypes.int)),
      sport: Sport.fromJson(json),

      dateEnd: parseStringToDateTime(json['dateEnd']! as String),
      dateStart: parseStringToDateTime(json['dateStart']! as String),
      description: json['description'],
      isCanceled: json['isCanceled'],
      level: Level.fromJson(json),
      attendeesNumber: json['attendeesNumber'],

      currentParticipants: json['participantsIdConcat']?.isEmpty ?? true ? <String>[] : json['participantsIdConcat'].split(','),
      nbCurrentParticipants: json['nbCurrentParticipants'] == null ? 0 : json['nbCurrentParticipants'] as int,
      createdAt: parseStringToDateTime(json['createdAt']! as String),
      updatedAt: parseStringToDateTime(json['updatedAt']! as String),

      public: json["public"] == null ? true : json["public"]!=0,
      criterionGender: json["criterionGender"] == null ? null : getGenderByString(json["criterionGender"]),
      limitByLevel: json["limitByLevel"] == null ? true : json["limitByLevel"]!=0,
      nbEquip: json["nbEquip"],
      nbByEquip: json["nbParticipantTeam"],
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
      "nbEquip": nbEquip,
      "nbParticipantTeam":nbByEquip,
    };
    return map;
  }

  toJson() {
    return jsonEncode(toMap());
  }
}
