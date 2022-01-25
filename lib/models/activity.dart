import 'dart:io';
import 'dart:convert';
import 'package:go_together/helper/date_extension.dart';

//@todo all field found in location (locationId, address, city...) should create an entity Location
class Activity {
  final int? id;
  final int? locationId;
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
  final int attendeesNumber;
  final List<String> currentParticipants;
  final int nbCurrentParticipants;
  final DateTime createdAt;
  final DateTime updatedAt;

  Activity({
    this.id,
    this.locationId,
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
    required this.attendeesNumber,
    required this.currentParticipants,
    required this.nbCurrentParticipants,
    required this.createdAt,
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
      attendeesNumber: json['attendeesNumber'],
      currentParticipants: json['participantsIdConcat']?.isEmpty ?? true ? <String>[] : json['participantsIdConcat'].split(','),
      nbCurrentParticipants: json['nbCurrentParticipants'] == null ? 0 : json['nbCurrentParticipants'] as int,
      createdAt: HttpDate.parse(json['createdAt']),
      updatedAt: HttpDate.parse(json['updatedAt']),
    );
  }

  /// in comment, fields not used by api
  ///
  /// currently needed for api
  //"address": address,
  //       "city": city,
  //       "country": country,
  //       "lat": lat as String,
  //       "lon": lon as String,
  //
  //       "hostId": hostId as String,
  //       "sportId": sportId as String,
  //
  //       "dateEnd": getMysqlDatetime(dateEnd),
  //       "dateStart": getMysqlDatetime(dateStart),
  //       "description": description,
  //       "idLevel": idLevel as String,
  //       "attendeesNumber": attendeesNumber as String,
  toJson() {
    return jsonEncode({
      "id": id,
      "locationId": locationId,
      "address": address,
      "city": city,
      "country": country,
      "lat": lat,
      "lon": lon,

      "hostId": hostId,
      "hostMail": hostMail,
      "hostName": hostName,
      "sport": sport,

      "dateEnd": dateEnd.getDbDateTime(),
      "dateStart": dateStart.getDbDateTime(),
      "description": description,
      "isCanceled": isCanceled,
      "level": level,
      //"attendeesNumber": attendeesNumber,
      //"currentParticipants": currentParticipants,
      //"nbCurrentParticipants": nbCurrentParticipants,
      //"updatedAt": updatedAt,
    });
  }
}
