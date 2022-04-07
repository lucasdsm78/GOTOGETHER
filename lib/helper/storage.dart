import 'dart:developer';

import 'package:go_together/helper/parse_helper.dart';
import 'package:go_together/mock/mock.dart';
import 'package:go_together/models/sports.dart';
import 'package:go_together/models/user.dart';
import 'package:go_together/usecase/sport.dart';
import 'package:localstorage/localstorage.dart';

class CustomStorage{
  final db = LocalStorage('go_together_app');
  static final CustomStorage _instance = CustomStorage._internal();

  factory CustomStorage() {
    return _instance;
  }
  CustomStorage._internal();

  //region get stored Sports
  Stream<List<Sport>> getAndStoreSportsStream({Function? func}) {
    return (() async* {
      List<Sport> res = await _getAndStoreSport(func: func);
      yield res;
    })();
  }
  Future<List<Sport>> getAndStoreSportsFuture({Function? func}) async {
      return await _getAndStoreSport(func: func);
  }
  Future<List<Sport>> _getAndStoreSport({Function? func}) async {
    List<Sport> res = [];
    String? storedSport = await get("sports");
    if(storedSport != null){
      log("GET FUTURE - SPORT IN LOCAL STORAGE");
      res = parseSportsFromJson(storedSport);
    }
    else{
      List<Sport> res = await SportUseCase().getAll();
      List<dynamic> list = res.map((e) => e.toJson()).toList();
      set("sports", list.toString());
      log("MAIN FUTURE - SAVE IN LOCAL STORAGE");
    }
    if(func != null){
      func(res);
    }
    return res;
  }
  //endregion

  storeUser(User user){
    set('user', user.toJson());
  }
  Future<String> getUser() async {
    return await db.getItem("user");
  }


  set(String key, dynamic data){
    db.setItem(key, data);
  }

  Future<String> get(String key) async {
    return await db.getItem(key);
  }

}