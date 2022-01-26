import 'dart:convert';
import 'dart:io';
import 'package:go_together/helper/date_extension.dart';
import 'package:go_together/helper/enum/gender.dart';
import 'package:go_together/models/location.dart';

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
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int,
      username: json['username'] as String,
      mail: json['mail'] as String,
      role: json['role'] as String,
      password: json['password']! as String,

      gender: json['gender'] == null ? null : getGenderByString(json['gender']),
      birthday: json['birthday'] == null ? null : HttpDate.parse(json['birthday']),
      availability: Availability.fromJson(json),
      location: json['locationId'] == null ? null : Location.fromJson(json),
      createdAt: json['createdAt'] == null ? null : HttpDate.parse(json['createdAt']),
    );
  }

  Map<String, Object?> toMap() {
    Map<String, Object?> map = {
      "id": id,
      "username": username,
      "mail": mail,
      "role": role,
      "password": password,

      "gender": birthday == null ? null : gender!.toShortString(),
      "birthday": birthday == null ? null : birthday!.getDbDateTime(),
      "createdAt" : createdAt == null ? null : createdAt!.getDbDateTime(),
    };
    if(availability != null){
      map.addAll(availability!.toMap());
    }
    if(location != null){
      map.addAll(location!.toMap());
    }
    return map;
  }

  toJson() {
    return jsonEncode(toMap());
  }
}