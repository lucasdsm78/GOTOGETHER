import 'dart:developer';

import 'package:go_together/helper/parse_helper.dart';
import 'package:go_together/models/sports.dart';
import 'package:go_together/models/user.dart';
import 'package:go_together/usecase/sport.dart';
import 'package:localstorage/localstorage.dart';

/// @deprecated.<br>
/// It's more like a prototype, but should be replaced one day.<br>
///
/// This class is used to get data from local storage.
/// Then we can get data from whenever we are in the application.
///
/// The main limitation is that we need an async function to get data.
/// In lots of screen we need to do requests using data like current user or token,
/// meaning we have to do a lot of check to avoid non initialized var.
///
/// We prefer using our Session singleton class instead, that don't require async
class CustomStorage{
  final db = LocalStorage('go_together_app');
  static final CustomStorage _instance = CustomStorage._internal();

  factory CustomStorage() {
    return _instance;
  }
  CustomStorage._internal();

  //region get stored Sports
  ///generate a stream to send data when the storage get the value required
  Stream<List<Sport>> getAndStoreSportsStream({Function? func}) {
    return (() async* {
      List<Sport> res = await _getAndStoreSport(func: func);
      yield res;
    })();
  }

  ///generate a Future to send data when the storage get the value required
  Future<List<Sport>> getAndStoreSportsFuture({Function? func}) async {
      return await _getAndStoreSport(func: func);
  }

  /// This will get sport list from storage to provide it where needed in the app.
  /// if the storage doesn't found it, we do an API call to store them.
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