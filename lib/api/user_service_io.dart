import 'dart:convert';
import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:go_together/helper/parse_helper.dart';
import 'package:go_together/models/user.dart';
import 'package:go_together/helper/api.dart';

class UserServiceApi {
  final api = Api();

  Future<List<User>> getAll({Map<String, dynamic> map = const {}}) async {
    final response = await api.client
        .get(Uri.parse(api.host + 'users'));
    if (response.statusCode == 200) {
      return compute(parseUsers, response.body);
    } else {
      throw ApiErr(codeStatus: response.statusCode, message: "failed to load users");
    }
  }

  Future<User> getById(int id) async {
    final response = await api.client
        .get(Uri.parse(api.host + 'users/$id'));
    if (response.statusCode == 200) {
      return User.fromJson(jsonDecode(response.body)["success"]);
    } else {
      throw ApiErr(codeStatus: response.statusCode, message: "failed to load user");
    }
  }

  Future<User> getByToken() async {
    final response = await api.client
        .get(Uri.parse(api.host + 'users/fromToken'),
        headers: api.mainHeader
    );
    log(api.mainHeader.toString());
    if (response.statusCode == 200) {
      return User.fromJson(jsonDecode(response.body)["success"]);
    } else {
      throw ApiErr(codeStatus: response.statusCode, message: "failed to load user");
    }
  }

  Future<String> getJWTTokenByGoogleToken(String tokenGoogle) async {
    final response = await api.client
        .get(Uri.parse(api.host + 'authentication/google/$tokenGoogle'),
      headers: api.mainHeader
    );
    // STATUS 200 = OK
    if (response.statusCode == 200) {
      return jsonDecode(response.body)["success"]["token"];
    } else {
      throw ApiErr(codeStatus: response.statusCode, message: "failed to load token");
    }
  }

  Future<String> getJWTTokenByLogin(Map<String, String> login) async {
    final response = await api.httpPost(api.host + 'authentication', jsonEncode(login));
    if (response.statusCode == 200) {
      return jsonDecode(response.body)["success"]["token"];
    } else {
      Map<String,dynamic> resMap = jsonDecode(response.body)["error"];
      throw ApiErr(codeStatus: response.statusCode, message: resMap["message"]);
    }
  }

  Future<bool> setPublicKey(String publicKey) async {
    final response = await api.client
        .patch(Uri.parse(api.host + 'users/set_pubkey'),
      headers: api.mainHeader,
      body: jsonEncode({"pubKey":publicKey}),
    );
    if (response.statusCode == 200) {
      return true;
    } else {
      throw ApiErr(codeStatus: response.statusCode, message: "failed to update public key");
    }
  }


  Future<User> add(User user) async {
    //ex : createUser(User(username: "flutterUser2", mail: "flutterUser2@gmail.com", password: "flutterPass"));
    final response = await api.client
        .post(Uri.parse(api.host + 'users'),
      headers: api.mainHeader,
      body: user.toJson(),
    );
    if (response.statusCode == 201) {
      return User.fromJson(jsonDecode(response.body)["success"]["last_insert"]);
    } else {
      Map<String,dynamic> resMap = jsonDecode(response.body)["error"];
      throw ApiErr(codeStatus: response.statusCode, message: resMap["message"], reason: resMap["reason"]);
    }
  }

  Future<User> updatePost(User user) async {
    final response = await api.client
        .post(Uri.parse(api.host + 'users/${user.id}'),
      headers: api.mainHeader,
      body: user.toJson(),
    );
    print(jsonDecode(response.body));
    if (jsonDecode(response.body)['success'] != null) {
      return User.fromJson(jsonDecode(response.body));
    } else {
      throw ApiErr(codeStatus: response.statusCode, message: "failed to update user");
    }
  }

  Future<User> updatePatch(Map<String, dynamic> map) async {
    if(map.containsKey("id")){
      throw Exception('need an id to update an user.');
    }
    else {
      final response = await api.client
          .patch(Uri.parse(api.host + 'users/${map["id"]}'),
        headers: api.mainHeader,
        body: jsonEncode(map),
      );
      print(jsonDecode(response.body));
      if (jsonDecode(response.body)['success'] != null) {
        return User.fromJson(jsonDecode(response.body));
      } else {
        throw ApiErr(codeStatus: response.statusCode, message: "failed to update user");
      }
    }
  }

  Future<User> delete(String id) async {
    final response = await api.client
        .delete(Uri.parse(api.host + 'users/$id'),
      headers: api.mainHeader,
    );

    if (response.statusCode == 200) {
      return User.fromJson(jsonDecode(response.body));
    } else {
      throw ApiErr(codeStatus: response.statusCode, message: "failed to delete user");
    }
  }
}