import 'package:flutter/material.dart';
import 'package:go_together/models/user.dart';

class UserProfile extends StatefulWidget {
  const UserProfile({Key? key, required this.user}) : super(key: key);
  final User user;

  @override
  _UserProfileState createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  late User user ;
  @override
  void initState() {
    super.initState();
    user = widget.user;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Profile',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Profile'),
        ),
        body: Center(
          child: Text(user.username),
        ),
      ),
    );
  }
}