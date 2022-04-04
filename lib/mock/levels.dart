
import 'dart:io';
import 'package:go_together/helper/enum/gender.dart';
import 'package:go_together/helper/extensions/date_extension.dart';
import 'package:go_together/models/level.dart';
import 'package:go_together/models/user.dart';

class MockLevel {
  static List<Level> levelList = [
    Level(id: 1, name: "pro"),
    Level(id: 2, name: "semi-pro"),
    Level(id: 3, name: "amateur")
  ];

}
