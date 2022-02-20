import 'package:flutter/material.dart';
import 'package:go_together/widgets/activities_list.dart';
import 'package:go_together/widgets/random_word.dart';
import 'package:go_together/widgets/user.dart';
import 'package:go_together/widgets/activity.dart';
import 'package:go_together/widgets/user_list.dart';
import 'package:go_together/widgets/login_pageGoogle.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Welcome to Go Together',
        theme: ThemeData(
            appBarTheme: const AppBarTheme(
             backgroundColor: Colors.white,
             foregroundColor: Colors.black,
            ),
           ),
    //home:RandomWord(),
      //home:UserProfile(),
      //home:ActivityPage(),
      //home:UserList(),
      home:ConnexionGoogle(),
    );
  }
}
