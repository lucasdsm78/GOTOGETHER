import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:go_together/mock/mock.dart';
import 'package:go_together/models/sports.dart';
import 'package:go_together/models/user.dart';
import 'package:go_together/usecase/sport.dart';
import 'package:go_together/widgets/activities_list.dart';
import 'package:go_together/widgets/activity_create.dart';
import 'package:go_together/widgets/user.dart';
import 'package:go_together/widgets/activity.dart';
import 'package:go_together/widgets/user_list.dart';
import 'package:localstorage/localstorage.dart';

import 'package:go_together/widgets/navigation.dart';

import 'login_gwen.dart';

class GotogetherApp extends StatelessWidget {
  GotogetherApp({Key? key}) : super(key: key);

  final LocalStorage storage = LocalStorage('go_together_app');
  final SportUseCase sportUseCase = SportUseCase();

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    //createSessionValue("user", Mock.userGwen.toJson());
    storage.setItem('user', Mock.userGwen.toJson());
    getSports();

    return MaterialApp(
      routes: {
        // put routes here
        ActivityList.tag: (context) => const ActivityList(),
        ActivityCreate.tag: (context) => const ActivityCreate(),
      },
      title: 'Welcome to Go Together',
      theme: ThemeData(
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
        ),
      ),
      //home:UserProfile(),
      //home:ActivityDetailsScreen(activityId: 1),
      //home:UserList(),
     // home:ActivityList(),
      home:LoginScreen(),
    );
  }

  void getSports() async{
    List<Sport> res = await sportUseCase.getAll();
    List<dynamic> list = res.map((e) => e.toJson()).toList();
    storage.setItem('sports', list.toString());
  }
}