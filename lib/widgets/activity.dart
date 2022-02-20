

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:go_together/mock/mock.dart';
import 'package:go_together/models/activity.dart';
import 'package:go_together/models/user.dart';
import 'package:go_together/usecase/activity.dart';

class ActivityDetailsScreen extends StatefulWidget {
  const ActivityDetailsScreen({Key? key, required this.activityId}) : super(key: key);

  final int activityId;


  @override
  _ActivityDetailsScreenState createState() => _ActivityDetailsScreenState();
}

class _ActivityDetailsScreenState extends State<ActivityDetailsScreen> {
  final ActivityUseCase activityUseCase = ActivityUseCase();
  late Future<Activity> futureActivity;
  late User currentUser = Mock.userGwen;

  @override
  void initState() {
    super.initState();
    futureActivity = activityUseCase.getById(widget.activityId);
    /*getSessionValue("user").then((res){
      setState(() {
        currentUser = res;
      });
    });*/
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Activity Details'),
        ),
        body: Center(
          child: FutureBuilder<Activity>(
            future: futureActivity,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                //return Text(snapshot.data!.description);
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  //mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                        snapshot.data!.description,
                        style: DefaultTextStyle.of(context).style.apply(fontSizeFactor: 2.0)
                    ),
                    Text(snapshot.data!.nbCurrentParticipants.toString() + "/" + snapshot.data!.attendeesNumber.toString() + " participants" ),
                    Text(snapshot.data!.location.address + ", " + snapshot.data!.location.city + ", " + snapshot.data!.location.country),
                    Text(snapshot.data!.dateStart.toString() + " - " + snapshot.data!.dateEnd.toString()),
                    const SizedBox(height: 30),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: Stack(
                        children: <Widget>[
                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: !snapshot.data!.currentParticipants!.contains(currentUser.id.toString()) ? LinearGradient(
                                  colors: <Color>[
                                    Color(0xFF1CFF0B),
                                    Color(0xFF17D400),
                                    Color(0xFF1CFF0B),
                                  ]) 
                                  : LinearGradient(
                                    colors: <Color>[
                                      Color(0xFFFF0000),
                                      Color(0xFFFF2525),
                                      Color(0xFFFF0000),
                                    ]
                                ),
                              ),
                            ),
                          ),
                          TextButton(
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.all(16.0),
                              primary: Colors.white,
                              textStyle: const TextStyle(fontSize: 20),
                            ),
                            onPressed: () {
                              setState(() {
                                futureActivity = activityUseCase.joinActivityUser(snapshot.data!, currentUser.id!, snapshot.data!.currentParticipants!.contains(currentUser.id.toString()));
                              });
                            },
                            child: const Text('Join'),
                          ),
                        ],
                      ),
                    ),
                    TextButton(
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.red,
                          primary: Colors.white,
                        ),
                        onPressed:() {
                            //log('${snapshot.data!.id}, description: ${ snapshot.data!.description} ');
                            activityUseCase.delete(snapshot.data!.id.toString() );

                        },
                        child: const Text('Annuler')
                    )
                  ],
                );
              } else if (snapshot.hasError) {
                return Text('${snapshot.error}');
              }
              return const Center(
                  child: CircularProgressIndicator()
              );
            },
          ),
        ),
    );
  }
}