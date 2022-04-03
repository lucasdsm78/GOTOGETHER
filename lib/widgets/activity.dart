import 'package:flutter/material.dart';
import 'package:go_together/helper/NotificationCenter.dart';
import 'package:go_together/mock/mock.dart';
import 'package:go_together/models/activity.dart';
import 'package:go_together/models/user.dart';
import 'package:go_together/usecase/activity.dart';
import 'package:go_together/helper/enum/gender.dart';
import 'package:flutter_observer/Observable.dart';

import 'navigation.dart';

class ActivityDetailsScreen extends StatefulWidget {
  const ActivityDetailsScreen({Key? key,  required this.activity}) : super(key: key);
  final Activity activity;
  static const tag = "activity_details";

  @override
  _ActivityDetailsScreenState createState() => _ActivityDetailsScreenState();
}

class _ActivityDetailsScreenState extends State<ActivityDetailsScreen> {
  final ActivityUseCase activityUseCase = ActivityUseCase();
  late User currentUser = Mock.userGwen;
  late Activity activity;

  @override
  void initState() {
    super.initState();
    activity = widget.activity;
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          //mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
                activity.description,
                style: DefaultTextStyle.of(context).style.apply(fontSizeFactor: 1.0)
            ),
            Text(activity.nbCurrentParticipants.toString() + "/" + activity.attendeesNumber.toString() + " participants" ),
            Text(activity.location.address + ", " + activity.location.city + ", " + activity.location.country),
            Text(activity.dateStart.toString() + " - " + activity.dateEnd.toString()),
            Text("Organisateur : " + activity.host.username),
            Text("Evenement publique : " + (activity.public! ? "Oui" : "Non")),
            Text("Destiné à : " + (activity.criterionGender != null ? activity.criterionGender!.translate() : "Tous")),

            const SizedBox(height: 30),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Stack(
                children: <Widget>[
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: activity.currentParticipants!.contains(currentUser.id.toString()) ? LinearGradient(
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
                    onPressed: () async {
                      Activity updatedActivity = await activityUseCase.joinActivityUser(activity, currentUser.id!, activity.currentParticipants!.contains(currentUser.id.toString()));
                      setState(() {
                        activity = updatedActivity;
                      });
                      Observable.instance.notifyObservers(NotificationCenter.userJoinActivity.stateImpacted,
                          notifyName : NotificationCenter.userJoinActivity.name,map: {});
                    },
                    child: const Text('Join'),
                  ),
                ],
              ),
            ),
            (currentUser.id == activity.host.id
                ? TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.red,
                    primary: Colors.white,
                  ),
                  onPressed:() {
                    activityUseCase.delete(activity.id.toString() );
                    Observable.instance.notifyObservers(NotificationCenter.userCancelActivity.stateImpacted,
                        notifyName : NotificationCenter.userCancelActivity.name,map: {});
                    Navigator.of(context).popAndPushNamed(Navigation.tag);

                  },
                  child: const Text('Annuler')
                )
                : Container()
            ),
          ],
        )
      ),
    );
  }
}