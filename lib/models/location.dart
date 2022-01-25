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
      id: json['locationId'],
      address: json['address'],
      city: json['city'],
      country: json['country'],
      lat: double.parse(json['lat']),
      lon: double.parse(json['lon']),
    );
  }

  Map<String, Object?> toJson() {
    return {
      'locationId': id,
      'address': address,
      'city': city,
      'country': country,
      'lat': lat,
      'lon': lon,
    };
  }
//@todo : add function toJson()
}
