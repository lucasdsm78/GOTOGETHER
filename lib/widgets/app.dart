import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:go_together/mock/mock.dart';
import 'package:go_together/models/sports.dart';
import 'package:go_together/usecase/sport.dart';
import 'package:go_together/widgets/activities_list.dart';
import 'package:go_together/widgets/activity_set.dart';
import 'package:go_together/widgets/google_maps.dart';
import 'package:localstorage/localstorage.dart';
import 'package:go_together/widgets/signup.dart';

import 'package:go_together/widgets/navigation.dart';

import 'message_details.dart';

class GotogetherApp extends StatelessWidget {
  GotogetherApp({Key? key}) : super(key: key);

  final LocalStorage storage = LocalStorage('go_together_app');
  final SportUseCase sportUseCase = SportUseCase();

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    storage.setItem('user', Mock.userGwen.toJson());
    getSports();

    return MaterialApp(
      routes: {
        // put routes here
        ActivityList.tag: (context) => const ActivityList(),
        ActivityCreate.tag: (context) => const ActivityCreate(),
        MapScreen.tag: (context) => MapScreen(),
        Navigation.tag: (context) => Navigation(),
      },
      debugShowCheckedModeBanner: false,
      title: 'Welcome to Go Together',
      theme: ThemeData(
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
        ),
      ),
      //home:SignUp(),
      home:Navigation(),
    );
  }

  void getSports() async{
    List<Sport> res = await sportUseCase.getAll();
    List<dynamic> list = res.map((e) => e.toJson()).toList();
    storage.setItem('sports', list.toString());
  }
}