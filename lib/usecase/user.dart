import 'package:go_together/api/user_service_io.dart';
import 'package:go_together/models/user.dart';

class UserUseCase {
  UserServiceApi api = UserServiceApi();

  Future<List<User>> getAll({Map<String, dynamic> map = const {}}) async {
    return api.getAll(map: map).then((value) => value);
  }

  Future<User> getById(int id) async {
    return api.getById(id).then((value) => value);
  }

  Future<String> getJWTTokenByGoogleToken(String tokenGoogle) async {
    return api.getJWTTokenByGoogleToken(tokenGoogle).then((value) => value);
  }

  Future<User?> add(User user) async {
    return api.add(user).then((value) => value);
  }

  Future<User?> update(User user) async {
    return api
        .updatePost(user)
        .then((value) => value)
        .catchError((onError) => onError);
  }

  Future<User?> updatePartially(Map<String, dynamic> map) async {
    return api
        .updatePatch(map)
        .then((value) => value)
        .catchError((onError) => onError);
  }

  Future<User?> delete(id) async {
    api.delete(id).then((value) => value);
  }
}
