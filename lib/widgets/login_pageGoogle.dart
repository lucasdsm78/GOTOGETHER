import 'package:flutter/material.dart';

import 'sign_in_screen_google.dart';

void main() {
  runApp(ConnexionGoogle());
}

class ConnexionGoogle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FlutterFire Samples',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        brightness: Brightness.dark,
      ),
      home: SignInScreen(),
    );
  }
}