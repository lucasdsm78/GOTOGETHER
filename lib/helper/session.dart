import 'package:flutter_session/flutter_session.dart';

createSessionValue(String name, dynamic value) async{
  await FlutterSession().set(name, value);
}

getSessionValue(String name) async{
  await FlutterSession().get(name);
}