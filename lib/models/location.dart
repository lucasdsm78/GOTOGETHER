import 'dart:convert';

import 'package:go_together/helper/map_extension.dart';

class Location {
  final int? id;
  final String address;
  final String city;
  final String country;
  final double lat;
  final double lon;

  Location({
    this.id,
    required this.address,
    required this.city,
    required this.country,
    required this.lat,
    required this.lon,
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      id: json.getFromMapFirstNotNull( ['locationId', 'id']) as int,
      address: json['address'] as String,
      city: json['city'] as String,
      country: json['country'] as String,
      lat: double.parse(json['lat']),
      lon: double.parse(json['lon']),
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'address': address,
      'city': city,
      'country': country,
      'lat': lat,
      'lon': lon,
    };
  }

  toJson() {
    return jsonEncode(toMap());
  }
}
