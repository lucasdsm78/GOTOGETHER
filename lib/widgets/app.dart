import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:go_together/mock/mock.dart';
import 'package:go_together/models/user.dart';
import 'package:go_together/widgets/activities_list.dart';
import 'package:go_together/widgets/user.dart';
import 'package:go_together/widgets/activity.dart';
import 'package:go_together/widgets/user_list.dart';
import 'package:go_together/helper/session.dart';

class GotogetherApp extends StatelessWidget {
  const GotogetherApp({Key? key}) : super(key: key);
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    createSessionValue("userId", 1);
    createSessionValue("user", Mock.userGwen);
    return MaterialApp(
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
      home:ActivityList(),
    );
  }
}