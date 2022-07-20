import 'dart:math';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_together/helper/NotificationCenter.dart';
import 'package:go_together/helper/extensions/date_extension.dart';
import 'package:go_together/helper/session.dart';
import 'package:go_together/mock/user.dart';
import 'package:go_together/models/activity.dart';
import 'package:go_together/models/user.dart';
import 'package:go_together/usecase/activity.dart';
import 'package:go_together/helper/enum/gender.dart';
import 'package:flutter_observer/Observable.dart';
import 'package:go_together/widgets/components/base_container.dart';
import 'package:go_together/widgets/components/buttons/custom_button_right.dart';
import 'package:go_together/widgets/components/lists/custom_row.dart';
import 'package:go_together/widgets/components/text_icon.dart';

import 'package:go_together/widgets/navigation.dart';
import 'package:go_together/widgets/screens/activities/activity_attendeesCommentary.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:go_together/models/location.dart';

import '../../../models/tournament2.dart';
import '../../../usecase/tournament.dart';
import '../../components/maps/map.dart';
import '../tournament/tournament_details.dart';

/// This is the screen where you can see activity details.
/// It's also here we can join / quit an activity
class ActivityDetailsScreen extends StatefulWidget {
  const ActivityDetailsScreen({Key? key,  required this.activity}) : super(key: key);
  final Activity activity;
  //final Tournament tournament;

  static const tag = "activity_details";

  @override
  _ActivityDetailsScreenState createState() => _ActivityDetailsScreenState();
}

class _ActivityDetailsScreenState extends State<ActivityDetailsScreen> {
  final ActivityUseCase activityUseCase = ActivityUseCase();
  final TournamentUseCase tournamentUseCase = TournamentUseCase();
  late User currentUser = MockUser.userGwen;
  late Session session = Session();
  late Activity activity;
  late Tournament tournament;


  @override
  void initState() {
    super.initState();
    activity = widget.activity;
    tournament = tournamentUseCase.getById(1) as Tournament;
    currentUser = session.getData(SessionData.user);
  }

  _joinActivity () async {
    Activity updatedActivity = await activityUseCase.joinActivityUser(activity, currentUser.id!, activity.currentAttendees!.contains(currentUser.id.toString()));
    setState(() {
      activity = updatedActivity;
    });
    Observable.instance.notifyObservers(NotificationCenter.userJoinActivity.stateImpacted, notifyName: NotificationCenter.userJoinActivity.name, map: {});
  }

  _checkTournament(){
    bool isActivityIsTournament = tournament.id.toString()!.contains(activity.id.toString());
    if(isActivityIsTournament==true){
      return TournamentDetailsScreen(activity);
    }
  }



  void _checkAttendeesCommentary(Activity activity) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) {
          return  ActivitiesAttendeesCommentary(activity: activity);
        },
      ),
    );
  }

  _deleteActivity() {
    activityUseCase.delete(activity.id.toString() );
    Observable.instance.notifyObservers(NotificationCenter.userCancelActivity.stateImpacted,
        notifyName : NotificationCenter.userCancelActivity.name,map: {});
    Navigator.of(context).popAndPushNamed(Navigation.tag);
  }

  @override
  Widget build(BuildContext context) {
    //log( activity.location.lat.toString() + " ---- " + activity.location.lon.toString());
    bool isUserInActivityList = activity.currentAttendees!.contains(currentUser.id.toString());
    bool isActivityIsTournament = tournament.id.toString()!.contains(activity.id.toString());
    // _checkNbEquip() {
    //   if (tournament.nbEquip != null) {
    //    return TextIcon(
    //       title: tournament.nbEquip.toString(),
    //       icon: Icon(MdiIcons.podium, color: Colors.green,),
    //     );
    //   };
    // }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Détails de l\'activité'),
      ),
      body: Center(
        child:
        BaseContainer(
          useBorder: false,
          width: 600,
          child: ListView(
          children: <Widget>[
            Container(
              margin: const EdgeInsets.only(top: 20.0, ),
              child:Text( activity.description + ""+  activity.id.toString(),
                style:const TextStyle(
                  fontSize: 40,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
                /*DefaultTextStyle.of(context).style.apply(fontSizeFactor: 1.0)*/
              ),
            ),

            Container(
              margin: const EdgeInsets.only(top: 20.0, ),
              child:Text("Organisateur : " + activity.host.username,
                style:const TextStyle(
                  fontSize: 20,
                )
              ),
            ),

            //region fields with icons
            Container(
              margin: const EdgeInsets.only(top: 20.0, ),
              child: TextIcon(
                title: activity.sport.name,
                icon: Icon(Icons.sports_soccer, color :Colors.green,),
              ),
            ),

            Container(
              margin: const EdgeInsets.only(top: 20.0, ),
              child:CustomRow(children: [
                GestureDetector(
                  onTap: () {
                    _checkAttendeesCommentary(widget.activity);
                  },
                  child: TextIcon(
                    title: activity.nbCurrentParticipants.toString() + "/" + activity.attendeesNumber.toString() + " participants",
                    icon: Icon(Icons.account_circle_rounded, color :Colors.green,),
                  ),
                ),


                // GestureDetector(
                //     onTap: () {
                //       _checkAttendeesCommentary(widget.activity);
                //     },
                //     child:_checkNbEquip()
                // ),

                TextIcon(
                  title:  activity.level.name,
                  icon: Icon(MdiIcons.podium, color :Colors.green,),
                ),
              ]
              ),
            ),

            Container(
              margin: const EdgeInsets.only(top: 20.0, ),
              child:TextIcon(
                title: activity.location.address + ", " + activity.location.city + ", " + activity.location.country,
                icon: Icon(Icons.location_on_rounded, color :Colors.green,),
              ),
            ),
            //endregion

            Container(
              margin: const EdgeInsets.only(top: 20.0, ),
              child:
              Text("Evenement " + (activity.public! ? "publique" : "privé"),
              style: const TextStyle(fontSize: 20)
              ),
            ),

            Container(
              margin: const EdgeInsets.only(top: 20.0, ),
              child: Text("Destiné à/aux " + (activity.criterionGender != null ? activity.criterionGender!.translate() : "Tous"),
                  style:const TextStyle(fontSize: 20)
              ),
            ),

            Container(
              margin: const EdgeInsets.only(top: 20.0, ),
              child:
              Container(
                height: MediaQuery.of(context).size.height *0.3,
                width: MediaQuery.of(context).size.width *0.6,
                child:CustomMap(pos: LatLng(activity.location.lat,activity.location.lon),onMark: (Location newLocation)=>{},),
              ),
            ),

            Container(
              margin: const EdgeInsets.only(top: 30.0, ),
              child: (currentUser.id == activity.host.id
                ? Container()
                : Center(
                  child: RightWrongButton(
                    onPressed: _joinActivity,
                    width: 5.0,
                    height: 5.0,
                    textButton: (!isUserInActivityList ? "JE PARTICIPE" : "JE NE PARTICIPE PLUS"),
                    isRight: !isUserInActivityList,
                  )
              )
              ),
            ),

            Container(
              margin: const EdgeInsets.only(top: 20.0, ),
              child:
              (currentUser.id == activity.host.id
                  ? TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.red,
                      primary: Colors.white,
                    ),
                    onPressed: _deleteActivity,
                    child: const Text('SUPPRIMER')
                  )
                  : Container()
              ),
            ),
            ],
          )
        )
      ),
    );
  }
}