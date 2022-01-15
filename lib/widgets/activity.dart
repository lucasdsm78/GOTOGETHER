import 'package:flutter/material.dart';
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

  @override
  void initState() {
    super.initState();
    futureActivity = fetchActivityById(widget.activityId);
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
      ),
    );
  }
}