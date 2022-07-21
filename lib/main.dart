import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:go_together/widgets/app.dart';

void main() async {
  await GetStorage.init();
  runApp(GotogetherApp());
}