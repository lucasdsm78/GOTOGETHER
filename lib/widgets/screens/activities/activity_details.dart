import 'dart:developer';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_together/helper/NotificationCenter.dart';
import 'package:go_together/helper/extensions/date_extension.dart';
import 'package:go_together/helper/session.dart';
import 'package:go_together/mock/mock.dart';
import 'package:go_together/models/activity.dart';
import 'package:go_together/models/user.dart';
import 'package:go_together/usecase/activity.dart';
import 'package:go_together/helper/enum/gender.dart';
import 'package:flutter_observer/Observable.dart';
import 'package:go_together/widgets/components/base_container.dart';
import 'package:go_together/widgets/components/custom_button_right.dart';
import 'package:go_together/widgets/components/lists/custom_row.dart';
import 'package:go_together/widgets/components/text_icon.dart';

import 'package:go_together/widgets/navigation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../../components/maps/map.dart';

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
  late Session session = Session();
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
   currentUser = session.getData("user");

  }

  @override

  Widget build(BuildContext context) {
    //log( activity.location.lat.toString() + " ---- " + activity.location.lon.toString());
    bool isUserInActivityList = activity.currentParticipants!.contains(currentUser.id.toString());
    return Scaffold(
      appBar: AppBar(
        title: const Text('Activity Details'),
      ),
      body: Center(
        child:
        BaseContainer(
          useBorder: false,
          width: 600,
          child: ListView(
          children: <Widget>[
            SizedBox(height: 20),
            Text( activity.description,
              style:const TextStyle(
                fontSize: 40,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
              /*DefaultTextStyle.of(context).style.apply(fontSizeFactor: 1.0)*/
            ),

            SizedBox(height: 20),
            Text("Organisateur : " + activity.host.username,
              style:const TextStyle(
                fontSize: 20,
              )
            ),

            SizedBox(height: 20),
            TextIcon(
                title: activity.dateStart.getFrenchDateTime() + " - " + activity.dateEnd.getFrenchDateTime(),
                icon: Icon(Icons.date_range, color :Colors.green,),
            ),

            SizedBox(height: 20),
            CustomRow(children: [
              TextIcon(
                title: activity.nbCurrentParticipants.toString() + "/" + activity.attendeesNumber.toString() + " participants",
                icon: Icon(Icons.account_circle_rounded, color :Colors.green,),
              ),
              TextIcon(
                title:  activity.level.name,
                icon: Icon(MdiIcons.podium, color :Colors.green,),
              ),
            ]),

            SizedBox(height: 20),
            TextIcon(
              title: activity.location.address + ", " + activity.location.city + ", " + activity.location.country,
              icon: Icon(Icons.location_on_rounded, color :Colors.green,),
            ),

            SizedBox(height: 20),
            Text("Evenement " + (activity.public! ? "publique" : "privé"),
            style: const TextStyle(fontSize: 20)
            ),

            SizedBox(height: 20),


            Text("Destiné à/aux " + (activity.criterionGender != null ? activity.criterionGender!.translate() : "Tous"),
              style:const TextStyle(fontSize: 20)
            ),

            SizedBox(height: 20),
            //Map
            Container(
              height: MediaQuery.of(context).size.height *0.3,
              width: MediaQuery.of(context).size.width *0.6,
              child:CustomMap(pos: LatLng(activity.location.lat,activity.location.lon),onMark: ()=>{},),
            ),

            const SizedBox(height: 30),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Stack(
                children: <Widget>[
                  /*Positioned.fill(
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
                  ),*/
                (currentUser.id == activity.host.id
                  ? Container()
                  : Align(
                    alignment: Alignment.center,
                    child: RightButton(
                      onPressed: () async {
                        Activity updatedActivity = await activityUseCase.joinActivityUser(activity, currentUser.id!, activity.currentParticipants!.contains(currentUser.id.toString()));
                        setState(() {
                          activity = updatedActivity;
                        });
                        Observable.instance.notifyObservers(NotificationCenter.userJoinActivity.stateImpacted, notifyName: NotificationCenter.userJoinActivity.name, map: {});
                      },
                      width: 5.0,
                      height: 5.0,
                      textButton: (!isUserInActivityList ? "JE PARTICIPE" : "JE NE PARTICIPE PLUS"),
                      isRight: !isUserInActivityList,
                    )
                  )
                )
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
                  child: const Text('SUPPRIMER')
                )
                : Container()
            ),
          ],
        )
        )
      ),
    );
  }
}