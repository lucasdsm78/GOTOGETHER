import 'package:go_together/helper/extensions/string_extension.dart';
import 'package:http/http.dart' as http;
import 'package:go_together/helper/commonFunctions.dart';

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

/// used to make API call in each api services.
/// [host] is our online server.
//@todo : save and use the token to execute request requiring user id
class Api{
  final http.Client client = http.Client();
  final host = "http://51.255.51.106:5000/";
  var mainHeader = {
    'Content-Type': 'application/json; charset=UTF-8',
    'secret_key' :'?somekey_thatWillReject_1orMore_unwantedRequest',
    //      HttpHeaders.authorizationHeader: 'Basic your_api_token_here',
    'x-access-tokens': 'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJ1c2VySWQiOjEsImV4cCI6MTY1NzQ5MDY2NX0.hgWA4pkOt606ISiy1OEPB7USIL_SxlESiEh9S6_MXeM'
  };

  static final Api _instance = Api._internal();
  factory Api() {
    return _instance;
  }
  Api._internal();

  setMainHeader(keyPara, val){
    // update mainHeader
    mainHeader[keyPara]=val ;
  }
  setToken(val){
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
  String errMsg() => 'an error occured with status code - $codeStatus - , $message';

  ApiErr({required this.codeStatus, required this.message});
}