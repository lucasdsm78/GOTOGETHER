import 'package:go_together/models/messages.dart';
import 'package:go_together/api/message_service_io.dart';

class MessageUseCase{
MessageServiceApi api = MessageServiceApi();

Future<List<Message>> getAll({Map<String, dynamic> map = const {}}) async {
  return api.getAll(map: map).then((value) => value);
}

Future<List<Message>> getById(int id) async {
  return api.getById(id).then((value) => value);
}

}