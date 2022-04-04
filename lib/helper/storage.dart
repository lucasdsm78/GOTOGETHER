import 'dart:developer';

import 'package:go_together/helper/parse_helper.dart';
import 'package:go_together/mock/mock.dart';
import 'package:go_together/models/sports.dart';
import 'package:go_together/models/user.dart';
import 'package:go_together/usecase/sport.dart';
import 'package:localstorage/localstorage.dart';

class Storage{
  final db = LocalStorage('go_together_app');
  static final Storage _instance = Storage._internal();

  factory Storage() {
    return _instance;
  }
  Storage._internal();

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
      res = parseSports(storedSport);
    }
    else{
      List<Sport> res = await SportUseCase().getAll();
      List<dynamic> list = res.map((e) => e.toJson()).toList();
      set("sports", list);
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

  set(String key, dynamic data){
    db.setItem(key, data.toString());
  }

  Future<String> get(String key) async {
    return await db.getItem(key);
  }

}