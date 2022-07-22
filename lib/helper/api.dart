import 'dart:developer';
import 'dart:io';

import 'package:go_together/helper/extensions/string_extension.dart';
import 'package:http/http.dart' as http;
import 'package:go_together/helper/commonFunctions.dart';
import 'package:http/http.dart';

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
  Function getHttpRequestFunction(http.Client client){
    if(this == Method.get){
      return client.get;
    }
    else if(this == Method.post){
      return client.post;
    }
    else if(this == Method.patch){
      return client.patch;
    }
    else if(this == Method.put){
      return client.put;
    }
    else{
      return client.delete;
    }
  }
}

/// used to make API call in each api services.
/// [host] is our online server.
class Api{
  final http.Client client = http.Client();
  final host = "http://51.255.51.106:5000/";
  var mainHeader = {
    'Content-Type': 'application/json; charset=UTF-8',
    'secret_key' :'?somekey_thatWillReject_1orMore_unwantedRequest',
    //      HttpHeaders.authorizationHeader: 'Basic your_api_token_here',
    'x-access-tokens': 'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJ1c2VySWQiOjEsImV4cCI6MTY1ODMyMzk5N30.9N2BMYLy-0vqwLSx-fQk_7uUF5Sw7Z_iBET5cuCvkO8'
  };

  //region http request
  Future<Response> _httpRequest(Method method, String route, {String? json}) async  {
    try {
      Response response ;
      Function action = method.getHttpRequestFunction(this.client);
      if(method == Method.get){
        response = await action(Uri.parse(route),
          headers: this.mainHeader,
        );
      }
      else{
        response = await action(Uri.parse(route),
          headers: this.mainHeader,
          body: json,
        );
      }

      return response;
    } on SocketException catch(err){
      throw ApiErr(codeStatus: -1, message: "Aucune connexion internet");
    }
  }
  Future<Response> httpGet(String route) async {
    return await _httpRequest(Method.get, route);
  }
  Future<Response> httpPost(String route, String? json) async {
    return await _httpRequest(Method.post, route, json: json);
  }
  Future<Response> httpPatch(String route, String? json) async {
    return await _httpRequest(Method.patch, route, json: json);
  }
  Future<Response> httpPut(String route, String? json) async {
    return await _httpRequest(Method.put, route, json: json);

  }
  Future<Response> httpDelete(String route, {String? json}) async {
    return await _httpRequest(Method.delete, route, json: json);
  }

  //endregion

  static final Api _instance = Api._internal();
  factory Api() {
    return _instance;
  }
  Api._internal();

  setMainHeader(keyPara, val){
    // update mainHeader
    mainHeader[keyPara]=val ;
  }
  setToken(String val){
    log("x-access-tokens setted" + val);
    setMainHeader("x-access-tokens", val);
  }


  /// Prepare the params in url (ex : https://api/activities?hostId=1&city=Cergy).
  /// [isFirstParam] should be true if we require to add a '?' char in first place.
  /// [map] contains all the data to convert as url params.
  /// The keys are used as param name (ex : {hostId:1, city:Cergy}).
  ///
  /// [ignored] is the list of keys we may want to ignore in the map provided.
  /// let it empty if nothing is to ignore.
  String handleUrlParams(bool isFirstParam, Map<String, dynamic> map,  {List<String>  ignored:const []}){
    String params = "";
    int count = 0;
    map.forEach((key, value){
      if(!ignored.contains(key) && value != null && !(isEmptyValue(value)) ){
        params += (isFirstParam && count ==0 ? "?" : "&") + key + "=" + value.toString();
        count ++;
      }
    });
    return params;
  }

}

class ApiErr implements Exception {
  int codeStatus;
  String message;
  String? reason;
  String errMsg() => 'an error occured with status code - $codeStatus - , $message';

  ApiErr({required this.codeStatus, required this.message, this.reason});
}

extension ApiCodeStatusExtension on ApiErr{
  void defaultMessageFromCodeStatus() {
    if(this.codeStatus >= 500){
      this.message = "Une erreur est survenue sur le serveur";
    }
    else if(this.codeStatus == 403){
      this.message = "Vous n'avez pas les droits pour cela";
    }
    else if(this.codeStatus == 401){
      this.message = "Une erreur est survenue lors de votre identification";
    }
  }
}