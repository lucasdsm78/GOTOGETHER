import 'dart:convert';
import 'package:go_together/helper/enum/run_types.dart';
import 'package:go_together/models/activity.dart';
import 'package:go_together/models/conversation.dart';
import 'package:go_together/models/messages.dart';
import 'package:go_together/models/signal.dart';
import 'package:go_together/models/sports.dart';
import 'package:go_together/models/user.dart';

import '../models/tournament.dart';

// all there are used to parse the data get from our api, when
// the api return a list of entity (like user, or activity)

List<Sport> parseSportsFromJson(String json) {
  final parsed = jsonDecode(json).cast<Map<String, dynamic>>();
  //log("Api sport parsed = " + parsed.toString());
  return parsed.map<Sport>((el) => Sport.fromJson(el)).toList();
}
List<Sport> parseSports(String responseBody) {
  final parsed = jsonDecode(responseBody)["success"].cast<Map<String, dynamic>>();
  return parsed.map<Sport>((json) => Sport.fromJson(json)).toList();
}
String listSportToJson(List<Sport> res){
  return  res.map((e) => e.toJson()).toList().toString();
}


List<User> parseUsers(String responseBody) {
  final parsed = jsonDecode(responseBody)["success"].cast<Map<String, dynamic>>();
  return parsed.map<User>((json) => User.fromJson(json)).toList();
}


List<Activity> parseActivities(String responseBody) {
  final parsed = jsonDecode(responseBody)["success"].cast<Map<String, dynamic>>();
  //log("api parse activity : " + parsed.toString());
  return parsed.map<Activity>((json) => Activity.fromJson(json)).toList();
}

List<Tournament> parseTournament(String responseBody) {
  final parsed = jsonDecode(responseBody)["success"].cast<Map<String, dynamic>>();
  //log("api parse activity : " + parsed.toString());
  return parsed.map<Tournament>((json) => Tournament.fromJson(json)).toList();
}

List<Message> parseMessages(String responseBody) {
  final parsed = jsonDecode(responseBody)["success"].cast<Map<String, dynamic>>();
  return parsed.map<Message>((json) => Message.fromJson(json)).toList();
}

List<Conversation> parseConversation(String responseBody) {
  final parsed = jsonDecode(responseBody)["success"]["conversation"].cast<
      Map<String, dynamic>>();
  return parsed.map<Conversation>((json) => Conversation.fromJson(json))
      .toList();
}
List<Signal> parseSignal(String responseBody) {
  final parsed = jsonDecode(responseBody)["success"].cast<Map<String, dynamic>>();
  return parsed.map<Signal>((json) => Signal.fromJson(json)).toList();
}


jsonParseToList(String? jsonList, RunTypes type){
  List<String> dataListAsString = jsonList?.isEmpty ?? true ? <String>[] : jsonList!.split(',');
  switch(type){
    case RunTypes.int:
      return dataListAsString.map((data) => int.parse(data)).toList();
    case RunTypes.string:
      return dataListAsString;
    default:
      return dataListAsString.map((data) => int.parse(data)).toList();
  }
}