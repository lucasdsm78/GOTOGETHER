import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:localstorage/localstorage.dart';

import 'navigation.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final formkey = GlobalKey<FormState>();
  final LocalStorage storage = LocalStorage('poney_app');
  String email = '';
  String userName = '';
  String password = '';
  bool isloading = false;
  bool isReset = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ElevatedButton(
        child: Text("access App"),
        onPressed: () async {
          Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                  builder: (BuildContext context) =>
                      Navigation()
              )
          );
        },
      ),
    );
  }

}
