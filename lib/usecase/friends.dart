import 'package:go_together/api/friend_service_io.dart';
import 'package:go_together/models/user.dart';

class FriendsUseCase {
  FriendsServiceApi api = FriendsServiceApi();

  _mapBody(int idUserSender ,int idUserReceiver){
    return {
      "userIdSender": idUserSender,
      "userIdReceiver": idUserReceiver,
    };
  }

  //Future<List<User>> getAll({Map<String, dynamic> map = const {}}) async {
  //  return api.getAll(map: map).then((value) => value);
  //}

  Future<List<User>> getById(int userId) async {
    return api.getById(userId).then((value) => value);
  }
  Future<List<User>> getWaitingById(int userId) async {
    return api.getWaitingById(userId).then((value) => value);
  }
  Future<List<User>> getWaitingAndValidateById(int userId) async {
    return api.getWaitingAndValidateById(userId).then((value) => value);
  }

  Future<User?> add(int idUserSender ,int idUserReceiver) async {
    return api.add(_mapBody(idUserSender, idUserReceiver)).then((value) => value);
  }

  Future<bool> validateFriendship(int idUserSender ,int idUserReceiver) async {
    return api
        .validateFriendship(_mapBody(idUserSender, idUserReceiver))
        .then((value) => value)
        .catchError((onError) => onError);
  }

  Future<bool> delete(int idUserSender ,int idUserReceiver) async {
    return api.delete(_mapBody(idUserSender, idUserReceiver))
        .then((value) => value)
        .catchError((onError) => onError);
  }
}
