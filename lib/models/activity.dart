import 'dart:io';
import 'dart:convert';
import 'package:go_together/helper/date.dart';

class Activity {
  final int id;
  final int locationId;
  final String address;
  final String city;
  final String country;
  final double lat;
  final double lon;

  final int hostId;
  final String hostMail;
  final String hostName;
  final String sport;

  final DateTime dateEnd;
  final DateTime dateStart;
  final String description;
  final int isCanceled;
  final String level;
  final int participantsNumber;
  final List<String> currentParticipants;
  final int nbCurrentParticipants;
  final DateTime updatedAt;

  Activity({
    required this.id,
    required this.locationId,
    required this.address,
    required this.city,
    required this.country,
    required this.lat,
    required this.lon,

    required this.hostId,
    required this.hostMail,
    required this.hostName,
    required this.sport,

    required this.dateEnd,
    required this.dateStart,
    required this.description,
    required this.isCanceled,
    required this.level,
    required this.participantsNumber,
    required this.currentParticipants,
    required this.nbCurrentParticipants,
    required this.updatedAt,
  });

  factory Activity.fromJson(Map<String, dynamic> json) {
    return Activity(
      id: json['activityId'],
      locationId: json['locationId'],
      address: json['address'],
      city: json['city'],
      country: json['country'],
      lat: double.parse(json['lat']),
      lon: double.parse(json['lon']),

      hostId: json['hostId'],
      hostMail: json['hostMail'],
      hostName: json['hostName'],
      sport: json['sport'],

      dateEnd: HttpDate.parse(json['dateEnd']),
      dateStart: HttpDate.parse(json['dateStart']),
      description: json['description'],
      isCanceled: json['isCanceled'],
      level: json['level'],
      participantsNumber: json['participantsNumber'],
      currentParticipants: json['participantsIdConcat']?.isEmpty ?? true ? <String>[] : json['participantsIdConcat'].split(','),
      nbCurrentParticipants: json['nbCurrentParticipants'] == null ? 0 : json['nbCurrentParticipants'] as int,
      updatedAt: HttpDate.parse(json['updatedAt']),
    );
  }
}

class ActivityCreate {
  final String address;
  final String city;
  final String country;
  final double lat;
  final double lon;

  final int hostId;
  final int sportId;

  final DateTime dateEnd;
  final DateTime dateStart;
  final String description;
  final int idLevel;
  final int participantsNumber;

  ActivityCreate({
    required this.address,
    required this.city,
    required this.country,
    required this.lat,
    required this.lon,

    required this.hostId,
    required this.sportId,

    required this.dateEnd,
    required this.dateStart,
    required this.description,
    required this.idLevel,
    required this.participantsNumber,
  });

  factory ActivityCreate.fromJson(Map<String, dynamic> json) {
    return ActivityCreate(
      address: json['address'],
      city: json['city'],
      country: json['country'],
      lat: double.parse(json['lat']),
      lon: double.parse(json['lon']),

      hostId: json['hostId'],
      sportId: json['sportId'],

      dateEnd: HttpDate.parse(json['dateEnd']),
      dateStart: HttpDate.parse(json['dateStart']),
      description: json['description'],
      idLevel: json['idLevel'],
      participantsNumber: json['participantsNumber'],
    );
  }

  factory ActivityCreate.fromString(String address, String city, String country,
      double lat, double lon, int hostId, int sportId, DateTime dateStart,
      DateTime dateEnd, String description, int idLevel, int participantsNumber) {
    return ActivityCreate(
      address: address,
      city: city,
      country: country,
      lat: lat,
      lon: lon,

      hostId: hostId,
      sportId: sportId,

      dateEnd: dateEnd,
      dateStart: dateStart,
      description: description,
      idLevel: idLevel,
      participantsNumber: participantsNumber,
    );
  }

  asJson(){
    return jsonEncode(<String, String>{
      "address": address,
      "city": city,
      "country": country,
      "lat": lat as String,
      "lon": lon as String,

      "hostId": hostId as String,
      "sportId": sportId as String,

      "dateEnd": getMysqlDatetime(dateEnd),
      "dateStart": getMysqlDatetime(dateStart),
      "description": description,
      "idLevel": idLevel as String,
      "participantsNumber": participantsNumber as String,
    });
  }
}
