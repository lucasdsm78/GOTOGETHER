import 'package:flutter/material.dart';
import 'package:go_together/helper/enum/custom_colors.dart';
import 'package:go_together/helper/error_helper.dart';
import 'package:go_together/models/signal.dart';
import 'package:go_together/models/user.dart';
import 'package:go_together/usecase/signal.dart';
import 'package:go_together/usecase/user.dart';
import 'package:go_together/widgets/screens/users/signal.dart';

class UserProfile extends StatefulWidget {
  const UserProfile({Key? key, required this.user}) : super(key: key);
  final User user;

  @override
  _UserProfileState createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  
  final UserUseCase userUseCase = UserUseCase();
  final SignalUseCase signalUseCase = SignalUseCase();
  late Future<User> futureUser;
  late Future<List<Signal>> futureSignal;
  bool isReported = false;
  int userId = 24;
  @override
  void initState() {
    super.initState();
    futureUser = userUseCase.getById(userId);
    futureSignal = signalUseCase.getAll(id: 18);
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
          backgroundColor: CustomColors.goTogetherMain,
        ),
        body: Center(
          child: Column(
        children:[
            FutureBuilder<List<Signal>>(
            future: futureSignal,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                for(int i=0; i< snapshot.data!.length;i++) {
                  if (snapshot.data![i].idReported == userId) {
                    isReported = true;
                  }
                }
                return  ElevatedButton(
                      child: Text('TextButton'),
                      onPressed: isReported ? null : (){
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (context) {
                              return SignalProfile(userId: userId);
                            },
                          ),
                        );
                      },
                    );


              } else if (snapshot.hasError) {
                return getSnapshotErrWidget(snapshot);
              }

              // By default, show a loading spinner.
              return const CircularProgressIndicator();
            },
          ),
          FutureBuilder<User>(
          future: futureUser,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return Text(snapshot.data!.username);
            } else if (snapshot.hasError) {
              return getSnapshotErrWidget(snapshot);
            }
            // By default, show a loading spinner.
            return const CircularProgressIndicator();
          },
        ),
        ]),

        ),
      ),
    );
  }
}