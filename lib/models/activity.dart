import 'dart:io';

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
  final List<int> currentParticipants;
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
      currentParticipants: json['participants'].split(',').map(int.parse).toList(),
      updatedAt: HttpDate.parse(json['updatedAt']),
    );
  }
}