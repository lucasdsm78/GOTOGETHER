import 'dart:convert';
import 'dart:developer';
import 'package:go_together/helper/string_extension.dart';
import 'package:go_together/models/activity.dart';
import 'package:go_together/models/sports.dart';
import 'package:go_together/models/user.dart';
import 'package:http/http.dart' as http;

enum Method {
  get,
  post,
  patch,
  put,
  delete
}
extension MethodExtension on Method {
  String toShortString() {
    return this.toString().enumValueToNormalCase();
  }
}

class Api{
  final http.Client client = http.Client();
  final host = "http://51.255.51.106:5000/";
  final mainHeader = {
    'Content-Type': 'application/json; charset=UTF-8',
    'secret_key' :'?somekey_thatWillReject_1orMore_unwantedRequest'
    //      HttpHeaders.authorizationHeader: 'Basic your_api_token_here',
  };


  String handleUrlParams(bool isFirstParam, Map<String, dynamic> map, List<String> ignored){
    String params = "";
    int count = 0;
    map.forEach((key, value){
      if(!ignored.contains(key) && value != null && !(value?.isEmpty ?? true) ){
        params += (isFirstParam && count ==0 ? "?" : "&") + key + "=" + value.toString();
        count ++;
      }
    });
    return params;
  }

  List<Activity> parseActivities(String responseBody) {
    final parsed = jsonDecode(responseBody)["success"].cast<Map<String, dynamic>>();
    log("api parse activity : " + parsed.toString());
    return parsed.map<Activity>((json) => Activity.fromJson(json)).toList();
  }

  List<Sport> parseSports(String responseBody) {
    final parsed = jsonDecode(responseBody)["success"].cast<Map<String, dynamic>>();
    log("Api sport parsed = " + parsed.toString());
    return parsed.map<Sport>((json) => Sport.fromJson(json)).toList();
  }

  List<User> parseUsers(String responseBody) {
    final parsed = jsonDecode(responseBody)["success"].cast<Map<String, dynamic>>();
    return parsed.map<User>((json) => User.fromJson(json)).toList();
  }
}
