import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:go_together/helper/parse_helper.dart';
import 'package:go_together/helper/session.dart';
import 'package:go_together/helper/storage.dart';
import 'package:go_together/mock/mock.dart';
import 'package:go_together/models/sports.dart';
import 'package:go_together/usecase/sport.dart';
import 'package:go_together/widgets/screens/activities/activities_list.dart';
import 'package:go_together/widgets/screens/activities/activity_set.dart';
import 'package:go_together/widgets/screens/tournament/tournament_set.dart';
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
  final store = CustomStorage();
  final session = Session();
  @override
  void initState() {
    super.initState();
    log("START APP");
    store.storeUser(Mock.userGwen);
    session.setData("user", Mock.userGwen);
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
      routes: {
        Navigation.tag: (context) => Navigation()
      },
      //home:SignUp(),
      home:const ActivitySet(),

      // home : StreamBuilder<List<Sport>>(
      //   stream: store.getAndStoreSportsStream(),
      //   builder: (
      //       BuildContext context,
      //       AsyncSnapshot<List<Sport>> snapshot,
      //       ) {
      //     if (snapshot.connectionState == ConnectionState.waiting) {
      //       return const Center(
      //           child:CircularProgressIndicator()
      //       );
      //     } else if (snapshot.connectionState == ConnectionState.active
      //         || snapshot.connectionState == ConnectionState.done) {
      //       if (snapshot.hasError) {
      //         return const Text('Error');
      //       } else if (snapshot.hasData) {
      //         return Navigation();
      //       } else {
      //         return const Text('Empty data');
      //       }
      //     } else {
      //       return Text('State: ${snapshot.connectionState}');
      //     }
      //   },
      //   // other arguments
      // )

    );
  }

}
