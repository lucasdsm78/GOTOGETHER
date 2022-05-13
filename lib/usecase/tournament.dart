import 'package:go_together/api/activity_service_io.dart';
import 'package:go_together/models/tournament.dart';

import '../api/tournament_service_io.dart';

class TournamentUseCase {
  TournamentServiceApi api = TournamentServiceApi();

  Future<List<Tournament>> getAll({Map<String, dynamic> map = const {}}) async {
    return api.getAll(map: map).then((value) => value);
  }

  Future<Tournament> getById(int id) async {
    return api.getById(id).then((value) => value);
  }

  Future<Tournament?> add(Tournament tournament) async {
    return api.add(tournament).then((value) => value);
  }

  Future<Tournament?> update(Tournament tournament) async {
    return api
        .updatePost(tournament)
        .then((value) => value)
        .catchError((onError) => onError);
  }

  Future<Tournament?> updatePartially(Map<String, dynamic> map) async {
    return api
        .updatePatch(map)
        .then((value) => value)
        .catchError((onError) => onError);
  }


  Future<Tournament> joinActivityUser(Tournament tournament, int userId, bool hasJoin) async {
    return api
        .joinActivityUser(tournament, userId, hasJoin)
        .then((value) => value)
        .catchError((onError) => onError);
  }

  Future<Tournament?> delete(id) async {
    api.delete(id).then((value) => value);
  }
}
