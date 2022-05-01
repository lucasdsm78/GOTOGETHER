import 'package:go_together/api/activity_service_io.dart';
import 'package:go_together/models/activity.dart';
import 'package:go_together/models/user.dart';

class ActivityUseCase {
  ActivityServiceApi api = ActivityServiceApi();

  Future<List<Activity>> getAll({Map<String, dynamic> map = const {}}) async {
    return api.getAll(map: map).then((value) => value);
  }

  Future<Activity> getById(int id) async {
    return api.getById(id).then((value) => value);
  }

  Future<Activity?> add(Activity activity) async {
    return api.add(activity).then((value) => value);
  }

  Future<Activity?> update(Activity activity) async {
    return api
        .updatePost(activity)
        .then((value) => value)
        .catchError((onError) => onError);
  }

  Future<Activity?> updatePartially(Map<String, dynamic> map) async {
    return api
        .updatePatch(map)
        .then((value) => value)
        .catchError((onError) => onError);
  }


  //@todo : refacto hasJoin into wantToJoin, then invert all boolean of this call (if true, use false)
  Future<Activity> joinActivityUser(Activity activity, int userId, bool hasJoin) async {
    return api
        .joinActivityUser(activity, userId, hasJoin)
        .then((value) => value)
        .catchError((onError) => onError);
  }

  Future<Activity?> delete(id) async {
    api.delete(id).then((value) => value);
  }

  Future<List<User>> getAllAttendeesByIdActivity(int id) async {
    return api.getAllAttendeesByIdActivity(id).then((value) => value);
  }

  Future<bool> changeHost(Map<String, dynamic> map) async {
    return api
        .changeHost(map)
        .then((value) => value)
        .catchError((onError) => onError);
  }
}
