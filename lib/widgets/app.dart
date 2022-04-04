import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:go_together/mock/mock.dart';
import 'package:go_together/models/sports.dart';
import 'package:go_together/usecase/sport.dart';
import 'package:go_together/widgets/screens/activities/activities_list.dart';
import 'package:go_together/widgets/screens/activities/activity_set.dart';
import 'package:go_together/widgets/screens/users/signal.dart';
import 'package:go_together/widgets/screens/users/user.dart';
import 'package:localstorage/localstorage.dart';
import 'package:go_together/widgets/screens/login/signup.dart';

import 'package:go_together/widgets/navigation.dart';
import 'package:go_together/widgets/screens/tchat/message_details.dart';


class GotogetherApp extends StatefulWidget {
  const GotogetherApp({Key? key}) : super(key: key);

  @override
  _GotogetherAppState createState() => _GotogetherAppState();
}

class _GotogetherAppState extends State<GotogetherApp> {
  final LocalStorage storage = LocalStorage('go_together_app');
  final SportUseCase sportUseCase = SportUseCase();
  late Future<List<Sport>> futureSportsMainApp;

  @override
  void initState() {
    super.initState();
    getSports();
    storage.setItem('user', Mock.userGwen.toJson()); //simulate user connexion
  }

  @override
  void dispose() {
    super.dispose();
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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

      /*home: FutureBuilder<List<Sport>>(
        future: futureSportsMainApp,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Navigation();
          } else if (snapshot.hasError) {
            return Container(
              child: Center(
                child: Text("Une erreur est survenue"),
              ),
            );
          }
          return const Center(
              child: CircularProgressIndicator()
          );
        },
      ),*/
    );
  }

  void getSports() async{
    Future<List<Sport>> sports = sportUseCase.getAll();
    List<Sport> res = await sports;
    List<dynamic> list = res.map((e) => e.toJson()).toList();
    storage.setItem('sports', list.toString());
    setState(() {
      futureSportsMainApp = sports;
    });
    log("SPORT SAVED IN STORAGE");
  }
  Future<List<List<Sport>>> futureWait() async {
    return Future.wait([
      sportUseCase.getAll(),
    ]);
  }
}
