import 'dart:convert';
import 'package:go_together/helper/extensions/date_extension.dart';
import 'package:go_together/helper/enum/gender.dart';
import 'package:go_together/models/location.dart';
import 'package:go_together/helper/extensions/map_extension.dart';

/// Availability only use for user, no need to create a model file for it
class Availability{
  final bool monday;
  final bool tuesday;
  final bool wednesday;
  final bool thursday;
  final bool friday;
  final bool saturday;
  final bool sunday;

  Availability({
    this.monday = true,
    this.tuesday = true,
    this.wednesday = true,
    this.thursday = true,
    this.friday = true,
    this.saturday = true,
    this.sunday = true,
  });

  factory Availability.fromJson(Map<String, dynamic> json) {
    return Availability(
      monday: json["monday"] == null ? true : json["monday"]!=0,
      tuesday: json["tuesday"] == null ? true : json["tuesday"]!=0,
      wednesday: json["wednesday"] == null ? true : json["wednesday"]!=0,
      thursday: json["thursday"] == null ? true : json["thursday"]!=0,
      friday: json["friday"] == null ? true : json["friday"]!=0,
      saturday: json["saturday"] == null ? true : json["saturday"]!=0,
      sunday: json["sunday"] == null ? true : json["sunday"]!=0,
    );
  }

  Map<String, Object?> toMap() {
    return {
      "monday": monday,
      "tuesday": tuesday,
      "wednesday": wednesday,
      "thursday": thursday,
      "friday": friday,
      "saturday": saturday,
      "sunday": sunday,
    };
  }

  toJson() {
    return jsonEncode(toMap());
  }
}

class User {
  final int? id;
  final String username;
  final String mail;
  final String role;
  final String? password;

  final Gender? gender;
  final DateTime? birthday;
  final Availability? availability;
  final Location? location;
  final DateTime? createdAt;
  late List<int> friendsList;

  User({
    this.id,
    required this.username,
    required this.mail,
    required this.role,
    this.password,

    this.gender,
    this.birthday,
    this.availability,
    this.location,
    this.createdAt,
    this.friendsList = const [],
  });

  factory User.fromJson(Map<String, dynamic> json) {
    List<String> dataListAsString = json['friends']?.isEmpty ?? true ? <String>[] : json['friends'].split(',');
    List<int> dataListAsInt = dataListAsString.map((data) => int.parse(data)).toList();

    return User(
      id: json.getFromMapFirstNotNull( ['id', 'userId']) as int,

      username: json['username'] as String,
      mail: json['mail'] as String,
      role: json['role'] as String,
      password: json['password'] == null ? null : json['password']! as String,

      gender: json['gender'] == null ? null : getGenderByString(json['gender']),
      birthday: json['birthday'] == null ? null :  parseStringToDateTime(json['birthday']! as String),  // HttpDate.parse(json['birthday']),
      availability: json['monday'] == null ? null : Availability.fromJson(json),
      location: json['locationId'] == null ? null : Location.fromJson(json),
      createdAt: json['createdAt'] == null ? null : parseStringToDateTime(json['createdAt']! as String), // DateTime.parse(json['createdAt']! as String),
      friendsList: dataListAsInt,
    );
  }

  Map<String, Object?> toMap() {
    Map<String, Object?> map = {
      "id": id,
      "username": username,
      "mail": mail,
      "role": role,
      "password": password,
      "gender": gender == null ? null : gender!.toShortString(),
      "birthday": birthday == null ? null : birthday!.getDbDateTime(),
      "createdAt" : createdAt == null ? null : createdAt!.getDbDateTime(),
      "location": location == null ? null :  location!.toMap(),
      "friends": friendsList == null ? null : friendsList.join(",")
    };
    if(availability != null){
      ///will add into user map : monday, tuesday ...
      map.addAll(availability!.toMap());
    }
    return map;
  }

  toJson() {
    return jsonEncode(toMap());
  }
}