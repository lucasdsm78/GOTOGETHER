import 'package:go_together/api/sport_service_io.dart';
import 'package:go_together/models/sports.dart';

class SportUseCase {
  SportServiceApi api = SportServiceApi();
  Future<List<Sport>> getAll({Map<String, dynamic> map = const {}}) async {
    return api.getAll(map: map).then((value) => value);
  }

  Future<Sport> getById(int id) async {
    return api.getById(id).then((value) => value);
  }
}
