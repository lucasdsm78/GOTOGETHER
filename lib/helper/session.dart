import 'package:flutter_session/flutter_session.dart';

createSessionValue(String name, dynamic value) async{
  await FlutterSession().set(name, value);
}

dynamic getSessionValue(String name) async{
  return await FlutterSession().get(name);
}