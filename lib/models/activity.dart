import 'dart:io';
import 'dart:convert';
import 'package:go_together/helper/date_extension.dart';
import 'package:go_together/helper/enum/gender.dart';
import 'package:go_together/models/location.dart';

//@todo all field found in location (locationId, address, city...) should create an entity Location
class Activity {
  final int? id;
  final Location location;

  //@todo convert hostId, mail et name into User, and sport intp Sport
  final int hostId;
  final String hostMail;
  final String hostName;
  final String sport;

  final DateTime dateEnd;
  final DateTime dateStart;
  final String description;
  final int isCanceled;
  final String level;
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

    required this.hostId,
    required this.hostMail,
    required this.hostName,
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

      hostId: json['hostId'],
      hostMail: json['hostMail'],
      hostName: json['hostName'],
      sport: json['sport'],

      dateEnd: HttpDate.parse(json['dateEnd']),
      dateStart: HttpDate.parse(json['dateStart']),
      description: json['description'],
      isCanceled: json['isCanceled'],
      level: json['level'],
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

      "hostId": hostId,
      "hostMail": hostMail,
      "hostName": hostName,
      "sport": sport,

      "dateEnd": dateEnd.getDbDateTime(),
      "dateStart": dateStart.getDbDateTime(),
      "description": description,
      "isCanceled": isCanceled,
      "level": level,
      "attendeesNumber": attendeesNumber,

      "currentParticipants": currentParticipants,
      "nbCurrentParticipants": nbCurrentParticipants,
      "createdAt": createdAt,
      "updatedAt": updatedAt,

      "public": public,
      "criterionGender": criterionGender,
      "limitByLevel": limitByLevel,
    };
    map.addAll(location.toMap());
    return map;
  }

  toJson() {
    return jsonEncode(toMap());
  }
}
