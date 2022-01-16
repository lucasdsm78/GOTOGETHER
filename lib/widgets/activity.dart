import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:go_together/helper/session.dart';
import 'package:go_together/models/activity.dart';
import 'package:go_together/api/requests.dart';

class ActivityDetailsScreen extends StatefulWidget {
  const ActivityDetailsScreen({Key? key, required this.activityId}) : super(key: key);

  final int activityId;

  @override
  _ActivityDetailsScreenState createState() => _ActivityDetailsScreenState();
}

class _ActivityDetailsScreenState extends State<ActivityDetailsScreen> {
  late Future<Activity> futureActivity;
  late int userId;

  @override
  void initState() {
    super.initState();
    futureActivity = fetchActivityById(widget.activityId);
    getSessionValue("userId").then((res){
      setState(() {
        userId = res as int;
      });
    });
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
                    Text(snapshot.data!.nbCurrentParticipants.toString() + "/" + snapshot.data!.participantsNumber.toString() + " participants" ),
                    Text(snapshot.data!.address + ", " + snapshot.data!.city + ", " + snapshot.data!.country),
                    Text(snapshot.data!.dateStart.toString() + " - " + snapshot.data!.dateEnd.toString()),
                    const SizedBox(height: 30),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: Stack(
                        children: <Widget>[
                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: !snapshot.data!.currentParticipants.contains(userId.toString()) ? LinearGradient(
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
                                futureActivity = joinActivity(snapshot.data!, userId, snapshot.data!.currentParticipants.contains(userId.toString()));
                              });
                            },
                            child: const Text('Join'),
                          ),
                        ],
                      ),
                    ),
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