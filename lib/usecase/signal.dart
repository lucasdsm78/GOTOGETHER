import 'package:go_together/api/signal_service_io.dart';
import 'package:go_together/models/signal.dart';

class SignalUseCase {
  SignalServiceApi api = SignalServiceApi();

  Future<List<Signal>> getAll({Map<String, dynamic> map = const {}, required int id}) async {
    return api.getAll(map: map, id: id).then((value) => value);
  }
  Future<Signal?> add(Signal signal) async {
    return api.add(signal).then((value) => value);
  }
}
